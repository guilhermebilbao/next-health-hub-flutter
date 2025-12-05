import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TwoFactorAuthDialog extends StatefulWidget {
  final Function(String) onVerified;
  final VoidCallback? onCancel;

  const TwoFactorAuthDialog({
    super.key,
    required this.onVerified,
    this.onCancel,
  });

  @override
  State<TwoFactorAuthDialog> createState() => _TwoFactorAuthDialogState();
}

class _TwoFactorAuthDialogState extends State<TwoFactorAuthDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  static const int _codeLength = 4;
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
          const Text(
            'Digite o código de 4 dígitos enviado para seu email g**********ao@g****.com',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              // Visual boxes
              Row(
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
                      isFilled ? code[index] : '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _themeColor,
                      ),
                    ),
                  );
                }),
              ),
              // Invisible TextField
              Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: _codeLength,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {});
                    if (value.length == _codeLength) {
                      widget.onVerified(value);
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
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text('Novo código enviado ao seu email cadastrado'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        //TODO acionar o API de reenvio de codigo pra email
                       // Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text(
            'Não recebi código',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],

    );
  }
}
