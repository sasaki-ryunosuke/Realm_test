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

//データベースのデータはuuid、word,noteDescription,tagの４要素からなる
//「今まで記録したことを思い出してみましょう！」、「クイズを始める」ボタンの2つを配置した
//クイズを始めるボタンを押すと以下の処理が始まり、ビュー２へ
//ボタンを押したときに、データベースからデータを取得し、配列にデータを格納する処理を行う。この配列はクイズの問題を表示するために使用する
//「この説明が示す、あなたがメモした言葉は？」「notedescription」「入力フォーム」「解答ボタン」の４つを表示するビュー２
//解答ボタンを押すと、入力された言葉とwordが一致した場合は正解、不一致の場合は不正解と表示し、「次の問題へ」というボタンも配置されたビュー3がポップアップする
//次の問題へボタンを押すと、問題を表示する配列の番号を指すインデックスが加算され、ビュー３が閉じて、ビュー２には次の問題が表示される。
//インデックスが最後に到達する(クイズが全て終了する)と、「クイズを終了します。」と表示され、ビュー１へ戻る



// ビュー１
struct protQuizView: View {
    @State private var startQuiz = false
    
    var body: some View {
        VStack {
            Text("今まで記録したことを思い出してみましょう！")
            Button("クイズを始める", action: { startQuiz = true })
                .sheet(isPresented: $startQuiz, content: {
                    ContentView(startQuiz: $startQuiz)
                })
        }
    }
}

// ビュー２＆３
struct ContentView: View {
    @Binding var startQuiz: Bool
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
    
    @State private var currentNoteIndex = 0
    @State private var answer = ""
    @State private var showAnswer = false
    @State private var isCorrect = false
    
    var body: some View {
        if currentNoteIndex < notes.count {
            VStack {
                Text("この説明が示す、あなたがメモした言葉は？")
                Text(notes[currentNoteIndex].noteDescription)
                TextField("あなたの回答", text: $answer)
                if !showAnswer {
                                    Button("解答", action: checkAnswer)
                                }
                
                if showAnswer {
                    if isCorrect {
                        Text("正解！")
                    } else {
                        Text("不正解。")
                    }
                    
                    Button("次の問題へ", action: nextQuestion)
                }
            }
        } else {
            Text("クイズを終了します。")
            Button("閉じる", action: { startQuiz = false })
        }
    }
    
    func checkAnswer() {
        showAnswer = true
        isCorrect = (answer == notes[currentNoteIndex].word)
    }
    
    func nextQuestion() {
        answer = ""
        showAnswer = false
        currentNoteIndex += 1
    }
}




//  7/25
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
//    @State private var currentNoteIndex = 0
//    @State private var answer = ""
//    @State private var showAnswer = false
//    @State private var isCorrect = false
//
//    var body: some View {
//        if currentNoteIndex < notes.count {
//            VStack {
//                Text("この説明が示す、あなたがメモした言葉は？")
//                Text(notes[currentNoteIndex].noteDescription)
//                TextField("あなたの回答", text: $answer)
//                Button("解答", action: checkAnswer)
//
//                if showAnswer {
//                    if isCorrect {
//                        Text("正解！")
//                    } else {
//                        Text("不正解。")
//                    }
//
//                    Button("次の問題へ", action: nextQuestion)
//                }
//            }
//        } else {
//            Text("クイズを終了します。")
//            Button("再開", action: restartQuiz)
//        }
//    }
//
//    func checkAnswer() {
//        showAnswer = true
//        isCorrect = (answer == notes[currentNoteIndex].word)
//    }
//
//    func nextQuestion() {
//        answer = ""
//        showAnswer = false
//        currentNoteIndex += 1
//    }
//
//    func restartQuiz() {
//        currentNoteIndex = 0
//    }
//}


//struct protQuizView: View {
//    //クイズ内容の取得処理
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
//    @State private var selectedNote: Note?
//    @State private var showingDetail = false
//
//    //配列の内容表示
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
//                NoteDetailView(note: note, isPresented: self.$showingDetail)
//            }
//        }
//    }
//}
//
////詳細表示
//struct NoteDetailView: View {
//    var note: Note
//    @Binding var isPresented: Bool  // 表示状態を制御する変数
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(note.word).font(.title)
//            Text(note.noteDescription).font(.body)
//            Text(note.tag).font(.body)
//
//            // 閉じるボタン
//            Button(action: {
//                self.isPresented = false
//            }) {
//                Text("閉じる")
//            }
//        }
//        .padding()
//    }
//}
