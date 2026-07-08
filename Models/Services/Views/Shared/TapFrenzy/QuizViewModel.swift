import Foundation
import Combine

enum QuizState {
    case loading
    case loaded
    case failed
}

@MainActor
class QuizViewModel: ObservableObject {
    
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: QuizState = .loading
    @Published var selectedAnswer: String? = nil
    @Published var isCorrect: Bool? = nil
    
    private let service = TriviaService()
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var isLastQuestion: Bool {
        currentIndex >= questions.count - 1
    }
    
    func load() async {
        await MainActor.run {
            state = .loading
        }
        
        do {
            let fetched = try await service.fetchQuestions()
            await MainActor.run {
                questions = fetched
                currentIndex = 0
                score = 0
                streak = 0
                selectedAnswer = nil
                isCorrect = nil
                state = .loaded
            }
        } catch {
            await MainActor.run {
                state = .failed
            }
        }
    }
    
    func selectAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        guard selectedAnswer == nil else { return } // prevent double tap
        
        selectedAnswer = answer
        
        if answer == question.decodedCorrectAnswer {
            isCorrect = true
            streak += 1
            // bonus points for streak
            let bonus = streak >= 3 ? 5 : 0
            score += 10 + bonus
        } else {
            isCorrect = false
            streak = 0
            score = max(0, score - 3)
        }
    }
    
    func nextQuestion() {
        selectedAnswer = nil
        isCorrect = nil
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        }
    }
}
