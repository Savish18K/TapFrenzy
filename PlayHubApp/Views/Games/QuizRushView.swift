import SwiftUI
import CoreLocation

// Per-option vivid colours used consistently throughout the quiz
private let optionColors: [Color] = [
    Color(red: 0.18, green: 0.52, blue: 1.00),  // A – electric blue
    Color(red: 1.00, green: 0.25, blue: 0.55),  // B – hot pink
    Color(red: 0.05, green: 0.80, blue: 0.65),  // C – cyan-teal
    Color(red: 1.00, green: 0.70, blue: 0.05)   // D – amber
]

struct QuizRushView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = QuizRushVM()
    @AppStorage("quizRushHighScore") private var highScore = 0

    @State private var showResults   = false
    @State private var shakeAmount: CGFloat = 0
    @State private var playerName    = ""
    @State private var showNameSheet = false
    @State private var cardScale: CGFloat = 1.0

    // ── Palette ───────────────────────────────────────────────────────────
    let accentA = optionColors[0]
    let accentB = optionColors[1]
    let accentC = optionColors[2]
    let accentD = optionColors[3]
    let cardBg  = Color(red: 0.10, green: 0.11, blue: 0.17)
    let bgBase  = Color(red: 0.06, green: 0.07, blue: 0.12)

    var body: some View {
        ZStack {
            // ── Background ────────────────────────────────────────────────
            bgBase.ignoresSafeArea()

            // Vivid ambient blobs
            Circle()
                .fill(accentA.opacity(0.18))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -100, y: -220)

            Circle()
                .fill(accentB.opacity(0.16))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 140, y: 120)

            Circle()
                .fill(accentC.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: -60, y: 300)

            // ── Content ───────────────────────────────────────────────────
            switch viewModel.state {
            case .loading: loadingView
            case .failed:  failedView
            case .loaded:
                if showResults { resultsView } else { quizView }
            }
        }
        .navigationBarHidden(true)
        // Back button
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.14)))
                    .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))
            }
            .padding(.leading, 16)
            .padding(.top, 8)
        }
        .sheet(isPresented: $showNameSheet) { nameSheet }
        .task { await viewModel.load() }
    }

    // MARK: Loading
    var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                ForEach(0..<4) { i in
                    Circle()
                        .fill(optionColors[i].opacity(0.35))
                        .frame(width: 14, height: 14)
                        .offset(x: 0, y: -28)
                        .rotationEffect(.degrees(Double(i) * 90))
                }
                ProgressView()
                    .scaleEffect(1.4)
                    .tint(.white)
            }
            Text("Loading Questions…")
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .medium))
        }
    }

    // MARK: Failed
    var failedView: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(accentB.opacity(0.2))
                    .frame(width: 90, height: 90)
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundColor(accentB)
            }
            VStack(spacing: 8) {
                Text("Couldn't Load Questions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("Check your connection and try again.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Button {
                Task { await viewModel.load() }
            } label: {
                Text("RETRY")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [accentA, accentB],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(Capsule())
            }
            Button { dismiss() } label: {
                Text("Back to Home")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: Quiz
    // ─────────────────────────────────────────────────────────────────────
    var quizView: some View {
        VStack(spacing: 0) {

            // ── Header ────────────────────────────────────────────────────
            HStack(alignment: .center) {

                // Score pill
                VStack(spacing: 1) {
                    Text("SCORE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(accentA.opacity(0.8))
                    Text("\(viewModel.score)")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(accentA.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(accentA.opacity(0.5), lineWidth: 1.5))
                )

                Spacer()

                // Streak badge
                if viewModel.streak > 1 {
                    HStack(spacing: 4) {
                        Text("🔥").font(.system(size: 16))
                        Text("\(viewModel.streak)")
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(accentD)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(accentD.opacity(0.18)))
                    .overlay(Capsule().stroke(accentD.opacity(0.5), lineWidth: 1.5))
                }

                Spacer()

                // Question counter
                VStack(spacing: 1) {
                    Text("QUESTION")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(accentC.opacity(0.8))
                    Text("\(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(accentC.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(accentC.opacity(0.5), lineWidth: 1.5))
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 64)

            // ── Progress bar ──────────────────────────────────────────────
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [accentA, accentB, accentC],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(
                            width: viewModel.questions.isEmpty ? 0 :
                                geo.size.width * CGFloat(viewModel.currentIndex + 1) /
                                CGFloat(viewModel.questions.count),
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentIndex)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            if let question = viewModel.currentQuestion {

                // ── Feedback banner ───────────────────────────────────────
                if let correct = viewModel.isCorrect {
                    HStack(spacing: 8) {
                        Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text(correct ? "Correct!  +10 pts" : "Wrong!  -3 pts")
                            .font(.system(size: 16, weight: .black))
                    }
                    .foregroundColor(correct ? accentC : accentB)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill((correct ? accentC : accentB).opacity(0.18))
                            .overlay(
                                Capsule().stroke((correct ? accentC : accentB).opacity(0.6), lineWidth: 1.5)
                            )
                    )
                    .shadow(color: (correct ? accentC : accentB).opacity(0.4), radius: 12)
                    .transition(.scale.combined(with: .opacity))
                }

                // ── Question card ─────────────────────────────────────────
                VStack(spacing: 0) {
                    // colourful top accent strip
                    LinearGradient(
                        colors: [accentA, accentB, accentC, accentD],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(height: 4)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20, bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0, topTrailingRadius: 20
                        )
                    )

                    Text(question.decodedQuestion)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 22)
                        .modifier(ShakeEffect(animatableData: shakeAmount))
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .shadow(color: accentA.opacity(0.1), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 20)
                .scaleEffect(cardScale)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: cardScale)

                Spacer().frame(height: 20)

                // ── Answer grid (2 × 2) ───────────────────────────────────
                let answers = question.shuffledAnswers
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        if answers.count > 0 {
                            answerButton(answers[0], question: question, index: 0)
                        }
                        if answers.count > 1 {
                            answerButton(answers[1], question: question, index: 1)
                        }
                    }
                    HStack(spacing: 12) {
                        if answers.count > 2 {
                            answerButton(answers[2], question: question, index: 2)
                        }
                        if answers.count > 3 {
                            answerButton(answers[3], question: question, index: 3)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isCorrect)
    }

    // ── Answer button ─────────────────────────────────────────────────────
    func answerButton(_ answer: String, question: Question, index: Int) -> some View {
        let color           = optionColors[index % optionColors.count]
        let isSelected      = viewModel.selectedAnswer == answer
        let isCorrectAnswer = answer == question.decodedCorrectAnswer
        let answered        = viewModel.selectedAnswer != nil

        // State-dependent styling
        let fillOpacity: Double = {
            if !answered { return 0.14 }
            if isCorrectAnswer { return 0.30 }
            if isSelected      { return 0.22 }
            return 0.05
        }()

        let strokeColor: Color = {
            if !answered { return color.opacity(0.55) }
            if isCorrectAnswer { return accentC }
            if isSelected      { return accentB }
            return color.opacity(0.12)
        }()

        let textColor: Color = {
            if !answered { return .white }
            if isCorrectAnswer { return accentC }
            if isSelected      { return accentB }
            return Color.white.opacity(0.3)
        }()

        let letters = ["A", "B", "C", "D"]
        let letter  = index < letters.count ? letters[index] : "?"

        return Button {
            handleAnswerTap(answer, question: question)
        } label: {
            VStack(spacing: 10) {
                // Letter badge at top
                HStack {
                    ZStack {
                        Circle()
                            .fill(answered
                                  ? (isCorrectAnswer ? accentC.opacity(0.3) : (isSelected ? accentB.opacity(0.3) : color.opacity(0.08)))
                                  : color.opacity(0.28))
                            .frame(width: 30, height: 30)
                        Text(letter)
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(answered
                                             ? (isCorrectAnswer ? accentC : (isSelected ? accentB : color.opacity(0.3)))
                                             : color)
                    }

                    Spacer()

                    // Result icon
                    if answered {
                        if isCorrectAnswer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(accentC)
                                .font(.system(size: 20))
                                .transition(.scale.combined(with: .opacity))
                        } else if isSelected {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(accentB)
                                .font(.system(size: 20))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                // Answer text
                Text(answer)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(fillOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(strokeColor,
                            lineWidth: answered && (isCorrectAnswer || isSelected) ? 2.5 : 1.5)
            )
            .shadow(
                color: answered && isCorrectAnswer ? accentC.opacity(0.35) :
                       answered && isSelected      ? accentB.opacity(0.25) :
                       color.opacity(0.08),
                radius: answered && (isCorrectAnswer || isSelected) ? 12 : 4
            )
            .scaleEffect(isSelected && answered ? 1.03 : 1.0)
        }
        .disabled(answered)
        .animation(.spring(response: 0.28, dampingFraction: 0.6), value: answered)
        .animation(.spring(response: 0.28, dampingFraction: 0.6), value: isSelected)
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: Results
    // ─────────────────────────────────────────────────────────────────────
    var resultsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer().frame(height: 60)

                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [accentA.opacity(0.3), accentB.opacity(0.3), accentC.opacity(0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle().stroke(
                                LinearGradient(colors: [accentA, accentB, accentC, accentD],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                        )
                    Text(viewModel.score >= highScore && viewModel.score > 0 ? "🏆" : "🧠")
                        .font(.system(size: 54))
                }

                VStack(spacing: 8) {
                    Text("QUIZ COMPLETE!")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(
                            LinearGradient(colors: [accentA, accentB],
                                           startPoint: .leading, endPoint: .trailing)
                        )

                    if viewModel.score >= highScore && viewModel.score > 0 {
                        HStack(spacing: 4) {
                            Text("⭐️")
                            Text("NEW HIGH SCORE!")
                                .font(.system(size: 14, weight: .black))
                            Text("⭐️")
                        }
                        .foregroundColor(accentD)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(accentD.opacity(0.15)))
                        .overlay(Capsule().stroke(accentD.opacity(0.5), lineWidth: 1.5))
                    }
                }

                // Score card
                VStack(spacing: 4) {
                    Text("FINAL SCORE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.gray)
                    Text("\(viewModel.score)")
                        .font(.system(size: 76, weight: .black))
                        .foregroundStyle(
                            LinearGradient(colors: [accentA, accentC],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .contentTransition(.numericText())
                    if viewModel.score < highScore {
                        Text("Best: \(highScore)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    LinearGradient(colors: [accentA.opacity(0.5), accentC.opacity(0.5)],
                                                   startPoint: .leading, endPoint: .trailing),
                                    lineWidth: 1.5
                                )
                        )
                )
                .padding(.horizontal, 24)

                // Buttons
                VStack(spacing: 12) {
                    ShareLink(item: "I just scored \(viewModel.score) on Quiz Rush — beat that! 🧠") {
                        Text("SHARE SCORE")
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(colors: [accentC, accentA],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: accentC.opacity(0.4), radius: 12)
                    }
                    
                    Button {
                        showResults = false
                        Task { await viewModel.load() }
                    } label: {
                        Text("PLAY AGAIN")
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(colors: [accentA, accentB],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: accentA.opacity(0.4), radius: 12)
                    }

                    NavigationLink(destination: StatsTab(game: "QuizRush")) {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill").foregroundColor(accentD)
                            Text("Leaderboard")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 16).fill(cardBg))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(accentD.opacity(0.6), lineWidth: 1.5))
                    }

                    Button { dismiss() } label: {
                        Text("Back to Home")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
    }

   
    // MARK: Name sheet
    
    var nameSheet: some View {
        ZStack {
            bgBase.ignoresSafeArea()

            // Decorative blobs
            Circle()
                .fill(accentA.opacity(0.18))
                .frame(width: 220)
                .blur(radius: 60)
                .offset(x: -80, y: -100)

            Circle()
                .fill(accentB.opacity(0.18))
                .frame(width: 180)
                .blur(radius: 60)
                .offset(x: 80, y: 60)

            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, 14)

                Text("Quiz Complete!")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(
                        LinearGradient(colors: [accentA, accentB],
                                       startPoint: .leading, endPoint: .trailing)
                    )

                Text("\(viewModel.score) pts")
                    .font(.system(size: 46, weight: .black))
                    .foregroundStyle(
                        LinearGradient(colors: [accentC, accentA],
                                       startPoint: .leading, endPoint: .trailing)
                    )

                Text("Enter your name to save your score")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                TextField("Your name", text: $playerName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(accentA.opacity(0.6), lineWidth: 1.5))
                    .padding(.horizontal, 24)

                Button {
                    let lat = LocationService.shared.lastLocation?.coordinate.latitude ?? 0.0
                    let lon = LocationService.shared.lastLocation?.coordinate.longitude ?? 0.0
                    SessionStore.shared.save(mode: .quizRush, score: viewModel.score, lat: lat, lon: lon, playerName: playerName.isEmpty ? "Anonymous" : playerName)
                    
                    playerName = ""
                    showNameSheet = false
                    showResults = true
                } label: {
                    Text("SAVE & SEE RESULTS")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [accentA, accentB],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: accentA.opacity(0.45), radius: 10)
                        .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 30)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

  
    // MARK: Logic
   
    func handleAnswerTap(_ answer: String, question: Question) {
        viewModel.selectAnswer(answer)

        // Bounce the card
        withAnimation(.easeInOut(duration: 0.08)) { cardScale = 0.96 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { cardScale = 1.0 }
        }

        // Shake on wrong answer
        if viewModel.isCorrect == false {
            withAnimation(.default) { shakeAmount += 1 }
        }

        // 2.5 s so users can clearly read the answer feedback before moving on
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if viewModel.isLastQuestion {
                if viewModel.score > highScore { highScore = viewModel.score }
                showNameSheet = true
            } else {
                viewModel.nextQuestion()
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
    NavigationStack {
        QuizRushView()
    }
}
