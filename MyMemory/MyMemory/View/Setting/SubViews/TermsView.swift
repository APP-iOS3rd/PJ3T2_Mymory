//
//  TermsView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/14/24.
//

import SwiftUI
import WebKit

enum KindOfTerms: String {
    case use = "use"
    case privacy = "privacy"
}

struct TermsView: View {
    var kindOfTerms: KindOfTerms
    var body: some View {
        VStack {
            switch kindOfTerms {
            case .use:
                TermsWebView(urlToLoad: "https://lucky-sycamore-c73.notion.site/af168c49a93b4fa48830d5bc0512dcb5")
            case .privacy:
                TermsWebView(urlToLoad: "https://lucky-sycamore-c73.notion.site/12bd694d0a774d2f9c167eb4e7976876")
            }
        }
        .customNavigationBar(
            centerView: {
                switch kindOfTerms {
                case .use:
                    Text("이용약관")
                case .privacy:
                    Text("개인정보 처리방침")
                }
            },
            leftView: {
                BackButton()
            },
            rightView: {
              EmptyView()
            },
            backgroundColor: .bgColor3
        )
    }
}

#Preview {
    TermsView(kindOfTerms: .use)
}

struct TermsWebView: UIViewRepresentable {
    var urlToLoad: String
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.urlToLoad) else {
            return WKWebView()
        }
        
        let webView = WKWebView()
        
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<TermsWebView>) {
        
    }
}
