import 'package:flutter/material.dart';

class ReactionStack extends StatelessWidget {
  final List<String> reactions;

  const ReactionStack({super.key, required this.reactions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // constrain height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reactions.length,
        itemBuilder: (context, index) {
          return Transform.translate(
            offset: Offset(index * -10, 0), // overlap amount
            child: CircleAvatar(radius: 18, child: Text(reactions[index])),
          );
        },
      ),
    );
  }
}
