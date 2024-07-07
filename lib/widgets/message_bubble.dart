import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = isUser
        ? const [
            Color(0xFFddb39a),
            Color.fromARGB(255, 238, 217, 141),
          ]
        : const [
            Color(0xff9ba9ff),
            Color(0xFF00CCFF),
          ];

    final linearGradientStops = [0.2, 1.0];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: linearGradientStops,
            tileMode: TileMode.clamp),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20.0),
          topRight: const Radius.circular(20.0),
          bottomLeft:
              isUser ? const Radius.circular(20.0) : const Radius.circular(0),
          bottomRight:
              isUser ? const Radius.circular(0) : const Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          // color: isUser ? Colors.white : Colors.black,
          color: Colors.black,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
