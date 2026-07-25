TapFrenzy 

A multi-game iOS app built with SwiftUI iOS App. 
Games

Tap Frenzy— Tap as fast as you can in 10 seconds.
Features combo system, trap colours, moving target,
shrinking button and bonus burst.

Light It Up — Tap the glowing card before it goes dark.
Four difficulty levels that ramp automatically in a 60 second round.

Quiz Rush— Answer 10 live trivia questions fetched
from the Open Trivia DB API. Streak bonus for consecutive correct answers.

 Features

- TabView shell with Home, Stats, Map and Settings tabs
- Leaderboard with player name, score and date per game
- Stats screen with bar chart using Swift Charts framework
- Map showing where each game was played using MapKit and Core Location
- Daily challenge notification scheduled from Settings
- Share your score using ShareLink
- High scores persisted using AppStorage and UserDefaults

Architecture

- MVVM pattern — ViewModels separate from Views
- Codable structs for all data models
- async/await and URLSession for API calls
- ObservableObject and @Published for reactive UI
- GameSession model persisted as JSON in UserDefaults

Tech Stack

SwiftUI · Combine · MapKit · Core Location ·
UserNotifications · Swift Charts · URLSession

 Known Limitations

- Map pins only appear when location permission is granted
- Quiz questions require an internet connection
- High scores are stored locally and do not sync across devices


