import Foundation

enum AnalyticsEvent: String {
    case appOpen = "app_open"
    case screenView = "screen_view"
    case buttonClick = "button_click"
    case search = "search"
    case login = "login"
    case signup = "signup"
    case logout = "logout"
    case bookAppointment = "book_appointment"
    case cancelAppointment = "cancel_appointment"
    case rescheduleAppointment = "reschedule_appointment"
    case saveFavoriteDoctor = "save_favorite_doctor"
    case removeDoctor = "remove_doctor"
    case submitReview = "submit_review"
    case error = "error"
}

protocol AnalyticsServiceProtocol {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
    func logScreenView(_ screenName: String, parameters: [String: Any]?)
    func logError(_ error: Error, parameters: [String: Any]?)
    func setUserID(_ userID: String)
    func clearUserID()
}

class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    private init() {
        // Initialize any analytics SDKs here
        setupAnalytics()
    }
    
    private func setupAnalytics() {
        // In a real app, you would set up Firebase Analytics, Mixpanel, etc.
        print("Analytics service initialized")
    }
    
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        // In a real app, you would send this to your analytics provider
        print("📊 Analytics event: \(event.rawValue), parameters: \(parameters ?? [:])")
    }
    
    func logScreenView(_ screenName: String, parameters: [String: Any]? = nil) {
        var params = parameters ?? [:]
        params["screen_name"] = screenName
        logEvent(.screenView, parameters: params)
    }
    
    func logError(_ error: Error, parameters: [String: Any]? = nil) {
        var params = parameters ?? [:]
        params["error_description"] = error.localizedDescription
        logEvent(.error, parameters: params)
    }
    
    func setUserID(_ userID: String) {
        // Set user ID in analytics SDK
        print("📊 Analytics user ID set: \(userID)")
    }
    
    func clearUserID() {
        // Clear user ID in analytics SDK
        print("📊 Analytics user ID cleared")
    }
}

