import 'package:freezed_annotation/freezed_annotation.dart';

part 'visitor.freezed.dart';
part 'visitor.g.dart';

@freezed
abstract class Visitor with _$Visitor {
  const factory Visitor({
    required String id,
    required String churchId,
    required String name,
    String? phone,
    String? observations,
    required String createdAt,
  }) = _Visitor;
  factory Visitor.fromJson(Map<String, dynamic> json) => _$VisitorFromJson(json);
}

@freezed
abstract class VisitorPage with _$VisitorPage {
  const factory VisitorPage({
    required List<Visitor> data,
    required int total,
    required int page,
    required int limit,
  }) = _VisitorPage;
  factory VisitorPage.fromJson(Map<String, dynamic> json) => _$VisitorPageFromJson(json);
}
