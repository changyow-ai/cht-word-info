import SwiftUI
import WebKit

struct DictWebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .onDrag
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let target = navigationAction.request.url else {
                decisionHandler(.cancel); return
            }

            // about:blank and data: are fine for in-page rendering
            if target.scheme == "about" || target.scheme == "data" {
                decisionHandler(.allow); return
            }

            if DictURL.isAllowed(target) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
                // Hand off external links to Safari
                if UIApplication.shared.canOpenURL(target) {
                    UIApplication.shared.open(target)
                }
            }
        }
    }
}
