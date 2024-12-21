import 'package:flutter/material.dart';

class AnimatedFlipCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final double size;
  final Color color;

  const AnimatedFlipCounter({
    super.key,
    required this.value,
    required this.duration,
    this.size = 72,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    List<int> digits = value == 0 ? [0] : [];

    int v = value;
    if (v < 0) {
      v *= -1;
    }
    while (v > 0) {
      digits.add(v);
      v = v ~/ 10;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(digits.length, (int i) {
        return SingleDigitFlipCounter(
          key: ValueKey(digits.length - i),
          value: digits[digits.length - i - 1].toDouble(),
          duration: duration,
          height: size,
          width: size / 1.8,
          color: color,
        );
      }),
    );
  }
}

class SingleDigitFlipCounter extends StatelessWidget {
  final double value;
  final Duration duration;
  final double height;
  final double width;
  final Color color;

  const SingleDigitFlipCounter({
    super.key,
    required this.value,
    required this.duration,
    required this.height,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: value, end: value),
      duration: duration,
      builder: (context, value, child) {
        final whole = value ~/ 1;
        final decimal = value - whole;
        return SizedBox(
          height: height,
          width: width * 1.16,
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildSingleDigit(
                digit: whole % 10,
                offset: height * decimal,
                opacity: 1 - decimal,
              ),
              buildSingleDigit(
                digit: (whole + 1) % 10,
                offset: height * decimal - height,
                opacity: decimal,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSingleDigit({int? digit, double? offset, double? opacity}) {
    return Positioned(
      bottom: offset,
      child: SizedBox(
        height: height * 1.16,
        width: width * 1.20,
        child: Opacity(
          opacity: opacity!,
          child: Text(
            "$digit",
            style: TextStyle(
                fontSize: height,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
