from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import auth, audits, catalogs, reports

app = FastAPI(
    title="Audit API",
    description="REST API for the Audit Web App – Filialrevision",
    version="1.0.0",
)

# CORS – allow Flutter web app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(audits.router, prefix="/audits", tags=["Audits"])
app.include_router(catalogs.router, prefix="/catalogs", tags=["Catalogs"])
app.include_router(reports.router, prefix="/reports", tags=["Reports"])


@app.get("/", tags=["Health"])
async def health_check():
    return {"status": "ok", "service": "audit-api"}
