import Foundation
import AppMetricaCore

struct AnalyticsService {

    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "85e844ed-d348-43c2-bd2f-ef6293002c23") else { return }

        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
            print("Analytics Event: \(event), Parameters: \(params)")
        })
    }
}
