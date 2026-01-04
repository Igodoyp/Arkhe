import 'package:flutter/material.dart';
import '../../../../core/haptic/haptic_service.dart';

/// Botón con micro-animaciones y haptic feedback
/// 
/// Características:
/// - Scale down al presionar
/// - Haptic feedback automático
/// - Elevation animation
/// - Color splash effect
class JuicyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enableHaptic;
  final double scaleDownFactor;

  const JuicyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 4,
    this.padding,
    this.borderRadius,
    this.enableHaptic = true,
    this.scaleDownFactor = 0.95,
  });

  @override
  State<JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<JuicyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 4,
      end: (widget.elevation ?? 4) / 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      HapticService.light();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      // onTap is handled by InkWell to enable splash effect
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              color: widget.backgroundColor ?? Theme.of(context).primaryColor,
              child: InkWell(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                onTap: widget.onPressed, // Pass callback here
                child: Container(
                  padding: widget.padding ??
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: widget.foregroundColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    child: child!,
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Card con animación de hover y tap
/// 
/// Características:
/// - Lift up al hacer hover (desktop/web)
/// - Scale down al presionar
/// - Haptic feedback
/// - Smooth shadows
class JuicyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool enableHaptic;
  final double? elevation;

  const JuicyCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.enableHaptic = true,
    this.elevation = 2,
  });

  @override
  State<JuicyCard> createState() => _JuicyCardState();
}

class _JuicyCardState extends State<JuicyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      HapticService.light();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final baseElevation = widget.elevation ?? 2;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        // onTap is handled by InkWell
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: widget.margin ?? EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.white,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: _isHovering ? (baseElevation * 4) : (baseElevation * 2),
                      offset: Offset(0, _isHovering ? (baseElevation + 2) : baseElevation),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    onTap: widget.onTap, // Pass callback here
                    child: Container(
                      padding: widget.padding ?? const EdgeInsets.all(16),
                      child: child!,
                    ),
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// IconButton con animación de bounce
class BounceIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final bool enableHaptic;

  const BounceIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.enableHaptic = true,
  });

  @override
  State<BounceIconButton> createState() => _BounceIconButtonState();
}

class _BounceIconButtonState extends State<BounceIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.1),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticService.light();
    }
    _controller.forward(from: 0.0);
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed != null ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.icon,
              color: widget.color ?? Theme.of(context).iconTheme.color,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

/// Animación de rotación para botón de refresh
class RotatingRefreshButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final double size;

  const RotatingRefreshButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.size = 24,
  });

  @override
  State<RotatingRefreshButton> createState() => _RotatingRefreshButtonState();
}

class _RotatingRefreshButtonState extends State<RotatingRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RotatingRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : () {
        HapticService.light();
        widget.onPressed?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: Icon(
              Icons.refresh,
              color: widget.color ?? Theme.of(context).iconTheme.color,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}
