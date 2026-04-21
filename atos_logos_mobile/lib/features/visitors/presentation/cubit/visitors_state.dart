import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/visitor.dart';

part 'visitors_state.freezed.dart';

@freezed
class VisitorsState with _$VisitorsState {
  const factory VisitorsState.initial() = _Initial;
  const factory VisitorsState.loading() = _Loading;
  const factory VisitorsState.loaded({
    required List<Visitor> visitors,
    required int total,
    required int page,
  }) = _Loaded;
  const factory VisitorsState.error({required String message}) = _Error;
}
