/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Vazirmatn-FD-Black.ttf
  String get vazirmatnFDBlack => 'assets/fonts/Vazirmatn-FD-Black.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-Bold.ttf
  String get vazirmatnFDBold => 'assets/fonts/Vazirmatn-FD-Bold.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-ExtraBold.ttf
  String get vazirmatnFDExtraBold => 'assets/fonts/Vazirmatn-FD-ExtraBold.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-ExtraLight.ttf
  String get vazirmatnFDExtraLight => 'assets/fonts/Vazirmatn-FD-ExtraLight.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-Light.ttf
  String get vazirmatnFDLight => 'assets/fonts/Vazirmatn-FD-Light.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-Medium.ttf
  String get vazirmatnFDMedium => 'assets/fonts/Vazirmatn-FD-Medium.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-Regular.ttf
  String get vazirmatnFDRegular => 'assets/fonts/Vazirmatn-FD-Regular.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-SemiBold.ttf
  String get vazirmatnFDSemiBold => 'assets/fonts/Vazirmatn-FD-SemiBold.ttf';

  /// File path: assets/fonts/Vazirmatn-FD-Thin.ttf
  String get vazirmatnFDThin => 'assets/fonts/Vazirmatn-FD-Thin.ttf';

  /// List of all assets
  List<String> get values => [
        vazirmatnFDBlack,
        vazirmatnFDBold,
        vazirmatnFDExtraBold,
        vazirmatnFDExtraLight,
        vazirmatnFDLight,
        vazirmatnFDMedium,
        vazirmatnFDRegular,
        vazirmatnFDSemiBold,
        vazirmatnFDThin,
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/icons
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [logo];
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  /// File path: assets/images/icons/Info-Fill.svg
  SvgGenImage get infoFill => const SvgGenImage('assets/images/icons/Info-Fill.svg');

  /// File path: assets/images/icons/search_icon.svg
  SvgGenImage get searchIcon => const SvgGenImage('assets/images/icons/search_icon.svg');

  /// List of all assets
  List<SvgGenImage> get values => [infoFill, searchIcon];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const String omdbKeys = 'assets/omdb_keys.json';

  /// List of all assets
  static List<String> get values => [omdbKeys];
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}}) : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
      : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ?? (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
