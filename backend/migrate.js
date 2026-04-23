const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

function parseCatalog(catalog_id) {
  const parts = catalog_id.split("-");
  return {
    catalogId: parts.slice(0, 2).join("-"), // catalog-at
    year: parts[2] || "2025",
  };
}

function groupTranslations(doc) {
  return {
    category: {
      de: doc.category || null,
      en: doc.category_en || null,
      hr: doc.category_hr || null,
    },
    default_finding: {
      de: doc.default_finding_de || null,
      en: doc.default_finding_en || null,
      hr: doc.default_finding_hr || null,
    },
    default_measure: {
      de: doc.default_measure_de || null,
      en: doc.default_measure_en || null,
      hr: doc.default_measure_hr || null,
    },
  };
}

async function migrate() {
  console.log("STARTING MIGRATION...");

  const snapshot = await db.collection("questions").get();
  console.log("Docs found:", snapshot.size);

  let batch = db.batch();
  let count = 0;

  const versionMap = new Map(); // track created versions

  for (const doc of snapshot.docs) {
    const data = doc.data();

    if (!data.catalog_id) {
      console.warn(`Skipping ${doc.id} (no catalog_id)`);
      continue;
    }

    const { catalogId, year } = parseCatalog(data.catalog_id);

    // default version setup
    const versionId = `${year}-v1`;
    const versionNumber = 1;

    // Derive country code from catalogId, e.g. "catalog-at" → "AT"
    const countryCode = catalogId.split("-")[1]?.toUpperCase() || "??";

    // create version doc once per catalog
    const versionKey = `${catalogId}_${versionId}`;
    if (!versionMap.has(versionKey)) {
      const versionRef = db
        .collection("auditCatalogs")
        .doc(catalogId)
        .collection("versions")
        .doc(versionId);

      batch.set(
        versionRef,
        {
          version: versionId,
          versionNumber,
          year,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      // Also create/update the catalog parent document so it shows up in queries
      const catalogRef = db.collection("auditCatalogs").doc(catalogId);
      batch.set(
        catalogRef,
        {
          id: catalogId,
          country_code: countryCode,
          version: versionId,
          year: parseInt(year, 10) || 2025,
          language: "de",
          question_count: 0,
        },
        { merge: true }
      );

      versionMap.set(versionKey, true);
    }

    const translations = groupTranslations(data);

    const questionRef = db
      .collection("auditCatalogs")
      .doc(catalogId)
      .collection("questions")
      .doc(doc.id);

    batch.set(questionRef, {
      catalogId,
      catalog_id: catalogId,
      country: data.country || null,
      order: data.order || null,
      master_question_id: data.master_question_id || null,

      // All text fields - these were previously missing
      text_de: data.text_de || null,
      text_en: data.text_en || null,
      text_hr: data.text_hr || null,
      explanation_text_de: data.explanation_text_de || null,
      explanation_text_en: data.explanation_text_en || null,
      explanation_text_hr: data.explanation_text_hr || null,
      internal_note_de: data.internal_note_de || null,
      internal_note_en: data.internal_note_en || null,
      internal_note_hr: data.internal_note_hr || null,

      introducedInVersionId: versionId,
      introducedInVersionNumber: versionNumber,

      // Nested translation objects (category, default_finding, default_measure)
      ...translations,

      migratedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    count++;

    if (count % 400 === 0) {
      await batch.commit();
      console.log(`Committed ${count}`);
      batch = db.batch();
    }
  }

  if (count % 400 !== 0) {
    await batch.commit();
  }

  // Update question_count on each catalog document
  console.log("Updating question counts...");
  for (const [versionKey] of versionMap) {
    const catalogId = versionKey.split("_")[0];
    const qSnap = await db
      .collection("auditCatalogs")
      .doc(catalogId)
      .collection("questions")
      .count()
      .get();
    await db.collection("auditCatalogs").doc(catalogId).update({
      question_count: qSnap.data().count,
    });
  }

  console.log("Migration complete:", count);
}

migrate()
  .then(() => {
    console.log("DONE");
    process.exit(0);
  })
  .catch((e) => {
    console.error("ERROR:", e);
    process.exit(1);
  });