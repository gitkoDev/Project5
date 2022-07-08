//
//  ViewController.swift
//  Project5
//
//  Created by Gitko Denis on 27.06.2022.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    var currentWord: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadWord))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
//        set userDefaults
        let defaults = UserDefaults.standard
        let currentWord = defaults.object(forKey: "currentWord") as? String ?? allWords.randomElement()
        usedWords = defaults.object(forKey: "usedWords") as? [String] ?? [String]()
        title = currentWord
        startGame()
    }
    
    @objc func startGame() {
//        Set userDefaults
        let defaults = UserDefaults.standard
        defaults.set(title, forKey: "currentWord")
        
//        usedWords.removeAll(keepingCapacity: true)
//        tableView.reloadData()
    }
    
    @objc func reloadWord() {
        currentWord = allWords.randomElement()
        title = currentWord
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
//        Set userDefaults
        let defaults = UserDefaults.standard
        defaults.set(title, forKey: "currentWord")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert )
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        var errorTitle: String
        var errorMessage: String
        
        if !isReal(word: lowerAnswer) {
            errorTitle = "Word not recognized"
            errorMessage = "You can't just make them up, you know!"
            showErrorMessage(title: errorTitle, message: errorMessage)
        }
        else if !isOriginal(word: lowerAnswer) {
            errorTitle = "Word used already"
            errorMessage = "Be more original!"
            showErrorMessage(title: errorTitle, message: errorMessage)
        }
        else if !isPossible(word: lowerAnswer) {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
            showErrorMessage(title: errorTitle, message: errorMessage)
        } else if !isNotLessThanThreeCharacters(word: lowerAnswer) {
            errorTitle = "Word is too short"
            errorMessage = "The word should be longer than 2 characters"
            showErrorMessage(title: errorTitle, message: errorMessage)
        } else if !isSameAsStartingWord(word: lowerAnswer){
            errorTitle = "Same word"
            errorMessage = "Your word is the same as the starting word"
            showErrorMessage(title: errorTitle, message: errorMessage)
        } else {
            usedWords.insert(answer.lowercased(), at: 0)
            
            let defaults = UserDefaults.standard
            defaults.set(usedWords, forKey: "usedWords")
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
        

    }
    
    
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func isNotLessThanThreeCharacters(word: String) -> Bool {
        return word.count > 2
    }
    func isSameAsStartingWord(word: String) -> Bool {
        return title?.lowercased() != word
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
}

