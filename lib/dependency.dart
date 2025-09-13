import 'package:get_it/get_it.dart';
import 'package:paws_connect/features/auth/provider/auth_provider.dart';
import 'package:paws_connect/features/auth/repository/auth_repository.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';
import 'package:paws_connect/features/forum/repository/forum_repository.dart';
import 'package:paws_connect/features/fundraising/provider/fundraising_provider.dart';
import 'package:paws_connect/features/fundraising/repository/fundraising_repository.dart';
import 'package:paws_connect/features/google_map/provider/address_provider.dart';
import 'package:paws_connect/features/pets/provider/pet_provider.dart';
import 'package:paws_connect/features/profile/provider/profile_provider.dart';
import 'package:paws_connect/features/profile/repository/image_repository.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';

import 'features/google_map/repository/address_repository.dart';
import 'features/pets/repository/pet_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => AuthProvider());
  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton(() => PetProvider());
  sl.registerLazySingleton(() => PetRepository(sl()));
  sl.registerLazySingleton(() => FundraisingProvider());
  sl.registerLazySingleton(() => FundraisingRepository(sl()));
  sl.registerLazySingleton(() => AddressProvider());
  sl.registerLazySingleton(() => AddressRepository(sl()));
  sl.registerLazySingleton(() => ProfileProvider());
  sl.registerLazySingleton(() => ProfileRepository(sl()));
  sl.registerLazySingleton(() => ImageRepository());
  sl.registerLazySingleton(() => ForumRepository(sl()));
  sl.registerLazySingleton(() => ForumProvider());
}
