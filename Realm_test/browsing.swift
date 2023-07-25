//
//  browsing.swift
//  Realm_test
//
//  Created by x19048xx on 2023/07/13.
//

import Foundation
import SwiftUI
import RealmSwift
import WebKit

struct browsingView: View {
    @State private var showNoteView = false
    @State private var hideNavBar = false // ナビゲーションバーを非表示にするかどうかを管理するための State

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                WebView(url: URL(string: "https://www.google.com")!)
                
                if showNoteView {
                    webNoteView(isPresented: $showNoteView)
                        .frame(height: 240) // frameの高さを調整
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationBarItems(trailing: Button(action: {
                withAnimation {
                    showNoteView.toggle()
                    hideNavBar = showNoteView // メモを開くときはナビゲーションバーを非表示にし、閉じるときは表示する
                }
            }) {
                Text(showNoteView ? "メモを隠す" : "メモを開く")
                    
            })
            .navigationBarHidden(hideNavBar) // hideNavBarの値に基づいてナビゲーションバーを非表示にする
        }
    }
}


    
    struct webNoteView: View {
        @Binding var isPresented: Bool
        @State private var webword: String = ""
        @State private var webDescription: String = ""
        @State private var webtag: String = ""

        func save(note: Note) {
            let realm = try! Realm()

            try! realm.write {
                realm.add(note)
            }
        }

        var body: some View {
            VStack {
                TextField("Enter word here...", text: $webword)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                TextEditor(text: $webDescription)
                    .padding()
                    .frame(height: 50)
                    .border(Color.gray, width: 1)

                TextField("Enter tag here...", text: $webtag)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button("保存") {
                    if !webword.isEmpty && !webDescription.isEmpty && !webtag.isEmpty {
                        save(note: Note(word: webword, noteDescription: webDescription, tag: webtag))
                        webword = ""
                        webDescription = ""
                        webtag = ""
                        isPresented = false
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
        }
    }
    
    
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // UIViewの状態を更新するために使用します。
    }
}
