//
//  ContentView.swift
//  Word Scramble
//
//  Created by Rakesh Shrestha on 30/12/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingError: Bool = false
    
    @State private var score = 0
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Score: \(score)")
                    .font(.largeTitle)
                List {
                    Section {
                        TextField("Enter your new word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Choose Another Word", action: startGame)
            }
            .onSubmit {
                addNewWord()
            }
            .onAppear {
                startGame()
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok") {
                    withAnimation {
                        newWord = ""
                    }
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "Answer too short", message: "You need to enter at least three characters")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Please enter a different word")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "Please enter a word that can be made from '\(rootWord)'")
            return
        }
        
        guard isRealWord(word: answer) else {
            wordError(title: "Word not real", message: "Please enter a word that is in the dictionary")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        score += newWord.count
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "random"
                return
            }
        }
        
        fatalError( "Couldn't load start.txt from bundle")
        
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isRealWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelled.location == NSNotFound
        
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
