//
//  HealthKitManager.swift
//  peakmind-pt2
//
//  Created by Raj Jagirdar on 6/3/24.
//

import HealthKit
import Combine

import Foundation
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    let healthStore: HKHealthStore?

    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.healthStore = nil
            return
        }
        self.healthStore = HKHealthStore()
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = healthStore else {
            completion(false, NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."]))
            return
        }

        let readTypes = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ])

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
