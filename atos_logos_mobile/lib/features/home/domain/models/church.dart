import 'package:freezed_annotation/freezed_annotation.dart';

part 'church.freezed.dart';
part 'church.g.dart';

@freezed
abstract class Church with _$Church {
  const factory Church({
    required String id,
    required String name,
    String? documentNumber,
    required String activePlan,
  }) = _Church;

  factory Church.fromJson(Map<String, dynamic> json) =>
      _$ChurchFromJson(json);
}
