import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // 추가
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonEffect {
  none,
  slime,
}

class ImageButton extends StatefulWidget {
  final String imagePath;
  final double size;
  final VoidCallback? onPressed;
  final Color? fillColor; // 주로 내부 fill 또는 전체 색상
  final Color? strokeColor; // 외곽선 색상
  final double? strokeWidth; // 외곽선 두께
  final String? title; // 추가: 버튼 제목
  final TextStyle? titleStyle; // 추가: 제목 스타일
  final double titleSpacing; // 추가: 제목과 이미지 사이 간격
  final Widget? child;
  final ButtonEffect effect;

  const ImageButton({
    super.key,
    required this.imagePath,
    required this.size,
    this.onPressed,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.title, // 추가
    this.titleStyle, // 추가
    this.titleSpacing = 4.0, // 추가: 기본값 4.0
    this.child,
    this.effect = ButtonEffect.none,
  });

  @override
  State<ImageButton> createState() => _ImageButtonState();
}

// 버튼 효과 관리를 위한 static 클래스
class SlimeEffectManager {
  static final List<_ImageButtonState> _buttons = [];
  static Timer? _globalTimer;
  static _ImageButtonState? _currentAnimatingButton;

  static void registerButton(_ImageButtonState button) {
    if (!_buttons.contains(button)) {
      _buttons.add(button);
    }
    if (_buttons.length == 1) {
      _startGlobalTimer();
    }
  }

  static void unregisterButton(_ImageButtonState button) {
    _buttons.remove(button);
    if (_currentAnimatingButton == button) {
      _currentAnimatingButton = null;
    }
    if (_buttons.isEmpty) {
      _globalTimer?.cancel();
      _globalTimer = null;
    }
  }

  static void _startGlobalTimer() {
    _globalTimer?.cancel();
    _scheduleNextEffect();
  }

  static void _scheduleNextEffect() {
    if (_buttons.isEmpty) return;

    // 8~15초 후에 다음 효과 실행 (기존 3~6초에서 증가)
    _globalTimer = Timer(
      Duration(milliseconds: 8000 + math.Random().nextInt(7000)),
      () {
        if (_buttons.isEmpty) return;

        // 현재 애니메이팅 중인 버튼을 제외한 버튼들 중에서 선택
        final availableButtons =
            _buttons.where((b) => b != _currentAnimatingButton).toList();
        if (availableButtons.isEmpty) return;

        // 랜덤하게 버튼 선택
        final randomButton =
            availableButtons[math.Random().nextInt(availableButtons.length)];
        _currentAnimatingButton = randomButton;
        randomButton._playSlimeAnimation();

        // 다음 효과 예약
        _scheduleNextEffect();
      },
    );
  }
}

class _ImageButtonState extends State<ImageButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _effectController;
  Animation<double>? _scale;
  bool _isPressed = false;

  // SVG 문자열을 로드하고 수정하는 Future를 저장할 변수
  Future<String>? _processedSvgFuture;
  Timer? _effectTimer;
  bool _isAnimating = false;

  // 슬라임 효과 애니메이션을 위한 TweenSequence
  Animation<double>? _slimeScaleXAnimation;
  Animation<double>? _slimeScaleYAnimation;
  Animation<double>? _slimeTranslateYAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _effectController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _setupSlimeAnimation();
    _updateSvgFuture();

    // 슬라임 효과가 있는 버튼만 등록
    if (widget.effect == ButtonEffect.slime) {
      SlimeEffectManager.registerButton(this);
    }
  }

  @override
  void didUpdateWidget(covariant ImageButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath ||
        widget.strokeWidth != oldWidget.strokeWidth ||
        widget.strokeColor != oldWidget.strokeColor) {
      _updateSvgFuture();
    }

    // effect 설정이 변경되었을 때 처리
    if (widget.effect != oldWidget.effect) {
      if (widget.effect == ButtonEffect.slime) {
        SlimeEffectManager.registerButton(this);
      } else {
        SlimeEffectManager.unregisterButton(this);
        _effectController.stop();
        setState(() => _isAnimating = false);
      }
    }
  }

  void _playSlimeAnimation() {
    if (!mounted) return;
    setState(() => _isAnimating = true);

    _effectController
      ..reset()
      ..forward().then((_) {
        _effectController.reverse().then((_) {
          if (mounted) {
            setState(() => _isAnimating = false);
          }
        });
      });
  }

  void _updateSvgFuture() {
    if (widget.imagePath.toLowerCase().endsWith('.svg')) {
      // strokeWidth나 strokeColor가 지정된 경우에만 SVG 처리
      if (widget.strokeWidth != null || widget.strokeColor != null) {
        setState(() {
          _processedSvgFuture = _loadAndModifySvg(
            widget.imagePath,
            widget.strokeWidth,
            widget.strokeColor,
            widget.fillColor,
          );
        });
      } else {
        // stroke 관련 파라미터가 없으면 처리 없이 로드만 (혹은 기존 방식 유지)
        // 여기서는 간단하게 null 처리하여 FutureBuilder가 기본 SvgPicture.asset을 사용하도록 유도 가능
        // 또는 아래 _buildImage에서 분기 처리
        setState(() {
          _processedSvgFuture = null; // 처리할 필요 없음 표시
        });
      }
    } else {
      setState(() {
        _processedSvgFuture = null; // SVG 아니면 null
      });
    }
  }

  // SVG 문자열을 로드하고 stroke 관련 속성을 수정하는 함수
  Future<String> _loadAndModifySvg(String assetName, double? strokeWidth,
      Color? strokeColor, Color? fillColor) async {
    String svgString = await rootBundle.loadString(assetName);

    // stroke-width 수정 (제공된 경우)
    if (strokeWidth != null) {
      // 주의: 단순 문자열 치환은 복잡한 SVG에서 문제를 일으킬 수 있음. XML 파서 사용이 더 안전.
      svgString = svgString.replaceAllMapped(
        RegExp(r'stroke-width="([^"]+)"'), // 기존 stroke-width 값 찾기
        (match) => 'stroke-width="$strokeWidth"', // 새 값으로 변경
      );
    }

    // stroke 색상 수정 (제공된 경우)
    if (strokeColor != null) {
      final colorHex =
          '#${strokeColor.value.toRadixString(16).substring(2).toUpperCase()}';
      svgString = svgString
          .replaceAllMapped(RegExp(r'stroke="([^"]+)"'), // 기존 stroke 값 찾기
              (match) {
        // currentColor인 경우 등 특정 조건에서만 변경하거나, 무조건 덮어쓸 수 있음
        return 'stroke="$colorHex"'; // 새 색상으로 변경
      });
      // 만약 stroke 속성이 없다면 추가하는 로직도 필요할 수 있음
    }

    if (fillColor != null) {
      final colorHex =
          '#${fillColor.value.toRadixString(16).substring(2).toUpperCase()}';
      svgString =
          svgString.replaceAllMapped(RegExp(r'fill="([^"]+)"'), // 기존 fill 값 찾기
              (match) {
        // currentColor인 경우 등 특정 조건에서만 변경하거나, 무조건 덮어쓸 수 있음
        return 'fill="$colorHex"'; // 새 색상으로 변경
      });
      // 만약 fill 속성이 없다면 추가하는 로직도 필요할 수 있음
    }

    return svgString;
  }

  @override
  void dispose() {
    SlimeEffectManager.unregisterButton(this);
    _controller.dispose();
    _effectController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed) {
      _isPressed = true;
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      _isPressed = false;
      _controller.reverse().then((_) {
        // 애니메이션 완료 후 콜백 호출 (선택적)
        if (mounted) {
          // 위젯이 여전히 마운트 상태인지 확인
          widget.onPressed?.call();
        }
      });
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      _isPressed = false;
      _controller.reverse();
    }
  }

  Widget _buildImage() {
    final isSvg = widget.imagePath.toLowerCase().endsWith('.svg');

    if (!isSvg) {
      // 기존 비-SVG 이미지 처리
      return Image.asset(
        widget.imagePath,
        width: widget.size,
        height: widget.size,
        color: widget.fillColor, // 비-SVG는 stroke 개념이 없으므로 기존 color만 적용
      );
    }

    // SVG 처리
    // strokeWidth나 strokeColor가 지정되어 처리된 SVG Future가 있는지 확인
    if (_processedSvgFuture != null) {
      return FutureBuilder<String>(
        future: _processedSvgFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            // SVG 문자열 로드 및 수정 완료
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: Padding(
                padding: EdgeInsets.all(widget.size * 0.2),
                child: SvgPicture.string(
                  snapshot.data!, // 수정된 SVG 문자열 사용
                  // colorFilter는 widget.color (주로 fill 용도)를 위해 남겨둘 수 있음
                  // strokeColor는 SVG 문자열 자체에 적용했으므로 여기서 다시 적용할 필요 없음
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // 오류 처리
            print('Error loading/processing SVG: ${snapshot.error}');
            return SizedBox(
                width: widget.size,
                height: widget.size,
                child: Icon(Icons.error, size: widget.size * 0.6));
          } else {
            // 로딩 중 표시
            return SizedBox(
                width: widget.size,
                height: widget.size,
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 2.0)));
          }
        },
      );
    } else {
      // strokeWidth나 strokeColor가 지정되지 않은 경우, 기존 방식 사용
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Padding(
          padding: EdgeInsets.all(widget.size * 0.2),
          child: SvgPicture.asset(
            widget.imagePath,
            // colorFilter는 여전히 widget.color 우선 적용
            colorFilter: widget.fillColor != null
                ? ColorFilter.mode(widget.fillColor!, BlendMode.srcIn)
                : null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = GoogleFonts.fredoka(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: widget.size * 0.25,
        fontWeight: FontWeight.bold,
        height: 0.9,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );

    Widget content = ScaleTransition(
      scale: _scale ?? AlwaysStoppedAnimation(1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height:
                widget.size + (widget.child != null ? widget.size * 0.3 : 0),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                _buildImage(),
                if (widget.child != null) ...[
                  Positioned(
                    bottom: 5,
                    child: widget.child!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.title != null) ...[
            SizedBox(height: widget.titleSpacing),
            Stack(
              children: [
                Text(
                  widget.title!,
                  textAlign: TextAlign.center,
                  style: (widget.titleStyle ?? defaultTitleStyle).copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.black.withOpacity(0.8),
                    shadows: [],
                  ),
                ),
                Text(
                  widget.title!,
                  textAlign: TextAlign.center,
                  style: widget.titleStyle ?? defaultTitleStyle,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    // 슬라임 효과 애니메이션 적용
    if (_isAnimating && widget.effect == ButtonEffect.slime) {
      content = AnimatedBuilder(
        animation: _effectController,
        builder: (context, child) {
          return Transform.translate(
            offset:
                Offset(0, _slimeTranslateYAnimation?.value ?? 0), // null 체크 추가
            child: Transform.scale(
              scaleX: _slimeScaleXAnimation?.value ?? 1.0, // null 체크 추가
              scaleY: _slimeScaleYAnimation?.value ?? 1.0, // null 체크 추가
              child: child,
            ),
          );
        },
        child: content,
      );
    }

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }

  // 슬라임 애니메이션을 위한 TweenSequence 설정 함수
  void _setupSlimeAnimation() {
    _slimeScaleXAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween(begin: 1.0, end: 1.2), weight: 25), // 더 큰 스케일로 변경
      TweenSequenceItem<double>(tween: Tween(begin: 1.2, end: 0.8), weight: 25),
      TweenSequenceItem<double>(tween: Tween(begin: 0.8, end: 1.1), weight: 25),
      TweenSequenceItem<double>(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _effectController,
      curve: Curves.easeInOut,
    ));

    _slimeScaleYAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween(begin: 1.0, end: 0.8), weight: 25),
      TweenSequenceItem<double>(tween: Tween(begin: 0.8, end: 1.2), weight: 25),
      TweenSequenceItem<double>(tween: Tween(begin: 1.2, end: 0.9), weight: 25),
      TweenSequenceItem<double>(tween: Tween(begin: 0.9, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _effectController,
      curve: Curves.easeInOut,
    ));

    _slimeTranslateYAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: 15.0), weight: 25), // 더 큰 움직임
      TweenSequenceItem<double>(
          tween: Tween(begin: 15.0, end: -15.0), weight: 25),
      TweenSequenceItem<double>(
          tween: Tween(begin: -15.0, end: 8.0), weight: 25),
      TweenSequenceItem<double>(tween: Tween(begin: 8.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _effectController,
      curve: Curves.easeInOut,
    ));
  }
}
