import 'package:freezed_annotation/freezed_annotation.dart';

part 'church_option.freezed.dart';
part 'church_option.g.dart';

@freezed
abstract class ChurchOption with _$ChurchOption {
  const factory ChurchOption({
    required String id,
    required String name,
    required String branchName,
    required String role,
  }) = _ChurchOption;

  factory ChurchOption.fromJson(Map<String, dynamic> json) =>
      _$ChurchOptionFromJson(json);
}
