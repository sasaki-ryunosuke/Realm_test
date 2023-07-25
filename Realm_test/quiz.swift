//
//  quiz.swift
//  Realm_test
//
//  Created by x19048xx on 2023/07/12.
//

import Foundation
import SwiftUI
import RealmSwift

struct QuizView: View {
    @State private var noteIds: [String] = {
        do {
            let realm = try Realm()
            let results = realm.objects(Note.self)
            let shuffledResults = Array(results).shuffled()
            let selectedNotes = shuffledResults.prefix(5)
            return Array(selectedNotes).map { $0.id }
        } catch {
            print("Failed to access Realm: \(error)")
            return []
        }
    }()
    
    @State private var currentIndex = 0
    @State private var answer: String = ""
    @State private var showAnswerView = false//結果表示画面表示のフラグ
    @State private var correctAnswer = ""
    @State private var showAlert = false
    @State private var showExitAlert = false
    @State private var nextQuestionLinkIsActive = false//クイズビューの再表示用

    var body: some View {
        if noteIds.count > currentIndex,
           let currentNote = try? Realm().object(ofType: Note.self, forPrimaryKey: noteIds[currentIndex]) {
            VStack {
                Text("この説明が表す言葉は何でしょう?")
                    .padding(30) // テキストの周囲にパディングを追加する
                
                Text(currentNote.noteDescription)
                    .font(.headline)
                
                TextField("Enter your answer...", text: $answer)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: {
                    if answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showAlert = true
                    } else {
                        correctAnswer = currentNote.word
                        showAnswerView = true
                    }
                }) {
                    Text("Submit Answer")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("Your answer cannot be blank."), dismissButton: .default(Text("OK")))
                }
                
                    NavigationLink(
                        destination: AnswerView(isCorrect: answer == correctAnswer, correctAnswer: correctAnswer, onContinue: {
                            showAnswerView = false
                            answer = ""
                            if currentIndex < noteIds.count - 1 {
                                currentIndex += 1
                                nextQuestionLinkIsActive = true
                            }
                            //renderTrigger.toggle()//クイズビューの再レンダリング
                        }),
                        isActive: $showAnswerView,
                        label: {
                            EmptyView()
                        }
                    )
                    NavigationLink(
                        destination: QuizView(),
                        isActive: $nextQuestionLinkIsActive,
                        label: {
                            EmptyView()
                        }
                    )
                

                Button(action: {
                    showExitAlert = true
                }) {
                    Text("Back to Home")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showExitAlert) {
                    Alert(title: Text("Exit Quiz"),
                          message: Text("Are you sure you want to exit the quiz and return to the home screen?"),
                          primaryButton: .destructive(Text("Exit"), action: {
                              // Navigate back to home screen
                          }),
                          secondaryButton: .cancel(Text("Continue Quiz")))
                }
            }
        } else {
            Text("No more quizzes available.")
            NavigationLink(destination: HomeView()) {
                Text("Back to Home")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}





struct AnswerView: View {
    var isCorrect: Bool
    var correctAnswer: String
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Text(isCorrect ? "Correct!" : "Wrong!")
                .font(.largeTitle)
            Text("The correct answer was \(correctAnswer).")
                .font(.title2)
            Button(action: {
                onContinue()
            }) {
                Text("Continue")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
