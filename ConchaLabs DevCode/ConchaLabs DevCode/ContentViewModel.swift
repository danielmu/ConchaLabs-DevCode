//
//  ContentViewModel.swift
//  ConchaLabs DevCode
//
//  Created by Dan Muana on 1/25/22.
//

import Foundation

final class ViewModel: ObservableObject {
    
    @Published var ticks: [Double] = []
    @Published var isComplete: Bool = false
    @Published var sliderIndex: Int = 0
    @Published var atTick: Double = 0.0
    @Published var selectedTicks: [Double] = []
    @Published var selectedIndex: [Int] = []
    @Published var arrCount = 14
    @Published var sessionID: Int64 = -1
    
    func startFetchTicks() {
        Network.shared.setPath(Network.shared.PATH_START)
        Network.shared.setChoice("start")
        Network.shared.setSessionID(Int64(-1))
        DispatchQueue.main.async {
            self.isComplete = false
        }
    }
    
    func nextFetchTicks(choice: String, sessionID: Int64) {
        Network.shared.setPath(Network.shared.PATH_NEXT)
        Network.shared.setChoice(choice)
        Network.shared.setSessionID(sessionID)
    }
    
    func getTicks() {
        Network.shared.fetchTicks(onSuccess: { (result) in
            if let myresult = result as? Ticks {
                DispatchQueue.main.async {
                    self.ticks = myresult.ticks
                    self.sessionID = myresult.sessionID
                }
            }
            if let myresult = result as? Completed {
                DispatchQueue.main.async {
                    self.isComplete = myresult.complete == "true"
                }
            }
        }) { (errorMessage) in
            debugPrint(errorMessage)
            if errorMessage == "session is invalid" {
                self.startFetchTicks()
                self.getTicks()
            }
        }
    }
}
