//
//  Application.swift
//  iOSGameHelper
//
//  Created by Luke on 2020-11-20.
//

import Cocoa

@objc(Application)
class Application: NSApplication {
    var isStart: Bool = false
    var currentTouchWinidow: TouchWindow? {
        didSet {
            if currentTouchWinidow !== oldValue {
                oldValue?.isListening = false
            }
        }
    }
    var mainViewController: ViewController?
    var controllingWindows: [TouchWindow] = [] {
        didSet {
            UserDefaults.standard.setValue(controllingWindows.compactMap { $0.id }, forKey: "allWindows")
            print(controllingWindows.count)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
    }
    
    override func finishLaunching() {
        super.finishLaunching()
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { (event) in
            guard self.isStart else { return }
            self.controllingWindows.forEach { (window) in
                window.fireDown(with: event)
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.keyUp]) { (event) in
            guard self.isStart else { return }
            self.controllingWindows.forEach { (window) in
                window.fireUp(with: event)
            }
        }
    }
    
    override func sendEvent(_ event: NSEvent) {
        if currentTouchWinidow?.isListening == true {
            if event.type == .keyDown {
                currentTouchWinidow?.fireDown(with: event)
            } else if event.type == .keyUp {
                currentTouchWinidow?.fireUp(with: event)
            }
        } else if isStart {
            if event.type == .keyDown {
                if event.keyCode == 53 {
                    mainViewController?.start(self)
                }
                self.controllingWindows.forEach { (window) in
                    window.fireDown(with: event)
                }
            } else if event.type == .keyUp {
                self.controllingWindows.forEach { (window) in
                    window.fireUp(with: event)
                }
            }
            return
        }
        
        super.sendEvent(event)
    }
    
    func showAllWindow() {
        controllingWindows.forEach { (window) in
            window.window?.orderFrontRegardless()
        }
    }
}
