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
import '../../features/estoques/data/datasources/estoque_remote_datasource.dart';
import '../../features/estoques/data/repositories/estoque_repository_impl.dart';
import '../../features/estoques/domain/repositories/estoque_repository.dart';
import '../../features/estoques/domain/usecases/get_estoques_usecase.dart';
import '../../features/estoques/domain/usecases/registrar_entrada_estoque_usecase.dart';
import '../../features/estoques/domain/usecases/get_movimentacoes_usecase.dart';
import '../../features/estoques/presentation/cubit/estoques_cubit.dart';
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

  // ========== ESTOQUE DEPENDENCIES ==========
  
  // Data sources
  sl.registerLazySingleton<EstoqueRemoteDatasource>(
    () => EstoqueRemoteDatasource(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<EstoqueRepository>(
    () => EstoqueRepositoryImpl(remoteDatasource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetEstoquesUsecase(sl()));
  sl.registerLazySingleton(() => RegistrarEntradaEstoqueUsecase(sl()));
  sl.registerLazySingleton(() => GetMovimentacoesUsecase(sl()));

  // Cubits
  sl.registerFactory(
    () => EstoquesCubit(
      getEstoques: sl(),
      registrarEntrada: sl(),
      getMovimentacoes: sl(),
    ),
  );
}
