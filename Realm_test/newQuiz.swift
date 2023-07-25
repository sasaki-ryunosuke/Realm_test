//
//  newQuiz.swift
//  Realm_test
//
//  Created by x19048xx on 2023/07/19.
//

import Foundation
import RealmSwift
import SwiftUI

//
//struct protQuizView: View {
//    @State private var notes: [Note] = {
//        do {
//            let realm = try Realm()
//            let results = realm.objects(Note.self)
//            let shuffledResults = Array(results).shuffled()
//            let selectedNotes = shuffledResults.prefix(5)
//            return Array(selectedNotes)
//        } catch {
//            print("Failed to access Realm: \(error)")
//            return []
//        }
//    }()
//
//    @State private var selectedNote: Note?
//    @State private var showingDetail = false
//
//    var body: some View {
//        List {
//            ForEach(notes, id: \.id) { note in
//                Text(note.word)
//                    .onTapGesture {
//                        self.selectedNote = note
//                        self.showingDetail = true
//                    }
//            }
//        }
//        .sheet(isPresented: $showingDetail) {
//            if let note = self.selectedNote {
//                NoteDetailView(note: note)
//            }
//        }
//    }
//}
//
//struct NoteDetailView: View {
//    var note: Note
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(note.word).font(.title)
//            Text(note.noteDescription).font(.body)
//            Text(note.tag).font(.body)
//        }
//        .padding()
//    }
//}


//クイズのタイトル、「今まで記録したことを思い出してみましょう！」、「クイズを始める」ボタンを配置したビュー
//ボタンを押したときに、データベースからデータを取得し、クイズ出題のための配列にデータを格納する処理を行う
//「この説明が示す、あなたがメモした言葉は？」「説明」「入力フォーム」を表示する

struct protQuizView: View {
    //クイズ内容の取得処理
    @State private var notes: [Note] = {
        do {
            let realm = try Realm()
            let results = realm.objects(Note.self)
            let shuffledResults = Array(results).shuffled()
            let selectedNotes = shuffledResults.prefix(5)
            return Array(selectedNotes)
        } catch {
            print("Failed to access Realm: \(error)")
            return []
        }
    }()
    @State private var selectedNote: Note?
    @State private var showingDetail = false

    //配列の内容表示
    var body: some View {
        List {
            ForEach(notes, id: \.id) { note in
                Text(note.word)
                    .onTapGesture {
                        self.selectedNote = note
                        self.showingDetail = true
                    }
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let note = self.selectedNote {
                NoteDetailView(note: note, isPresented: self.$showingDetail)
            }
        }
    }
}

//詳細表示
struct NoteDetailView: View {
    var note: Note
    @Binding var isPresented: Bool  // 表示状態を制御する変数

    var body: some View {
        VStack(alignment: .leading) {
            Text(note.word).font(.title)
            Text(note.noteDescription).font(.body)
            Text(note.tag).font(.body)
            
            // 閉じるボタン
            Button(action: {
                self.isPresented = false
            }) {
                Text("閉じる")
            }
        }
        .padding()
    }
}
