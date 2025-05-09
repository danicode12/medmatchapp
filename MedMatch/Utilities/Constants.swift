import SwiftUI

enum Constants {
    // MARK: - UI Constants
    enum UI {
        static let standardPadding: CGFloat = 16.0
        static let smallPadding: CGFloat = 8.0
        static let largePadding: CGFloat = 24.0
        
        static let cornerRadius: CGFloat = 10.0
        static let buttonHeight: CGFloat = 50.0
        static let iconSize: CGFloat = 24.0
        
        static let animationDuration: Double = 0.3
    }
    
    // MARK: - API Constants
    enum API {
        static let baseURL = "https://api.medmatch.com"
        static let timeout: Double = 30.0
        
        enum Endpoints {
            static let doctors = "/doctors"
            static let appointments = "/appointments"
            static let reviews = "/reviews"
            static let users = "/users"
            static let auth = "/auth"
        }
    }
    
    // MARK: - Colors
    enum Colors {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let accent = Color("AccentColor")
        static let background = Color("BackgroundColor")
        static let text = Color("TextColor")
        static let success = Color.customGreen
        static let warning = Color.orange
        static let error = Color.red
    }
    
    // MARK: - Storage Keys
    enum StorageKeys {
        static let authToken = "authToken"
        static let userID = "userID"
        static let userProfile = "userProfile"
        static let savedDoctors = "savedDoctors"
        static let recentSearches = "recentSearches"
        static let appSettings = "appSettings"
    }
    
    // MARK: - Validation
    enum Validation {
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let passwordMinLength = 8
        static let phoneRegex = "^\\d{10}$"
        static let zipCodeRegex = "^\\d{5}$"
    }
    
    // MARK: - Time Formats
    enum TimeFormats {
        static let dateOnly = "MMM d, yyyy"
        static let timeOnly = "h:mm a"
        static let dateTime = "MMM d, yyyy 'at' h:mm a"
        static let shortDate = "MM/dd/yyyy"
        static let dayMonth = "MMM d"
        static let weekday = "EEEE"
    }
}
