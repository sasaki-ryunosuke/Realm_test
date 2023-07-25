//
//  ContentView.swift
//  Realm_test
//
//  Created by x19048xx on 2023/06/15.
//

import SwiftUI
import RealmSwift
import WebKit

class Note: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var word: String = ""
    @Persisted var noteDescription: String = "" // `description`を`noteDescription`に変更
    @Persisted var tag: String = ""

    // 初期化方法を追加
    convenience init(word: String, noteDescription: String, tag: String) {
        self.init()
        self.word = word
        self.noteDescription = noteDescription
        self.tag = tag
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}




struct HomeView: View {
    var body: some View {
        TabView {
            NoteView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("Create Note")
                }
            
            NotesListView()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("View Notes")
                }
            
            QuizView()
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Play Quiz")
                }

            protQuizView()
                .tabItem {
                    Image(systemName: "4.square.fill")
                    Text("開発中")
                }

            browsingView()
                .tabItem {
                    Image(systemName: "5.square.fill")
                    Text("ブラウザ")
                }
        }
    }
}
    
    
    
    struct NoteView: View {
        @State private var word: String = ""
        @State private var description: String = ""
        @State private var tag: String = ""
        
        func save(note: Note) {
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(note)
            }
        }
        
        var body: some View {
            NavigationView {
                VStack {
                    TextField("Enter word here...", text: $word)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    TextEditor(text: $description)
                        .padding()
                        .frame(height: 200)
                        .border(Color.gray, width: 1)
                    
                    TextField("Enter tag here...", text: $tag)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button(action: {
                        if !word.isEmpty && !description.isEmpty && !tag.isEmpty {
                            save(note: Note(word: word, noteDescription: description, tag: tag)) // 新たに追加した初期化方法を使用
                            word = ""
                            description = ""
                            tag = ""
                        }
                    }) {
                        Text("Save Note")
                    }
                    
                    NavigationLink(destination: NotesListView()) {
                        Text("View Notes")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .navigationBarTitle("Notes")
            }
        }
    }
    
    
    class RealmObserver: ObservableObject {
        @Published var notes: Results<Note> = {
            let realm = try! Realm()
            return realm.objects(Note.self)
        }()
    }
    
    struct NotesListView: View {
        @State private var searchWord: String = ""
        @ObservedObject var realmObserver = RealmObserver() // ここでRealmObserverを使用します。
        
        var body: some View {
            VStack {
                TextField("Search notes by tag...", text: $searchWord)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                List {
                    ForEach(realmObserver.notes.filter { note in
                        searchWord.isEmpty || note.tag.contains(searchWord)
                    }, id: \.id) { note in
                        NavigationLink(destination: NoteEditView(noteId: note.id)) {
                            VStack(alignment: .leading) {
                                Text(note.word)
                                    .font(.headline)
                                Text(note.noteDescription)
                                    .font(.subheadline)
                                Text(note.tag)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: removeNotes)
                }
                .navigationBarTitle("Saved Notes")
            }
        }
        
        func removeNotes(at offsets: IndexSet) {
            let realm = try! Realm()
            let notesToDelete = offsets.map { realmObserver.notes[$0] } // `Results`オブジェクトから削除するノートを取り出す
            
            try! realm.write {
                realm.delete(notesToDelete)
            }
        }
    }
    
    
    
    
    struct NoteEditView: View {
        let noteId: String
        @State private var word: String = ""
        @State private var description: String = ""
        @State private var tag: String = ""
        
        var body: some View {
            VStack {
                
                TextField("Enter word here...", text: $word)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                TextEditor(text: $description)
                    .padding()
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                
                TextField("Enter tag here...", text: $tag)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: {
                    let realm = try! Realm()
                    if let note = realm.object(ofType: Note.self, forPrimaryKey: noteId) { // IDを元にRealmからノートを取得
                        try! realm.write {
                            note.word = word
                            note.noteDescription = description
                            note.tag = tag
                        }
                    }
                }) {
                    Text("Update Note")
                }
            }
            .onAppear {
                let realm = try! Realm()
                if let note = realm.object(ofType: Note.self, forPrimaryKey: noteId) { // IDを元にRealmからノートを取得
                    word = note.word
                    description = note.noteDescription // `noteDescription`を表示
                    tag = note.tag
                }
            }
        }
    }
    
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


    

    
    
    
    
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
