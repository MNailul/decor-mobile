import 'package:flutter/material.dart';

class AnimatedWishlistButton extends StatefulWidget {
  final bool initialIsLiked;
  final Function(bool isLiked) onChanged;
  final double size;

  const AnimatedWishlistButton({
    super.key,
    this.initialIsLiked = false,
    required this.onChanged,
    this.size = 24.0,
  });

  @override
  State<AnimatedWishlistButton> createState() => _AnimatedWishlistButtonState();
}

class _AnimatedWishlistButtonState extends State<AnimatedWishlistButton>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Colors from the brand palette
  static const Color _activeColor = Color(0xFFB5733A);
  static const Color _inactiveColor = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedWishlistButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsLiked != oldWidget.initialIsLiked) {
      setState(() {
        _isLiked = widget.initialIsLiked;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      _controller.forward(from: 0.0);
    }

    widget.onChanged(_isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ripple Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: _activeColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Icon with smooth transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(_isLiked),
              color: _isLiked ? _activeColor : _inactiveColor,
              size: widget.size,
            ),
          ),
        ],
      ),
    );
  }
}
