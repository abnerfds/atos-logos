import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/ebd_class.dart';

part 'ebd_state.freezed.dart';

@freezed
class EbdState with _$EbdState {
  const factory EbdState.initial() = _Initial;
  const factory EbdState.loading() = _Loading;
  const factory EbdState.loaded({required List<EbdClass> classes}) = _Loaded;
  const factory EbdState.error({required String message}) = _Error;
}
