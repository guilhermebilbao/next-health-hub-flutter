import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;

  LoginBloc({required AuthService authService}) 
      : _authService = authService,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await _authService.loginPatient(event.cpf);
      emit(LoginSuccess());
    } catch (e) {
      // Remove "Exception: " prefix if present for cleaner UI
      final message = e.toString().replaceAll('Exception: ', '');
      emit(LoginFailure(message));
    }
  }
}
