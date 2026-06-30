import SwiftUI

struct QuizRushView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = QuizViewModel()
    @AppStorage("quizRushHighScore") private var highScore = 0
    
    @State private var showResults = false
    @State private var shakeAmount: CGFloat = 0
    @State private var playerName = ""
    @State private var showNameSheet = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch viewModel.state {
            case .loading:
                loadingView
            case .failed:
                failedView
            case .loaded:
                if showResults {
                    resultsView
                } else {
                    quizView
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showNameSheet) {

            VStack(spacing:20){

                Text("Save Your Score")
                    .font(.largeTitle.bold())

                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Save"){

                    let name = playerName.isEmpty ? "Player" : playerName

                    LeaderboardManager.shared.saveScore(
                        playerName: name,
                        score: viewModel.score,
                        game: "QuizRush"
                    )

                    showNameSheet = false
                    showResults = true
                }
                .buttonStyle(.borderedProminent)

            }
            .padding()
        }
        .task {
            await viewModel.load()
        }
    }
    
    // MARK - Loading State
    
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.orange)
            
            Text("Loading questions...")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
    }
    
    // MARK - Failed State
    
    var failedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Couldn't load questions")
                .font(.title3)
                .foregroundColor(.white)
            
            Text("Check your internet connection and try again")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task {
                    await viewModel.load()
                }
            } label: {
                Text("RETRY")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .foregroundColor(.black)
                    .cornerRadius(14)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Back to Home")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
    }
    
    // MARK - Quiz State
    
    var quizView: some View {
        VStack(spacing: 0) {
            
            // top bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(viewModel.score)")
                        .font(.system(size: 30, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if viewModel.streak > 1 {
                    VStack {
                        Text("🔥 \(viewModel.streak)")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.orange)
                        Text("STREAK")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("QUESTION")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            
            Spacer()
            
            if let question = viewModel.currentQuestion {
                
                // question card
                Text(question.decodedQuestion)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .modifier(ShakeEffect(animatableData: shakeAmount))
                
                Spacer()
                
                // answer buttons
                VStack(spacing: 14) {
                    ForEach(question.shuffledAnswers, id: \.self) { answer in
                        answerButton(answer, question: question)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
    
    func answerButton(_ answer: String, question: Question) -> some View {
        let isSelected = viewModel.selectedAnswer == answer
        let isCorrectAnswer = answer == question.decodedCorrectAnswer
        
        var bgColor: Color = Color(red: 0.15, green: 0.17, blue: 0.22)
        var borderColor: Color = Color.gray.opacity(0.3)
        
        if viewModel.selectedAnswer != nil {
            if isCorrectAnswer {
                bgColor = Color.green.opacity(0.3)
                borderColor = .green
            } else if isSelected {
                bgColor = Color.red.opacity(0.3)
                borderColor = .red
            }
        }
        
        return Button {
            handleAnswerTap(answer, question: question)
        } label: {
            Text(answer)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(bgColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1.5)
                )
        }
        .disabled(viewModel.selectedAnswer != nil)
    }
    
    func handleAnswerTap(_ answer: String, question: Question) {
        viewModel.selectAnswer(answer)
        
        if viewModel.isCorrect == false {
            withAnimation(.default) {
                shakeAmount += 1
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if viewModel.isLastQuestion {

                if viewModel.score > highScore {
                    highScore = viewModel.score
                }

                showNameSheet = true
            }
            else {
                viewModel.nextQuestion()
            }
        }
    }
    
    // MARK - Results State
    
    var resultsView: some View {
        VStack(spacing: 24) {
            Text("QUIZ COMPLETE!")
                .font(.system(size: 34, weight: .black))
                .foregroundColor(.orange)
            
            Text("Final Score")
                .foregroundColor(.gray)
            
            Text("\(viewModel.score)")
                .font(.system(size: 70, weight: .black))
                .foregroundColor(.white)
            
            if viewModel.score > 0 && viewModel.score >= highScore {
                Text("NEW HIGH SCORE!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("Best: \(highScore)")
                    .foregroundColor(.gray)
            }
            
            Button {
                showResults = false
                Task {
                }
            } label: {
                Text("PLAY AGAIN")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 44)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .foregroundColor(.black)
                    .cornerRadius(14)
            }
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 14))
                    Text("Choose Another Game")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.6), Color.red.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange, lineWidth: 1.5)
                )
            }
        }
    }
}


struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 6 * sin(animatableData * .pi * 6)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    QuizRushView()
}
