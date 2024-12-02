//
//  NetworkMonitor.swift
//  Movie App
//
//  Created by Shivendra on 25/09/24.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private var isMonitoring = false
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    deinit {
        stopMonitoring()
    }
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    func startMonitoring() {
        if !isMonitoring {
            let queue = DispatchQueue.global(qos: .background)
            monitor.start(queue: queue)
            isMonitoring = true
        }
    }
    
    func stopMonitoring() {
        if isMonitoring {
            monitor.cancel()
            isMonitoring = false
        }
    }
}

