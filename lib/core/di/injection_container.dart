import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/insumos/data/datasources/insumo_remote_datasource.dart';
import '../../features/insumos/data/repositories/insumo_repository_impl.dart';
import '../../features/insumos/domain/repositories/insumo_repository.dart';
import '../../features/insumos/domain/usecases/create_insumo_usecase.dart';
import '../../features/insumos/domain/usecases/delete_insumo_usecase.dart';
import '../../features/insumos/domain/usecases/get_insumo_usecase.dart';
import '../../features/insumos/domain/usecases/get_insumos_usecase.dart';
import '../../features/insumos/domain/usecases/toggle_insumo_ativo_usecase.dart';
import '../../features/insumos/domain/usecases/update_insumo_usecase.dart';
import '../../features/insumos/presentation/cubit/insumos_cubit.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

void initDependencies() {
  // External
  sl.registerLazySingleton<Dio>(() => ApiClient.create());

  // Data sources
  sl.registerLazySingleton<InsumoRemoteDatasource>(
    () => InsumoRemoteDatasourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<InsumoRepository>(
    () => InsumoRepositoryImpl(datasource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetInsumosUsecase(sl()));
  sl.registerLazySingleton(() => GetInsumoUsecase(sl()));
  sl.registerLazySingleton(() => CreateInsumoUsecase(sl()));
  sl.registerLazySingleton(() => UpdateInsumoUsecase(sl()));
  sl.registerLazySingleton(() => DeleteInsumoUsecase(sl()));
  sl.registerLazySingleton(() => ToggleInsumoAtivoUsecase(sl()));

  // Cubits
  sl.registerFactory(
    () => InsumosCubit(
      getInsumos: sl(),
      getInsumo: sl(),
      createInsumo: sl(),
      updateInsumo: sl(),
      deleteInsumo: sl(),
      toggleAtivo: sl(),
    ),
  );
}
