import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/auth_service.dart';

class TwoFactorAuthDialog extends StatefulWidget {
  final Function(String) onVerified;
  final VoidCallback? onCancel;
  final String emailMasked;
  final String cpf;

  const TwoFactorAuthDialog({
    super.key,
    required this.onVerified,
    required this.emailMasked,
    required this.cpf,
    this.onCancel,
  });

  @override
  State<TwoFactorAuthDialog> createState() => _TwoFactorAuthDialogState();
}

class _TwoFactorAuthDialogState extends State<TwoFactorAuthDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AuthService _authService = AuthService(); // <--- 3. Instancie o serviço
  bool _isLoading = false; // Para feedback visual ao usuário
  static const int _codeLength = 6;
  static const Color _themeColor = Color.fromRGBO(27, 106, 123, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);
    try {
      await _authService.loginPatient(widget.cpf);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: _themeColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Código Enviado!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _themeColor,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Um novo código de acesso foi enviado para o e-mail:\n'),
                    TextSpan(
                      text: widget.emailMasked,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _themeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao reenviar código: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Verificação em Duas Etapas',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _themeColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Digite o código enviado para seu email  ${widget.emailMasked}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              // Visual boxes
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_codeLength, (index) {
                    final code = _controller.text;
                    final isFilled = index < code.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 35,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFilled ? _themeColor : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isFilled ? code[index].toUpperCase() : '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _themeColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Invisible TextField
              Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.text,
                  maxLength: _codeLength,
                  enableInteractiveSelection: false,
                  contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                  onChanged: (value) {
                    setState(() {});
                    if (value.length == _codeLength) {
                      widget.onVerified(value.toUpperCase());
                    }
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  showCursor: false,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleResendCode,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Text(
            'Gerar novo código',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
