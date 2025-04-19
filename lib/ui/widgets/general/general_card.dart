import 'package:economia/ui/themes/neutral_theme.dart';
import 'package:economia/core/utils/shimmer_loading.dart';
import 'package:flutter/material.dart';

class GeneralCard extends StatelessWidget {
  const GeneralCard({
    super.key,
    this.child,
    this.width,
    this.height,
    this.margin,
    this.padding = const EdgeInsets.all(0),
    this.onTap,
    this.onLongPress,
    this.radius = 16,
    this.shadow = false,
    this.backgroundColor,
    this.borderColor,
    this.isShimmerLoading = false,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final double radius;
  final bool shadow;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isShimmerLoading;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: isShimmerLoading,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color:
                  borderColor ??
                  Theme.of(context).cardTheme.shadowColor ??
                  NeutralTheme.grey02,
              width: 2,
            ),
            boxShadow:
                shadow
                    ? [
                      const BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        offset: Offset(2, 2),
                        blurRadius: 8,
                      ),
                    ]
                    : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
