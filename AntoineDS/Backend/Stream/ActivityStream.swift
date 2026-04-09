//
//  ActivityStream.swift
//  Antoine
//
//  Created by Serena on 25/11/2022
//

import Foundation


/// A type managing incoming log entires
class ActivityStream {
    
    private var activityStreamPtr: OpaquePointer? = nil
    
    weak var delegate: ActivityStreamDelegate?
    
    public init() {}
    
    var isStreaming: Bool = false
    
    static func enableShowPrivateData(_ newStatus: Bool) {
        var ourCurrentDiagFlags: UInt32 = 0
        
        // Not going to cache this value as a `static let` because `enableShowPrivateData` is prob just gonna run
        // 1 or 2 times through the app's lifetime
        let privateDataFlag: UInt32 = 1 << 24
        
        host_get_atm_diagnostic_flag(mach_host_self(), &ourCurrentDiagFlags)
        
        let kret: kern_return_t
        
        if newStatus {
            kret = host_set_atm_diagnostic_flag(mach_host_self(), ourCurrentDiagFlags | privateDataFlag)
        } else {
            kret = host_set_atm_diagnostic_flag(mach_host_self(), ourCurrentDiagFlags & ~privateDataFlag)
        }
        
        if kret != KERN_SUCCESS {
            NSLog("\(#function): Failed to set private data flag to \(newStatus ? "enabled" : "disabled"), error: \(String(cString: mach_error_string(kret)))")
        } else {
            NSLog("\(#function): successful")
        }
    }
    
    private var retryCount = 0
    private var currentOptions: StreamOption = []
    
    /// Start the Log Stream. Tries pid=-1 first, falls back to pid=getpid(), then pid=0
    func start(options: StreamOption) {
        // Cancel any existing stream first
        if let existing = activityStreamPtr {
            activityStreamPtr = nil
            os_activity_stream_cancel(existing)
        }
        currentOptions = options
        retryCount = 0
        startWithPid(-1, options: options)
    }
    
    private func startWithPid(_ pid: pid_t, options: StreamOption) {
        NSLog("[ActivityStream] start pid=%d options=0x%x retry=%d", pid, options.rawValue, retryCount)
        
        let messageHandler: os_activity_stream_block_t = { (entry, error) in
            self.delegate?.activityStream(didRecieveEntry: entry, error: error)
            return true
        }
        
        let currentPid = pid
        let eventBlock: os_activity_stream_event_block_t = { [weak self] stream, event in
            guard let self = self else { return }
            let streamEv = StreamEvent(rawValue: event)
            NSLog("[ActivityStream] event: %d pid=%d", event, currentPid)
            
            switch streamEv {
            case .started:
                self.isStreaming = true
                NSLog("[ActivityStream] STREAMING with pid=%d", currentPid)
            case .stopped, .failed:
                self.isStreaming = false
                // Auto-retry with different pid
                if self.retryCount < 3 {
                    self.retryCount += 1
                    let nextPid: pid_t
                    switch self.retryCount {
                    case 1: nextPid = getpid()
                    case 2: nextPid = 0
                    default:
                        // Try with minimal options
                        nextPid = getpid()
                    }
                    NSLog("[ActivityStream] retry %d with pid=%d", self.retryCount, nextPid)
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                        self.startWithPid(nextPid, options: self.retryCount >= 3 ? [] : self.currentOptions)
                    }
                    return
                }
            default: break
            }
            
            self.delegate?.activityStream(streamEventDidChangeTo: streamEv)
        }
        
        let activityStream = OpaquePointer(os_activity_stream_for_pid(pid, os_activity_stream_flag_t(options.rawValue), messageHandler))
        self.activityStreamPtr = activityStream
        os_activity_stream_set_event_handler(activityStream, eventBlock)
        os_activity_stream_resume(activityStream)
    }
    
    /// Cancel the log stream, if one is in work
    func cancel() {
        // Prevent retry after intentional cancel
        retryCount = 999
        isStreaming = false
        if let activityStream = activityStreamPtr {
            self.activityStreamPtr = nil
            os_activity_stream_cancel(activityStream)
        }
    }
    
}
