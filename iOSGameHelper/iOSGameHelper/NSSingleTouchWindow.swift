//
//  NSSingleTouchWindow.swift
//  iOSGameHelper
//
//  Created by Luke on 2020-11-20.
//

import Cocoa

class NSSingleTouchWindow: NSWindowController, TouchWindow {
    @IBOutlet weak var keyCodebutton: NSButton!
    
    var id: String?
    weak var delegate: TouchWindowDelegate?
    
    var keyCode: UInt16? {
        didSet {
            saveWindow()
        }
    }
    
    var downEvent: CGEvent?
    var upEvent: CGEvent?
    var source: CGEventSource?
    
    var isListening = false {
        didSet {
            keyCodebutton.isEnabled = !isListening
            if isListening {
                keyCodebutton.title = "设置按键……"
                (Application.shared as? Application)?.currentTouchWinidow = self
                return
            }
            guard let keyCode = self.keyCode else {
                keyCodebutton.title = "设置按键"
                return
            }
            
            guard let keyCodeString = keyMap[keyCode] else {
                keyCodebutton.title = "未知"
                return
            }
            
            keyCodebutton.title =  keyCodeString
        }
    }
    
    var isStart = false {
        didSet {
            window?.setIsVisible(!isStart)
        }
    }
    
    var hitPoint: CGPoint {
        guard let windowOriginX = window?.frame.origin.x,
              let windowOriginY = window?.frame.origin.y,
              let windowWidth = window?.frame.width,
              let windowHeight = window?.frame.height,
              let screenHeight = window?.screen?.frame.height else { return .zero }
        return CGPoint(x: windowOriginX + windowWidth / 2, y: screenHeight - windowOriginY - windowHeight / 2)
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
        if isListening {
            if keyMap.keys.contains(event.keyCode), event.keyCode != 53 {
                keyCode = event.keyCode
                isListening = false
            }
            isListening = false
        } else if isStart, event.keyCode == keyCode {
            self.downEvent?.post(tap: .cghidEventTap)
            print(keyMap[event.keyCode])
        }
    }
    
    func fireUp(with event: NSEvent) {
        if isStart, event.keyCode == keyCode {
            print(keyMap[event.keyCode])
            self.upEvent?.post(tap: .cghidEventTap)
        }
    }
    
    @IBAction func setKeyButtonTapped(_ sender: Any) {
        isListening = true
    }
    
    func repositionEvents() {
        downEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: hitPoint, mouseButton: .left)
        upEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: hitPoint, mouseButton: .left)
    }
    
    func configureWithNewID() {
        id = "single_\(UUID())"
    }
    
    func configuewWithID(string: String) {
        let key = UserDefaults.standard.integer(forKey: string)
        let y = UserDefaults.standard.integer(forKey: "\(string)_y")
        let x = UserDefaults.standard.integer(forKey: "\(string)_x")
        window?.setFrameOrigin(NSPoint(x: x, y: y))
        id = string
        if key != 53 {
            keyCode = UInt16(key)
        }
        isListening = false
    }
    
    func saveWindow() {
        guard let id = self.id else { return }
        UserDefaults.standard.setValue(Int(window?.frame.minX ?? 0), forKey: "\(id)_x")
        UserDefaults.standard.setValue(Int(window?.frame.minY ?? 0), forKey: "\(id)_y")
        UserDefaults.standard.setValue(Int(keyCode ?? 53), forKey: id)
    }
}



extension NSSingleTouchWindow: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        delegate?.windowControllerClose(windowController: self)
        return true
    }
    
    func windowDidResize(_ notification: Notification) {
        repositionEvents()
        (Application.shared as? Application)?.showAllWindow()
    }
    
    func windowDidMove(_ notification: Notification) {
        repositionEvents()
        (Application.shared as? Application)?.showAllWindow()
        saveWindow()
    }
}

var keyMap: [UInt16: String] = [29:"0",
              18:"1",
              19:"2",
              20:"3",
              21:"4",
              23:"5",
              22:"6",
              26:"7",
              28:"8",
              25:"9",
              0:"A",
              11:"B",
              8:"C",
              2:"D",
              14:"E",
              3:"F",
              5:"G",
              4:"H",
              34:"I",
              38:"J",
              40:"K",
              37:"L",
              46:"M",
              45:"N",
              31:"O",
              35:"P",
              12:"Q",
              15:"R",
              1:"S",
              17:"T",
              32:"U",
              9:"V",
              13:"W",
              7:"X",
              16:"Y",
              6:"Z",
              10:"§",
              50:"`",
              27:"-",
              24:"=",
              33:"[",
              30:"]",
              41:";",
              39:"'",
              43:",",
              47:".",
              44:"/",
              42:"\\",
              82:"0",
              83:"1",
              84:"2",
              85:"3",
              86:"4",
              87:"5",
              88:"6",
              89:"7",
              91:"8",
              92:"9",
              65:".",
              67:"*",
              69:"+",
              75:"/",
              78:"-",
              81:"=",
              71:"⌧",
              76:"⌤",
              49:"␣",
              36:"⏎",
              48:"⇥",
              51:"⌫",
              117:"⌦",
              52:"␊",
              53:"⎋",
              55:"⌘",
              56:"⇧",
              57:"⇪",
              58:"⌥",
              59:"⌃",
              60:"⇧",
              61:"⌥",
              62:"⌃",
              63:"fn",
              122:"F1",
              120:"F2",
              99:"F3",
              118:"F4",
              96:"F5",
              97:"F6",
              98:"F7",
              100:"F8",
              101:"F9",
              109:"F10",
              103:"F11",
              111:"F12",
              105:"F13",
              107:"F14",
              113:"F15",
              106:"F16",
              64:"F17",
              79:"F18",
              80:"F19",
              90:"F20",
              72:"VolumeUp",
              73:"VolumeDown",
              74:"Mute",
              114:"Help/Insert",
              115:"Home",
              119:"End",
              116:"PageUp",
              121:"PageDown",
              123:"←",
              124:"→",
              125:"↓",
              126:"↑"]
