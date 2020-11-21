//
//  NSJoystickTouchWindow.swift
//  iOSGameHelper
//
//  Created by Luke on 2020-11-20.
//

import Cocoa

class NSJoystickTouchWindow: NSWindowController, TouchWindow {
    @IBOutlet weak var topImage: NSStackView!
    @IBOutlet weak var bottomImage: NSStackView!
    @IBOutlet weak var leftImage: NSStackView!
    @IBOutlet weak var rightImage: NSStackView!
    
    @IBOutlet weak var topButton: NSButton!
    @IBOutlet weak var leftButton: NSButton!
    @IBOutlet weak var bottomButton: NSButton!
    @IBOutlet weak var rightButton: NSButton!
    
    var lastKeyDown = ""
    
    var source: CGEventSource?
    var id: String?
    weak var delegate: TouchWindowDelegate?
    
    var topKeyCode: UInt16? {
        didSet {
            saveWindow()
        }
    }
    
    var bottomKeyCode: UInt16? {
        didSet {
            saveWindow()
        }
    }
    
    var rightKeyCode: UInt16? {
        didSet {
            saveWindow()
        }
    }
    
    var leftKeyCode: UInt16? {
        didSet {
            saveWindow()
        }
    }
    
    var leftDownEvent: CGEvent?
    var leftUpEvent: CGEvent?
    
    var rightDownEvent: CGEvent?
    var rightUpEvent: CGEvent?
    
    var topDownEvent: CGEvent?
    var topUpEvent: CGEvent?
    
    var bottomDownEvent: CGEvent?
    var bottomUpEvent: CGEvent?
    
    var middleDownEvent: CGEvent?
    
    var isListening: Bool {
        set {
            if newValue == false {
                leftIsListening = newValue
                rightIsListening = newValue
                topIsListening = newValue
                bottomIsListening = newValue
            }
        }
        get {
            leftIsListening || rightIsListening || topIsListening || bottomIsListening
        }
    }
    
    var leftIsListening = false {
        didSet {
            leftButton.isEnabled = !leftIsListening
            if leftIsListening {
                leftButton.title = "设置按键……"
                (Application.shared as? Application)?.currentTouchWinidow = self
                return
            }
            guard let keyCode = self.leftKeyCode else {
                leftButton.title = "设置按键"
                return
            }
            
            guard let keyCodeString = keyMap[keyCode] else {
                leftButton.title = "未知"
                return
            }
            
            leftButton.title =  keyCodeString
        }
    }
    
    var rightIsListening = false {
        didSet {
            rightButton.isEnabled = !rightIsListening
            if rightIsListening {
                rightButton.title = "设置按键……"
                (Application.shared as? Application)?.currentTouchWinidow = self
                return
            }
            guard let keyCode = self.rightKeyCode else {
                rightButton.title = "设置按键"
                return
            }
            
            guard let keyCodeString = keyMap[keyCode] else {
                rightButton.title = "未知"
                return
            }
            
            rightButton.title =  keyCodeString
        }
    }
    
    var topIsListening = false {
        didSet {
            topButton.isEnabled = !topIsListening
            if topIsListening {
                topButton.title = "设置按键……"
                (Application.shared as? Application)?.currentTouchWinidow = self
                return
            }
            guard let keyCode = self.topKeyCode else {
                topButton.title = "设置按键"
                return
            }
            
            guard let keyCodeString = keyMap[keyCode] else {
                topButton.title = "未知"
                return
            }
            
            topButton.title =  keyCodeString
        }
    }
    
    var bottomIsListening = false {
        didSet {
            bottomButton.isEnabled = !bottomIsListening
            if bottomIsListening {
                bottomButton.title = "设置按键……"
                (Application.shared as? Application)?.currentTouchWinidow = self
                return
            }
            guard let keyCode = self.bottomKeyCode else {
                bottomButton.title = "设置按键"
                return
            }
            
            guard let keyCodeString = keyMap[keyCode] else {
                bottomButton.title = "未知"
                return
            }
            
            bottomButton.title =  keyCodeString
        }
    }
    
    var isStart = false {
        didSet {
            window?.setIsVisible(!isStart)
        }
    }
    
    var rightHitPoint: CGPoint {
        guard let windowOriginX = window?.frame.origin.x,
              let windowOriginY = window?.frame.origin.y,
              let screenHeight = window?.screen?.frame.height else { return .zero }
        return CGPoint(x: windowOriginX + rightImage.frame.origin.x + rightImage.frame.width / 2, y: screenHeight - windowOriginY - rightImage.frame.origin.y - rightImage.frame.height / 2)
    }
    
    var leftHitPoint: CGPoint {
        guard let windowOriginX = window?.frame.origin.x,
              let windowOriginY = window?.frame.origin.y,
              let screenHeight = window?.screen?.frame.height else { return .zero }
        return CGPoint(x: windowOriginX + leftImage.frame.origin.x + leftImage.frame.width / 2, y: screenHeight - windowOriginY - leftImage.frame.origin.y - leftImage.frame.height / 2)
    }
    
    var topHitPoint: CGPoint {
        guard let windowOriginX = window?.frame.origin.x,
              let windowOriginY = window?.frame.origin.y,
              let screenHeight = window?.screen?.frame.height else { return .zero }
        return CGPoint(x: windowOriginX + topImage.frame.origin.x + topImage.frame.width / 2, y: screenHeight - windowOriginY - topImage.frame.origin.y - topImage.frame.height / 2)
    }
    
    var bottomHitPoint: CGPoint {
        guard let windowOriginX = window?.frame.origin.x,
              let windowOriginY = window?.frame.origin.y,
              let screenHeight = window?.screen?.frame.height else { return .zero }
        return CGPoint(x: windowOriginX + bottomImage.frame.origin.x + bottomImage.frame.width / 2, y: screenHeight - windowOriginY - bottomImage.frame.origin.y - bottomImage.frame.height / 2)
    }
    
    var hitPoint: CGPoint {
        CGPoint(x: (leftHitPoint.x + rightHitPoint.x)/2, y: leftHitPoint.y)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        window?.title = ""
        window?.alphaValue = 1.0
        window?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.3)
        
        window?.delegate = self
        source = CGEventSource(stateID: .hidSystemState)
        
        repositionEvents()
        isListening = true
    }
    
    func fireDown(with event: NSEvent) {
        if leftIsListening {
            if keyMap.keys.contains(event.keyCode), event.keyCode != 53 {
                leftKeyCode = event.keyCode
                leftIsListening = false
            }
            leftIsListening = false
        } else if rightIsListening {
            if keyMap.keys.contains(event.keyCode), event.keyCode != 53 {
                rightKeyCode = event.keyCode
                rightIsListening = false
            }
            rightIsListening = false
        } else if topIsListening {
            if keyMap.keys.contains(event.keyCode), event.keyCode != 53 {
                topKeyCode = event.keyCode
                topIsListening = false
            }
            topIsListening = false
        } else if bottomIsListening {
            if keyMap.keys.contains(event.keyCode), event.keyCode != 53 {
                bottomKeyCode = event.keyCode
                bottomIsListening = false
            }
            bottomIsListening = false
        } else if isStart {
            if event.keyCode == leftKeyCode {
                if lastKeyDown != "leftDown" {
                    lastKeyDown = "leftDown"
                    self.middleDownEvent?.post(tap: .cghidEventTap)
                    usleep(100_000)
                    self.leftDownEvent?.post(tap: .cghidEventTap)
                } else {
                    self.leftDownEvent?.post(tap: .cghidEventTap)
                }
            } else if event.keyCode == rightKeyCode {
                if lastKeyDown != "rightDown" {
                    lastKeyDown = "rightDown"
                    self.middleDownEvent?.post(tap: .cghidEventTap)
                    usleep(100_000)
                    self.rightDownEvent?.post(tap: .cghidEventTap)
                } else {
                    self.rightDownEvent?.post(tap: .cghidEventTap)
                }
            } else if event.keyCode == topKeyCode {
                if lastKeyDown != "topDown" {
                    lastKeyDown = "topDown"
                    self.middleDownEvent?.post(tap: .cghidEventTap)
                    usleep(100_000)
                    self.topDownEvent?.post(tap: .cghidEventTap)
                } else {
                    self.topDownEvent?.post(tap: .cghidEventTap)
                }
            } else if event.keyCode == bottomKeyCode {
                if lastKeyDown != "bottomDown" {
                    lastKeyDown = "bottomDown"
                    self.middleDownEvent?.post(tap: .cghidEventTap)
                    usleep(100_000)
                    self.bottomDownEvent?.post(tap: .cghidEventTap)
                } else {
                    self.bottomDownEvent?.post(tap: .cghidEventTap)
                }
            }
        }
    }
    
    func fireUp(with event: NSEvent) {
        lastKeyDown = "up"
        if isStart {
            if event.keyCode == leftKeyCode {
                self.leftUpEvent?.post(tap: .cghidEventTap)
            } else if event.keyCode == rightKeyCode {
                self.rightUpEvent?.post(tap: .cghidEventTap)
            } else if event.keyCode == topKeyCode {
                self.topUpEvent?.post(tap: .cghidEventTap)
            } else if event.keyCode == bottomKeyCode {
                self.bottomUpEvent?.post(tap: .cghidEventTap)
            }
        }
    }
    
    @IBAction func top(_ sender: Any) {
        topIsListening = true
    }
    
    @IBAction func left(_ sender: Any) {
        leftIsListening = true
    }
    
    @IBAction func bottom(_ sender: Any) {
        bottomIsListening = true
    }
    
    @IBAction func right(_ sender: Any) {
        rightIsListening = true
    }
    
    func repositionEvents() {
        middleDownEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: hitPoint, mouseButton: .left)
        topDownEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: topHitPoint, mouseButton: .left)
        topUpEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: topHitPoint, mouseButton: .left)
        
        bottomDownEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: bottomHitPoint, mouseButton: .left)
        bottomUpEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: bottomHitPoint, mouseButton: .left)
        
        leftDownEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: leftHitPoint, mouseButton: .left)
        leftUpEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: leftHitPoint, mouseButton: .left)
        
        rightDownEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: rightHitPoint, mouseButton: .left)
        rightUpEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: rightHitPoint, mouseButton: .left)
        
        print("t \(topHitPoint)")
        print("b \(bottomHitPoint)")
        print("l \(leftImage.frame)")
        print("r \(topImage.frame)")
    }
    
    func configureWithNewID() {
        id = "joystick_\(UUID().uuidString)"
    }
    
    func configuewWithID(string: String) {
        let y = UserDefaults.standard.integer(forKey: "\(string)_y")
        let x = UserDefaults.standard.integer(forKey: "\(string)_x")
        let w = UserDefaults.standard.integer(forKey: "\(string)_w")
        let h = UserDefaults.standard.integer(forKey: "\(string)_h")
        let t = UserDefaults.standard.integer(forKey: "\(string)_t")
        let b = UserDefaults.standard.integer(forKey: "\(string)_b")
        let l = UserDefaults.standard.integer(forKey: "\(string)_l")
        let r = UserDefaults.standard.integer(forKey: "\(string)_r")
        window?.setFrame(NSRect(x: x, y: y, width: w, height: h), display: true, animate: false)
        id = string
        if t != 53 {
            topKeyCode = UInt16(t)
        }
        if l != 53 {
            leftKeyCode = UInt16(l)
        }
        if r != 53 {
            rightKeyCode = UInt16(r)
        }
        if b != 53 {
            bottomKeyCode = UInt16(b)
        }

        isListening = false
    }
    
    func saveWindow() {
        guard let id = self.id else { return }
        UserDefaults.standard.setValue(Int(window?.frame.minX ?? 0), forKey: "\(id)_x")
        UserDefaults.standard.setValue(Int(window?.frame.minY ?? 0), forKey: "\(id)_y")
        UserDefaults.standard.setValue(Int(window?.frame.width ?? 0), forKey: "\(id)_w")
        UserDefaults.standard.setValue(Int(window?.frame.height ?? 0), forKey: "\(id)_h")
        UserDefaults.standard.setValue(Int(topKeyCode ?? 53), forKey: "\(id)_t")
        UserDefaults.standard.setValue(Int(bottomKeyCode ?? 53), forKey: "\(id)_b")
        UserDefaults.standard.setValue(Int(leftKeyCode ?? 53), forKey: "\(id)_l")
        UserDefaults.standard.setValue(Int(rightKeyCode ?? 53), forKey: "\(id)_r")
    }
}

extension NSJoystickTouchWindow: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        delegate?.windowControllerClose(windowController: self)
        return true
    }
    
    func windowDidResize(_ notification: Notification) {
        repositionEvents()
        (Application.shared as? Application)?.showAllWindow()
        saveWindow()
    }
    
    func windowDidMove(_ notification: Notification) {
        repositionEvents()
        (Application.shared as? Application)?.showAllWindow()
        saveWindow()
    }
}
