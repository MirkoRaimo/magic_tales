import 'package:flutter/material.dart';
import 'package:magic_tales/widgets/bubble_painter.dart';
import 'package:magic_tales/widgets/message_bubble.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  final Image? image;
  final String? text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            // constraints: const BoxConstraints(maxWidth: 520),
            // decoration: BoxDecoration(
            //   color: isFromUser
            //       ? Theme.of(context).colorScheme.primaryContainer
            //       : Theme.of(context).colorScheme.surfaceContainerHighest,
            //   borderRadius: BorderRadius.circular(18),
            // ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                // if (text case final text?) MarkdownBody(data: text),
                // if (text case final text?) SelectableText(text),
                if (text case final text?)
                  MessageBubble(message: text, isUser: isFromUser),
                // if (text case final text?) buildSpeechBubble(text),
                if (image case final image?) image,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSpeechBubble(String text) {
    return CustomPaint(
      painter: BubblePainter(color: Colors.purple.shade200),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        child: SelectableText(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
