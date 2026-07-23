import Foundation
import Combine

enum QuizState {
    case setup
    case loading
    case loaded
    case failed
}

@MainActor
class QuizRushVM: ObservableObject {
    
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: QuizState = .loading
    @Published var selectedAnswer: String? = nil
    @Published var isCorrect: Bool? = nil
    @Published var selectedCategory: TriviaCategory = .sports
    @Published var selectedDifficulty: TriviaDifficulty = .medium
    
    // Cache shuffled answers so they don't reshuffle on re-render
    private var shuffledAnswersCache: [String: [String]] = [:]
    
    private let service = TriviaAPI()
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var isLastQuestion: Bool {
        currentIndex >= questions.count - 1
    }
    
    init() {
        state = .setup
    }
    
    func load(
        category: TriviaCategory? = nil,
        difficulty: TriviaDifficulty? = nil
    ) async {
        if let category {
            selectedCategory = category
        }
        
        if let difficulty {
            selectedDifficulty = difficulty
        }
        
        await MainActor.run {
            state = .loading
        }
        
        do {
            let fetched = try await service.fetchQuestions(
                category: selectedCategory,
                difficulty: selectedDifficulty
            )
            
            guard !fetched.isEmpty else {
                await MainActor.run {
                    questions = []
                    shuffledAnswersCache = [:]
                    selectedAnswer = nil
                    isCorrect = nil
                    state = .failed
                }
                return
            }
            
            await MainActor.run {
                questions = fetched
                currentIndex = 0
                // Pre-shuffle answers for all questions
                shuffledAnswersCache = [:]
                for q in fetched {
                    shuffledAnswersCache[q.id] = q.shuffledAnswers
                }
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
    
    func resetToSetup() {
        questions = []
        currentIndex = 0
        score = 0
        streak = 0
        selectedAnswer = nil
        isCorrect = nil
        shuffledAnswersCache = [:]
        state = .setup
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
    
    // Stable shuffled answers for the current question . 
    var currentShuffledAnswers: [String] {
        guard let q = currentQuestion else { return [] }
        return shuffledAnswersCache[q.id] ?? q.shuffledAnswers
    }
}
