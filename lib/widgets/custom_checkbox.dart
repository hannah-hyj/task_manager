import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.size = 24.0,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final double size;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = widget.activeColor ?? theme.colorScheme.primary;

    return Semantics(
      checked: widget.value,
      label: widget.value ? 'Mark incomplete' : 'Mark complete',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onChanged != null
              ? () => widget.onChanged!(!widget.value)
              : null,
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.value ? primary : Colors.transparent,
                      border: Border.all(
                        color: widget.value
                            ? primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.35,
                              ),
                        width: 2,
                      ),
                      boxShadow: widget.value
                          ? <BoxShadow>[
                              BoxShadow(
                                color: primary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: widget.value
                        ? Icon(
                            Icons.check_rounded,
                            size: widget.size * 0.7,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
