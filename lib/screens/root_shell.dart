import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../widgets/splash_overlay.dart';

enum _LoadState { loading, loaded, error }

/// Single screen that owns the WebView for the whole app lifetime.
///
/// The WebView is created and starts loading [AppConfig.phpPageUrl]
/// immediately in [initState], at the same time the splash animation
/// starts. When the splash duration elapses, the splash fades out to
/// reveal the already-loading (or already-loaded) WebView — it is never
/// recreated or reloaded. A lightweight spinner is shown only if the page
/// is still loading once the splash is gone.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late final WebViewController _controller;
  late final WebViewWidget _webViewWidget;
  final FocusNode _webViewFocusNode = FocusNode();

  _LoadState _state = _LoadState.loading;
  String _errorMessage = '';
  bool _splashVisible = true;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _splashTimer = Timer(AppConfig.splashDuration, () {
      if (!mounted) return;
      setState(() => _splashVisible = false);
      _webViewFocusNode.requestFocus();
    });
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _state = _LoadState.loading);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _state = _LoadState.loaded);
            if (!_splashVisible) _webViewFocusNode.requestFocus();
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            // Only treat main-frame failures as a full-page error.
            if (error.isForMainFrame == false) return;
            setState(() {
              _state = _LoadState.error;
              _errorMessage = error.description.isNotEmpty
                  ? error.description
                  : 'Failed to load the page.';
            });
          },
          onNavigationRequest: (request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.phpPageUrl));

    // On Android, render the WebView with Hybrid Composition instead of the
    // default texture-based composition, so input (taps, keyboard-on-focus
    // for form fields in the admin panel) behaves like a normal Android
    // WebView rather than relying on synthesized touch events.
    PlatformWebViewWidgetCreationParams widgetParams =
        PlatformWebViewWidgetCreationParams(controller: _controller.platform);
    if (_controller.platform is AndroidWebViewController) {
      final androidController = _controller.platform as AndroidWebViewController;
      widgetParams =
          AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
        widgetParams,
        displayWithHybridComposition: true,
      );
      // Without this, tapping an <input type="file"> upload button on the
      // admin page does nothing: Android's WebView never opens a file
      // chooser unless the host app supplies one.
      androidController.setOnShowFileSelector(_onShowFileSelector);
    }
    _webViewWidget = WebViewWidget.fromPlatformCreationParams(
      params: widgetParams,
    );
  }

  Future<List<String>> _onShowFileSelector(FileSelectorParams params) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: params.mode == FileSelectorMode.openMultiple,
      type: FileType.any,
    );
    final paths = result?.files.map((f) => f.path).whereType<String>() ?? [];
    return paths.map((path) => Uri.file(path).toString()).toList();
  }

  Future<void> _reload() async {
    setState(() {
      _state = _LoadState.loading;
      _errorMessage = '';
    });
    try {
      await _controller.reload();
    } catch (_) {
      await _controller.loadRequest(Uri.parse(AppConfig.phpPageUrl));
    }
  }

  /// Returns true if the app itself should be allowed to close.
  Future<bool> _handleBackPressed() async {
    if (_splashVisible) return false;
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _webViewFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldClose = await _handleBackPressed();
        if (shouldClose) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Stack(
            children: [
              // The WebView is created once in initState and lives for the
              // whole screen lifetime — it is never rebuilt or reloaded
              // when the splash is dismissed.
              Focus(
                focusNode: _webViewFocusNode,
                autofocus: true,
                child: _webViewWidget,
              ),
              if (!_splashVisible && _state == _LoadState.loading)
                const _LoadingOverlay(),
              if (!_splashVisible && _state == _LoadState.error)
                _ErrorOverlay(message: _errorMessage, onReload: _reload),
              AnimatedOpacity(
                opacity: _splashVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: IgnorePointer(
                  ignoring: !_splashVisible,
                  child: const SplashOverlay(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonPink),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message, required this.onReload});

  final String message;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppTheme.neonPurple,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load NexShow Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.isEmpty
                  ? 'Please check your internet connection and try again.'
                  : message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              autofocus: true,
              onPressed: onReload,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }
}
