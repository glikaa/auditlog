import '../../domain/entities/branch.dart';

class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.name,
    required super.countryCode,
    required super.address,
    super.managerId,
    super.districtManagerId,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      address: json['address'] as String? ?? '',
      managerId: json['manager_id'] as String?,
      districtManagerId: json['district_manager_id'] as String?,
    );
  }
}
