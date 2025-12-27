import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/app_formatters.dart';
import '../data/auth_service.dart';
import 'viewmodel/login_bloc.dart';
import '../../components/app_button.dart';
import 'widgets/two_factor_auth_dialog.dart';
import '../../app_routes.dart';

class LoginPatientScreen extends StatelessWidget {
  const LoginPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authService: AuthService()),
      child: const LoginPatientView(),
    );
  }
}

class LoginPatientView extends StatefulWidget {
  const LoginPatientView({super.key});

  @override
  State<LoginPatientView> createState() => _LoginPatientViewState();
}

class _LoginPatientViewState extends State<LoginPatientView> {
  final _formKey = GlobalKey<FormState>();

  final _cpfFormatter = AppFormatters.cpf;

  final TextEditingController _cpfController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(LoginSubmitted(_cpfController.text));
    }
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => TwoFactorAuthDialog(
        onVerified: (code) {
          Navigator.of(dialogContext).pop();
          // Agora passamos o CPF e o Código
          context.read<LoginBloc>().add(
            LoginCodeSubmitted(
              cpf: _cpfController.text,
              code: code,
            ),
          );
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const logoImage = 'assets/images/next_health_logo.png';

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            _showTwoFactorDialog();
          } else if (state is LoginVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código validado com sucesso! Redirecionando...'),
                backgroundColor: Color.fromRGBO(27, 106, 123, 1),
              ),
            );
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            if (state.message == 'Código incorreto. Tente novamente.') {
              _showTwoFactorDialog();
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        logoImage,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Login do Paciente',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Digite seu CPF para acessar seus exames',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _cpfController,
                        inputFormatters: [_cpfFormatter],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          hintText: '000.000.000-00',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o CPF';
                          }
                          if (_cpfFormatter.getUnmaskedText().length != 11) {
                            return 'CPF inválido. Digite 11 números.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          final isLoading = state is LoginLoading;
                          return AppButton(
                            text: 'Entrar',
                            onPressed: _handleLogin,
                            isLoading: isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Seus dados estão protegidos e criptografados',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
