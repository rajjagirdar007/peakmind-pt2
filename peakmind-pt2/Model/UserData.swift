import Foundation
import FirebaseFirestoreSwift

struct UserData: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var username: String
    var selectedAvatar: String
    var selectedBackground: String
    var hasCompletedInitialQuiz: Bool
    var hasSetInitialAvatar: Bool
    var inventory: [String]
    var LevelOneCompleted: Bool
    var LevelTwoCompleted: Bool
    var selectedWidgets: [String]
    var lastCheck: Date?
    var weeklyStatus: [Int]
    var hasCompletedTutorial: Bool
    var completedLevels: [String]
    var completedLevels2: [String]
    var dailyCheckInStreak: Int
}
