import SwiftUI

struct SettingsTab: View {
    @AppStorage("dailyNotificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationGameType") private var notificationGameType = "Random"
    @State private var notificationTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showResetConfirmation = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("SETTINGS")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Notifications Section
                VStack(spacing: 0) {
                    Toggle("Daily Reminder", isOn: $notificationsEnabled)
                        .padding()
                        .foregroundColor(.white)
                        .tint(.purple)
                        .onChange(of: notificationsEnabled) {
                            if notificationsEnabled {
                                NotificationService.shared.requestPermission()
                                scheduleNotification()
                            } else {
                                NotificationService.shared.cancelAll()
                            }
                        }
                    
                    if notificationsEnabled {
                        Divider().background(Color.gray.opacity(0.3))
                        
                        DatePicker("Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                            .onChange(of: notificationTime) {
                                scheduleNotification()
                            }
                            
                        Divider().background(Color.gray.opacity(0.3))
                        
                        Picker("Reminder Type", selection: $notificationGameType) {
                            Text("Random").tag("Random")
                            Text("Tap Frenzy").tag("Tap Frenzy")
                            Text("Light It Up").tag("Light It Up")
                            Text("Quiz Rush").tag("Quiz Rush")
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .foregroundColor(.white)
                        .tint(.purple)
                        .onChange(of: notificationGameType) {
                            scheduleNotification()
                        }
                    }
                }
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
                
                // Reset Button
                Button(action: {
                    showResetConfirmation = true
                }) {
                    Text("RESET ALL STATS")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 1.5)
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .confirmationDialog("Are you sure?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                    Button("Reset Stats", role: .destructive) {
                        SessionStore.shared.clearAll()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone and will delete all your game history and high scores.")
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func scheduleNotification() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        if let hour = components.hour, let minute = components.minute {
            NotificationService.shared.scheduleDailyNotification(at: hour, minute: minute, type: notificationGameType)
        }
    }
}

#Preview {
    SettingsTab()
}
