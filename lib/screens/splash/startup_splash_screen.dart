import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/widgets/mc_logo.dart';

class StartupSplashScreen extends StatefulWidget {
  final Widget child;

  const StartupSplashScreen({
    super.key,
    required this.child,
  });

  @override
  State<StartupSplashScreen> createState() => _StartupSplashScreenState();
}

class _StartupSplashScreenState extends State<StartupSplashScreen> {
  late final VideoPlayerController _controller;
  Timer? _fallbackTimer;
  bool _showApp = false;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash.mp4');
    _controller.addListener(_handlePlaybackTick);
    _fallbackTimer = Timer(const Duration(seconds: 12), _finishSplash);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.setVolume(0);
      await _controller.play();
      if (!mounted) return;
      setState(() => _videoReady = true);
    } catch (_) {
      // Video failed to load — show fallback brand screen for 5 seconds
      _fallbackTimer?.cancel();
      _fallbackTimer = Timer(const Duration(seconds: 5), _finishSplash);
    }
  }

  void _handlePlaybackTick() {
    final value = _controller.value;
    if (!value.isInitialized || _showApp) return;

    final remaining = value.duration - value.position;
    if (remaining <= const Duration(milliseconds: 120)) {
      _finishSplash();
    }
  }

  void _finishSplash() {
    if (_showApp) return;
    _fallbackTimer?.cancel();
    if (!mounted) return;
    setState(() => _showApp = true);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller
      ..removeListener(_handlePlaybackTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showApp) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _finishSplash,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_videoReady)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: _controller.value.size.width == 0
                        ? 9
                        : _controller.value.size.width,
                    height: _controller.value.size.height == 0
                        ? 16
                        : _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              const _SplashFallback(),
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Text(
                'Tap to skip',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashFallback extends StatelessWidget {
  const _SplashFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF06111F),
            Color(0xFF13253F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            McLogo(
              size: 108,
              borderRadius: 26,
              withShadow: true,
            ),
            SizedBox(height: 18),
            Text(
              'NSSON Moto Crafter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
