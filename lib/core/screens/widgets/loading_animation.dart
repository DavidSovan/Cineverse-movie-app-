import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  final String? message;
  final Color? primaryColor;
  final Color? backgroundColor;
  final LoadingStyle style;
  final double size;
  final bool showPulseEffect;

  const LoadingAnimation({
    Key? key,
    this.message,
    this.primaryColor,
    this.backgroundColor,
    this.style = LoadingStyle.modern,
    this.size = 60.0,
    this.showPulseEffect = true,
  }) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

enum LoadingStyle {
  modern,
  minimal,
  elegant,
  pulsing,
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for spinner
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Pulse animation for background
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _rotationController.repeat();
    if (widget.showPulseEffect) {
      _pulseController.repeat(reverse: true);
    }
    _fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;
    final backgroundColor =
        widget.backgroundColor ?? theme.scaffoldBackgroundColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingIndicator(primaryColor, backgroundColor),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            _buildLoadingText(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color primaryColor, Color backgroundColor) {
    switch (widget.style) {
      case LoadingStyle.modern:
        return _buildModernSpinner(primaryColor);
      case LoadingStyle.minimal:
        return _buildMinimalSpinner(primaryColor);
      case LoadingStyle.elegant:
        return _buildElegantSpinner(primaryColor, backgroundColor);
      case LoadingStyle.pulsing:
        return _buildPulsingSpinner(primaryColor);
    }
  }

  Widget _buildModernSpinner(Color primaryColor) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.1),
                  primaryColor.withValues(alpha: 0.3),
                  primaryColor,
                  primaryColor.withValues(alpha: 0.1),
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalSpinner(Color primaryColor) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        backgroundColor: primaryColor.withValues(alpha: 0.1),
        strokeCap: StrokeCap.round,
      ),
    );
  }

  Widget _buildElegantSpinner(Color primaryColor, Color backgroundColor) {
    return AnimatedBuilder(
      animation:
          widget.showPulseEffect ? _pulseController : _rotationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.showPulseEffect ? _pulseAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              strokeCap: StrokeCap.round,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingSpinner(Color primaryColor) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing circle
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: widget.size + 20,
                height: widget.size + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Inner spinner
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeCap: StrokeCap.round,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingText(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

// Usage examples:
class LoadingExamples extends StatelessWidget {
  const LoadingExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Animations')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Modern style
            SizedBox(height: 100),
            LoadingAnimation(
              message: 'Loading your data...',
              style: LoadingStyle.modern,
              primaryColor: Colors.blue,
            ),

            SizedBox(height: 60),

            // Elegant style with pulse
            LoadingAnimation(
              message: 'Please wait',
              style: LoadingStyle.elegant,
              primaryColor: Colors.purple,
              showPulseEffect: true,
            ),

            SizedBox(height: 60),

            // Minimal style
            LoadingAnimation(
              message: 'Processing...',
              style: LoadingStyle.minimal,
              primaryColor: Colors.green,
              size: 40,
            ),

            SizedBox(height: 60),

            // Pulsing style
            LoadingAnimation(
              message: 'Almost there!',
              style: LoadingStyle.pulsing,
              primaryColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
