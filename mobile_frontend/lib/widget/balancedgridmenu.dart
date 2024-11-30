import 'package:flutter/material.dart';

class BalancedGridView extends StatelessWidget {
  const BalancedGridView(
      {Key? key, required this.children, required this.columnCount})
      : super(key: key);

  final List<Widget> children;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length ~/ columnCount + 1; i++)
          Row(
            children: [
              for (int j = 0; j < columnCount; j++)
                Expanded(
                  child: () {
                    final index = i * columnCount + j;
                    if (index >= children.length) {
                      return const SizedBox();
                    } else {
                      return children[index];
                    }
                  }(),
                )
            ],
          )
      ],
    );
  }
}
