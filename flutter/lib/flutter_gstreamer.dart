
import 'src/rust/frb_generated.dart';

export "src/rust/api.dart";


Future<void> init() async {
  await RustLib.init();
}