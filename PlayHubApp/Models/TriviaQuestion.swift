import Foundation


struct TriviaResponse: Codable {
    let response_code: Int
    let results: [Question]
}

// matches each question object in the API
struct Question: Codable, Identifiable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    // Identifiable needs an id
    var id: String { question }
    
   
    var decodedQuestion: String {
        question.htmlDecoded
    }
    
    var decodedCorrectAnswer: String {
        correct_answer.htmlDecoded
    }
    
    var decodedIncorrectAnswers: [String] {
        incorrect_answers.map { $0.htmlDecoded }
    }
    
    
    var shuffledAnswers: [String] {
        ([decodedCorrectAnswer] + decodedIncorrectAnswers).shuffled()
    }
}

// helper to clean up HTML entities the API sends back
extension String {
    var htmlDecoded: String {
        var result = self
        let replacements: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&apos;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&ldquo;": "\u{201C}",
            "&rdquo;": "\u{201D}",
            "&rsquo;": "\u{2019}",
            "&eacute;": "é",
            "&uuml;": "ü",
            "&ouml;": "ö",
            "&auml;": "ä"
        ]
        
        for (key, value) in replacements {
            result = result.replacingOccurrences(of: key, with: value)
        }
        
        return result
    }
}
