import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final int empresaId;
  final String? nome;
  final String email;

  const AuthUser({
    required this.id,
    required this.empresaId,
    this.nome,
    required this.email,
  });

  @override
  List<Object?> get props => [id, empresaId, nome, email];
}
