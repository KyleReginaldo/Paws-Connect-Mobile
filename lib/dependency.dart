import 'package:get_it/get_it.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => AuthProvider());
  sl.registerLazySingleton(() => AuthRepository(sl()));
}
