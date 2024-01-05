import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  String? deepLink;
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        userAgent: Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15'
                ' (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1'
            : 'Mozilla/5.0 (Linux; Android 11; SAMSUNG SM-G973U) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/14.2 Chrome/87.0.4280.141 Mobile Safari/537.36',
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Official InAppWebView website")),
        body: SafeArea(
            child: Column(children: <Widget>[
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.url,
            onSubmitted: (value) {
              var url = Uri.parse(value);
              if (url.scheme.isEmpty) {
                url = Uri.parse("https://www.google.com/search?q=$value");
              }
              webViewController?.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
          Text("Deep Link - $deepLink"),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                      URLRequest(url: Uri.parse("https://www.facebook.com/")),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    controller.addJavaScriptHandler(
                        handlerName: 'vidurl',
                        callback: (tt) {
                          String str = tt.join();
                          str = str.replaceAll('&amp;', '&').toString();
                          deepLink = str;
                          setState(() {});
                        });
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (uri.toString().contains('facebook.com')) {
                      return NavigationActionPolicy.ALLOW;
                    }
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationActionPolicy.CANCEL;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    webViewController?.evaluateJavascript(
                        source:
                            "document.getElementById('login_top_banner').style.display='none'");

                    controller.injectJavascriptFileFromAsset(
                        assetFilePath: "assets/js/fb.js");
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Icon(Icons.arrow_back),
                onPressed: () {
                  webViewController?.goBack();
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.arrow_forward),
                onPressed: () {
                  webViewController?.goForward();
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.refresh),
                onPressed: () {
                  webViewController?.reload();
                },
              ),
            ],
          ),
        ])));
  }
}































// import 'package:flutter/material.dart';
// import 'package:reel_downloader/home_web_page.dart';

// void main() {
//   runApp(const ReelDownloader());
// }

// class ReelDownloader extends StatefulWidget {
//   const ReelDownloader({super.key});

//   @override
//   State<ReelDownloader> createState() => _ReelDownloaderState();
// }

// class _ReelDownloaderState extends State<ReelDownloader> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Reel Downloader',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),//       home: const WebHomePage(),
//     );
//   }
// }
