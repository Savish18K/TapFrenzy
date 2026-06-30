import Foundation
import UIKit

// matches the outer JSON wrapper: { "results": [...] }
struct TriviaResponse: Codable {
    let results: [Question]
}

// matches each question object in the API
struct Question: Codable, Identifiable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    // Identifiable needs an id - question text works fine here
    var id: String { question }
    
    // decode HTML entities like &quot; &#039; into normal text
    var decodedQuestion: String {
        question.htmlDecoded
    }
    
    var decodedCorrectAnswer: String {
        correct_answer.htmlDecoded
    }
    
    var decodedIncorrectAnswers: [String] {
        incorrect_answers.map { $0.htmlDecoded }
    }
    
    // mix correct + incorrect answers and shuffle them
    var shuffledAnswers: [String] {
        ([decodedCorrectAnswer] + decodedIncorrectAnswers).shuffled()
    }
}

// helper to clean up HTML entities the API sends back
extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        guard let attributed = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ) else { return self }
        return attributed.string
    }
}
