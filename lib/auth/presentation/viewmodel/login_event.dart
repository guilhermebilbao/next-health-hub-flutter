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
  final String code;
  const LoginCodeSubmitted(this.code);
  @override
  List<Object> get props => [code];
}
