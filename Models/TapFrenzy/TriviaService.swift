import Foundation

enum TriviaError: Error {
    case badURL
    case badResponse
    case decodeFailed
}

struct TriviaService {
    
    func fetchQuestions() async throws -> [Question] {
        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        
        guard let url = URL(string: urlString) else {
            throw TriviaError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TriviaError.badResponse
        }
        
        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return decoded.results
        } catch {
            throw TriviaError.decodeFailed
        }
    }
}
