import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  final String id;
  final String name;
  final String countryCode;
  final String address;
  final String? managerId;
  final String? districtManagerId;

  const Branch({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.address,
    this.managerId,
    this.districtManagerId,
  });

  @override
  List<Object?> get props => [id, name, countryCode, address, managerId, districtManagerId];
}
