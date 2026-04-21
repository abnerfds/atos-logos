import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/position.dart';

part 'positions_state.freezed.dart';

@freezed
class PositionsState with _$PositionsState {
  const factory PositionsState.initial() = _Initial;
  const factory PositionsState.loading() = _Loading;
  const factory PositionsState.loaded({required List<Position> positions}) = _Loaded;
  const factory PositionsState.error({required String message}) = _Error;
}
