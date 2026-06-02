import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/auth_remote_datasource.dart';
import '../../features/estoques/data/datasources/estoque_remote_datasource.dart';
import '../../features/estoques/data/repositories/estoque_repository_impl.dart';
import '../../features/estoques/domain/repositories/estoque_repository.dart';
import '../../features/estoques/domain/usecases/get_estoques_usecase.dart';
import '../../features/estoques/domain/usecases/get_movimentacoes_usecase.dart';
import '../../features/estoques/domain/usecases/registrar_entrada_estoque_usecase.dart';
import '../../features/estoques/presentation/cubit/estoques_cubit.dart';
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
import '../../features/receitas/data/datasources/receita_remote_datasource.dart';
import '../../features/receitas/data/repositories/receita_repository_impl.dart';
import '../../features/receitas/domain/repositories/receita_repository.dart';
import '../../features/receitas/domain/usecases/create_receita_usecase.dart';
import '../../features/receitas/domain/usecases/delete_receita_usecase.dart';
import '../../features/receitas/domain/usecases/get_receita_usecase.dart';
import '../../features/receitas/domain/usecases/get_receitas_usecase.dart';
import '../../features/receitas/domain/usecases/toggle_receita_ativo_usecase.dart';
import '../../features/receitas/domain/usecases/update_receita_usecase.dart';
import '../../features/receitas/presentation/cubit/receitas_cubit.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<Dio>(ApiClient.create);

  sl.registerLazySingleton(() => AuthRemoteDatasource(dio: sl()));

  sl.registerLazySingleton<InsumoRemoteDatasource>(
    () => InsumoRemoteDatasourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ReceitaRemoteDatasource>(
    () => ReceitaRemoteDatasourceImpl(dio: sl()),
  );
  sl.registerLazySingleton(() => EstoqueRemoteDatasource(dio: sl()));

  sl.registerLazySingleton<InsumoRepository>(
    () => InsumoRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<ReceitaRepository>(
    () => ReceitaRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<EstoqueRepository>(
    () => EstoqueRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => GetInsumosUsecase(sl()));
  sl.registerLazySingleton(() => GetInsumoUsecase(sl()));
  sl.registerLazySingleton(() => CreateInsumoUsecase(sl()));
  sl.registerLazySingleton(() => UpdateInsumoUsecase(sl()));
  sl.registerLazySingleton(() => DeleteInsumoUsecase(sl()));
  sl.registerLazySingleton(() => ToggleInsumoAtivoUsecase(sl()));

  sl.registerLazySingleton(() => GetReceitasUsecase(sl()));
  sl.registerLazySingleton(() => GetReceitaUsecase(sl()));
  sl.registerLazySingleton(() => CreateReceitaUsecase(sl()));
  sl.registerLazySingleton(() => UpdateReceitaUsecase(sl()));
  sl.registerLazySingleton(() => DeleteReceitaUsecase(sl()));
  sl.registerLazySingleton(() => ToggleReceitaAtivoUsecase(sl()));

  sl.registerLazySingleton(() => GetEstoquesUsecase(sl()));
  sl.registerLazySingleton(() => RegistrarEntradaEstoqueUsecase(sl()));
  sl.registerLazySingleton(() => GetMovimentacoesUsecase(sl()));

  sl.registerFactory(
    () => InsumosCubit(
      getInsumosUsecase: sl(),
      createInsumoUsecase: sl(),
      updateInsumoUsecase: sl(),
      deleteInsumoUsecase: sl(),
      toggleInsumoAtivoUsecase: sl(),
    ),
  );
  sl.registerFactory(
    () => ReceitasCubit(
      getReceitasUsecase: sl(),
      createReceitaUsecase: sl(),
      updateReceitaUsecase: sl(),
      deleteReceitaUsecase: sl(),
      toggleReceitaAtivoUsecase: sl(),
    ),
  );
  sl.registerFactory(
    () => EstoquesCubit(
      getEstoques: sl(),
      registrarEntrada: sl(),
      getMovimentacoes: sl(),
    ),
  );
}
