import 'package:flutter/material.dart';

//TODO: migliorare lo stato dei primi pulsanti
/*TIP I pulsanti iniziali si disabilitano quando appare il messaggio successivo
perché sono degli stateless widget
e cambiano stato solo quando si refresha il resto dell'app
*/
class PromptButton extends StatelessWidget {
  final bool disablePreviousButtons;
  final VoidCallback? onPressed;
  final Widget child;

  const PromptButton(
      {super.key,
      this.disablePreviousButtons = false,
      required this.onPressed,
      this.child = const Text('')});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disablePreviousButtons ? onPressed : null,
      child: child,
    );
  }
}
