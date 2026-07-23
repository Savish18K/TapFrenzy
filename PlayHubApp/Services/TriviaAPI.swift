import Foundation

enum TriviaError: Error {
    case badURL
    case badResponse
    case noResults
    case decodeFailed
}

enum TriviaCategory: String, CaseIterable, Identifiable {
    case any = "Any"
    case sports = "Sports"
    case history = "History"
    case music = "Music"
    case movies = "Movies"
    case geography = "Geography"
    case science = "Science"
    case computers = "Computers"
    case videoGames = "Video Games"
    case generalKnowledge = "General Knowledge"
    
    var id: String { rawValue }
    
    var apiID: Int? {
        switch self {
        case .any: return nil
        case .sports: return 21
        case .history: return 23
        case .music: return 12
        case .movies: return 11
        case .geography: return 22
        case .science: return 17
        case .computers: return 18
        case .videoGames: return 15
        case .generalKnowledge: return 9
        }
    }
}

enum TriviaDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { rawValue }
    var apiValue: String { rawValue.lowercased() }
}

struct TriviaAPI {
    
    func fetchQuestions(
        category: TriviaCategory? = nil,
        difficulty: TriviaDifficulty? = nil
    ) async throws -> [Question] {
        var components = URLComponents(string: "https://opentdb.com/api.php")
        var queryItems = [
            URLQueryItem(name: "amount", value: "10"),
            URLQueryItem(name: "type", value: "multiple")
        ]
        
        if let categoryID = category?.apiID {
            queryItems.append(URLQueryItem(name: "category", value: "\(categoryID)"))
        }
        
        if let difficulty {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty.apiValue))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw TriviaError.badURL
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TriviaError.badResponse
        }
        
        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            guard decoded.response_code == 0 else {
                throw TriviaError.noResults
            }
            return decoded.results
        } catch {
            if error is TriviaError {
                throw error
            }
            throw TriviaError.decodeFailed
        }
    }
}
