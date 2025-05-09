import SwiftUI

struct Insurance: Identifiable {
    let id = UUID()
    let name: String
    let planType: String?
    
    init(name: String, planType: String? = nil) {
        self.name = name
        self.planType = planType
    }
    
    static var popularInsurances: [Insurance] {
        [
            Insurance(name: "Triple-S", planType: "PPO"),
            Insurance(name: "MCS", planType: "EPO"),
            Insurance(name: "First MEDICAL", planType: "HMO"),
            Insurance(name: "Humana", planType: "PPO")
        ]
    }
}
