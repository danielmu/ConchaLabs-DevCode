//
//  Network.swift
//  ConchaLabs DevCode
//
//  Created by Dan Muana on 1/25/22.
//

import Foundation

class Network {
    static let shared = Network()

    // MARK: - Network Service Variables
    private let HOST = "iostestserver-su6iqkb5pq-uc.a.run.app"
    private let SCHEME = "https"
    private let METHOD = "POST"
    
    private var CHOICE = "8" ///"start"
    private var SESSION_ID: Int64 = -1
    private var PATH = "" ///"start || next"
    private var URL_BUILT = ""
    
    let PATH_START = "/test_start"
    let PATH_NEXT = "/test_next"
    
    // MARK: - Network Service Setup
    let session = URLSession(configuration: .default)

    func setChoice(_ choice: String) {
        CHOICE = choice
    }
    
    func setSessionID(_ id: Int64) {
        SESSION_ID = id
    }
    
    func setPath(_ path: String) {
        PATH = path
    }
    
    private func buildURL() -> String {
        URL_BUILT = SCHEME + "://" + HOST + PATH
        
        return URL_BUILT.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? URL_BUILT
    }
    
    // fetch Ticks - bruteforce
    func fetchTicks(onSuccess: @escaping (AnyObject) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: buildURL()) else {
            onError("Failed to build URL")
            
            return
        }
        
        let parameters: [String: Any] = ["session_id": SESSION_ID, "choice": CHOICE]
        
        var request = URLRequest(url: url)
        request.httpMethod = METHOD
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
                    
                    if json["error"] != nil {
                        onError("session is invalid")
                        return
                    }
                    if json["complete"] != nil {
                        let complete = try JSONDecoder().decode(Completed.self, from: data)
                        onSuccess(complete as AnyObject)
                    } else {
                        let ticks = try JSONDecoder().decode(Ticks.self, from: data)
                        onSuccess(ticks as AnyObject)
                    }
                } catch {
                    print(error)
                    print(response.debugDescription)
                }
            }
        }.resume()
    }
}
