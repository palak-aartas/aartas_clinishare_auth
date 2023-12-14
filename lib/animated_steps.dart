import 'package:connect_design_system/components/misc/colors.dart';
import 'package:connect_design_system/components/misc/responsive.dart';
import 'package:flutter/material.dart';

class AnimatedSteps extends StatefulWidget {
  final double current, steps;
  final double? height;
  final BorderRadius? borderRadius;
  const AnimatedSteps({
    super.key,
    required this.current,
    required this.steps,
    this.height,
    this.borderRadius,
  });

  @override
  State<AnimatedSteps> createState() => _AnimatedStepsState();
}

class _AnimatedStepsState extends State<AnimatedSteps> {
  GlobalKey key = GlobalKey();
  double? width;
  @override
  void initState() {
    getWidth();
    super.initState();
  }

  getWidth() {
    if (widget.current < 0 || widget.steps < 0) {
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(duration, () {
          width = key.currentContext!.size!.width;
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // log("$width - ${widget.current < 0} - ${widget.steps}");
    if (widget.current < 0 || widget.steps < 0) {
      return const SizedBox();
    }
    return SizedBox(
      height: widget.height != null ? widget.height! : defaultPadding / 2,
      width: double.infinity,
      child: Stack(
        key: key,
        alignment: Alignment.centerLeft,
        children: [
          AnimatedContainer(
            duration: duration * 5,
            curve: curve,
            height: widget.height != null ? widget.height! : defaultPadding / 2,
            width: width != null && widget.current != 0 ? width! : 0,
            decoration: BoxDecoration(
              color: width != null ? seaShellColor : Colors.transparent,
              borderRadius: widget.borderRadius != null
                  ? widget.borderRadius!
                  : BorderRadius.circular(defaultPadding / 2),
            ),
          ),
          AnimatedContainer(
            duration: duration * 3,
            curve: curve,
            height: widget.height != null ? widget.height! : defaultPadding / 2,
            width: width != null && widget.current != 0
                ? (width! * (widget.current / widget.steps))
                : 0,
            decoration: BoxDecoration(
              color: width != null
                  ? textTheme(context).titleSmall!.color
                  : Colors.transparent,
              borderRadius: widget.borderRadius != null
                  ? widget.borderRadius!
                  : BorderRadius.circular(defaultPadding / 2),
            ),
          ),
        ],
      ),
    );
  }
}
