//
//  ViewController.swift
//  iOSGameHelper
//
//  Created by Presentation on 2020-11-20.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var addSingle: NSButton!
    @IBOutlet weak var addJoystick: NSButton!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var removeAllButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    var isStart = false {
        didSet {
            (Application.shared as? Application)?.isStart = isStart
            startButton.title = isStart ? "按（⎋）键退出" : "开始监听键盘"
            setLabel()
            view.window?.backgroundColor = isStart ? NSColor.systemRed : NSColor.windowBackgroundColor
            addSingle.isHidden = isStart
            addJoystick.isHidden = isStart
            removeAllButton.isHidden = isStart
            startButton.isEnabled = !isStart
        }
    }
    
    @IBAction func addSingle(_ sender: Any) {
        let singleWindow = NSSingleTouchWindow(windowNibName: NSNib.Name(describing: NSSingleTouchWindow.self))
        singleWindow.showWindow(self)
        singleWindow.delegate = self
        singleWindow.configureWithNewID()
        (Application.shared as? Application)?.controllingWindows.append(singleWindow)
        setLabel()
    }
    
    @IBAction func addJoystick(_ sender: Any) {
        let joystickTouchWindow = NSJoystickTouchWindow(windowNibName: NSNib.Name(describing: NSJoystickTouchWindow.self))
        joystickTouchWindow.showWindow(self)
        joystickTouchWindow.delegate = self
        joystickTouchWindow.configureWithNewID()
        (Application.shared as? Application)?.controllingWindows.append(joystickTouchWindow)
        setLabel()
    }
    
    @IBAction func removeAll(_ sender: Any) {
        (Application.shared as? Application)?.controllingWindows.forEach { (window) in
            window.close()
        }
        (Application.shared as? Application)?.controllingWindows = []
        setLabel()
    }
    
    func setLabel() {
        infoLabel.stringValue = isStart ? "正在监听键盘……" : "共有\((Application.shared as? Application)?.controllingWindows.count ?? 0)个映射"
    }
    
    @IBAction func start(_ sender: Any) {
        if !isStart, (Application.shared as? Application)?.controllingWindows.isEmpty == true {
            let alert = NSAlert()
            alert.messageText = "请添加键盘映射"
            alert.runModal()
            return
        }
        
        isStart = !isStart
        (Application.shared as? Application)?.controllingWindows.forEach { (window) in
            window.isStart = isStart
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (Application.shared as? Application)?.mainViewController = self
        
        let windows = (UserDefaults.standard.array(forKey: "allWindows") ?? []).compactMap({ (any) -> TouchWindow? in
            if let uuidString = any as? String {
                if uuidString.hasPrefix("joystick_") {
                    let joystickTouchWindow = NSJoystickTouchWindow(windowNibName: NSNib.Name(describing: NSJoystickTouchWindow.self))
                    joystickTouchWindow.showWindow(self)
                    joystickTouchWindow.configuewWithID(string: uuidString)
                    joystickTouchWindow.delegate = self
                    return joystickTouchWindow
                } else if uuidString.hasPrefix("single_") {
                    let singleWindow = NSSingleTouchWindow(windowNibName: NSNib.Name(describing: NSSingleTouchWindow.self))
                    singleWindow.showWindow(self)
                    singleWindow.configuewWithID(string: uuidString)
                    singleWindow.delegate = self
                    return singleWindow
                }
            }
            return nil
        })
        
        (Application.shared as? Application)?.controllingWindows = windows
        DispatchQueue.main.async {
            (Application.shared as? Application)?.showAllWindow()
        }
        setLabel()
    }
}

extension ViewController: TouchWindowDelegate {
    func windowControllerClose(windowController: NSWindowController) {
        (Application.shared as? Application)?.controllingWindows.removeAll {
            $0 === windowController
        }
        setLabel()
    }
}

protocol TouchWindow: NSWindowController {
    var id: String? { get }
    var isStart: Bool { set get }
    var isListening: Bool { set get }
    func fireDown(with event: NSEvent)
    func fireUp(with event: NSEvent)
}


protocol TouchWindowDelegate: class {
    func windowControllerClose(windowController: NSWindowController)
}
