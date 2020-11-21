//
//  MainWindow.swift
//  iOSGameHelper
//
//  Created by Luke on 2020-11-20.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    override func windowDidLoad() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            print("Access Not Enabled")
            return
        }
        window?.delegate = self
    }
    func windowDidMove(_ notification: Notification) {
        (Application.shared as? Application)?.showAllWindow()
    }
    
    func windowWillClose(_ notification: Notification) {
        Application.shared.terminate(self)
    }
}
