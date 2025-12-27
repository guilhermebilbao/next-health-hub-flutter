part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class LoginSubmitted extends LoginEvent {
  final String cpf;
  const LoginSubmitted(this.cpf);
  @override
  List<Object> get props => [cpf];
}

final class LoginCodeSubmitted extends LoginEvent {
  final String cpf;
  final String code;
  const LoginCodeSubmitted({required this.cpf, required this.code});
  @override
  List<Object> get props => [cpf, code];
}
