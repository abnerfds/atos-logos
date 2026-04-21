import 'package:freezed_annotation/freezed_annotation.dart';

part 'select_church_request.freezed.dart';
part 'select_church_request.g.dart';

@freezed
abstract class SelectChurchRequest with _$SelectChurchRequest {
  const factory SelectChurchRequest({
    required String selectionToken,
    required String churchId,
  }) = _SelectChurchRequest;

  factory SelectChurchRequest.fromJson(Map<String, dynamic> json) =>
      _$SelectChurchRequestFromJson(json);
}
