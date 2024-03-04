//
//  EventTap.swift
//  Dragula
//
//

import Foundation
import Cocoa
import AVFoundation

fileprivate var player: AVAudioPlayer?

fileprivate func initializePlayer(forResource:String, ofType: String) -> Optional<AVAudioPlayer> {
    guard let path = Bundle.main.path(forResource: forResource, ofType:ofType) else {
        return nil }
    let url = URL(fileURLWithPath: path)
    
    do {
        let player = try AVAudioPlayer(contentsOf: url)
        player.volume = 0.25;
        return player
    } catch {
    }
    
    return nil
}

class EventTap {
    // i wouldn't recommend you do this
    static var shared: Optional<EventTap> = nil
    
    private var eventTap: CFMachPort!
    private var selfPtr: Unmanaged<EventTap>!
    private var isDragging = false
    private var weight: Optional<Double> = nil
    private var isMultiSelecting = false
    //    var precomputedWeight: Optional<Double> = nil
    private var isDraggingItem = false
    private var isWindowDragging = false
    
    private var scrapePlayer: Optional<AVAudioPlayer>
    private var vineboomPlayer: Optional<AVAudioPlayer>
    private var clangPlayer: Optional<AVAudioPlayer>
    private var puffPlayer: Optional<AVAudioPlayer>

    var shouldPlaySound = false
    var windowDrag = false
    var enabled = true
    
    private var calculatingWeight = true
    private var weightCalculatedForDrag = false
    
    private var currentSelection = [URL]()
    
    init() {
        // you can convert an NSEvent.EventTypeMask to its raw value
        let eventMask: NSEvent.EventTypeMask = [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
        
        self.scrapePlayer = initializePlayer(forResource: "scrape", ofType: "wav")
        self.vineboomPlayer = initializePlayer(forResource: "vineboom", ofType: "mp3")
        self.clangPlayer = initializePlayer(forResource: "clang", ofType: "wav")
        self.puffPlayer = initializePlayer(forResource: "puff", ofType: "wav")

        // Need to keep this pointer around for a while until we're sure of being done,
        // or else EventTap gets freed and the event tap has a dangling pointer to it (??)
        selfPtr = Unmanaged.passRetained(self)
        
        eventTap = CGEvent.tapCreate(
            tap: CGEventTapLocation.cgSessionEventTap,
            place: CGEventTapPlacement.headInsertEventTap,
            options: CGEventTapOptions.defaultTap,
            eventsOfInterest: eventMask.rawValue,
            callback: { proxy, type, event, refcon in
                // Trick from https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
                let mySelf = Unmanaged<EventTap>.fromOpaque(refcon!).takeUnretainedValue()
                return mySelf.eventTapCallback(proxy: proxy, type: type, event: event, refcon: refcon)
            },
            userInfo: selfPtr.toOpaque())!
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
    
    func eventTapCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        if type == CGEventType.tapDisabledByUserInput {
            return nil
        }
        
        guard enabled else { return Unmanaged.passUnretained(event) }
        
        // get window position and role and make sure we are in Finder
        let position =  NSEvent.mouseLocation.screenFlipped
        guard let element = AXUIElement.systemWide.getElementAtPosition(position) else {
            return Unmanaged.passUnretained(event)
        }
        
        // get the Window
        guard let window = element.getValue(.window) else {
            return Unmanaged.passUnretained(event)
        }
        let windowElement = window as! AXUIElement
        
        // make sure this is Finder
        guard let pid = windowElement.getPid() else {
            return Unmanaged.passUnretained(event)
        }
        
        let app = NSRunningApplication(processIdentifier: pid)
        if app?.bundleIdentifier! != "com.apple.finder" {
            return Unmanaged.passUnretained(event)
        }
        
        
        switch type {
            
        case .leftMouseUp:
            if (isDraggingItem) {
                let prevWeight = self.weight
                DispatchQueue.global(qos:.default).async {
                    print("audio player")
                    if self.scrapePlayer?.isPlaying ?? false { self.scrapePlayer?.stop()}
                    guard self.shouldPlaySound else {return}
                    switch prevWeight {
                    case .some(let wgt) where wgt >= 4000:
                        self.vineboomPlayer?.play()
                        break
                    case .some(let wgt) where wgt > 250:
                        print("clang")
                        self.clangPlayer?.play()
                        break
                    default:
                        print("puff")
                        self.puffPlayer?.play()
                        break
                    }
                }
            }
            Weight.takeOff()
            weight = nil
            isDragging = false
            isDraggingItem = false
            calculatingWeight = false
            weightCalculatedForDrag = false
            isWindowDragging = false
            break
        case .leftMouseDown:
            //            isDragging = true
            weight = nil
            break
        case .leftMouseDragged:
            isDragging = true
            break
        default:
            break
        }
        
        // Handle window drags too
        if windowDrag && (element.getValue(.role) as! NSAccessibility.Role == .toolbar || element.getValue(.roleDescription) as! NSString == "text") {
            if type == .leftMouseDragged && self.weight == nil && !isWindowDragging && !isDraggingItem {
                calculatingWeight = true
                isWindowDragging = true
                Weight.apply(weight: 16_000)
                DispatchQueue.global(qos:.userInitiated).async {
                    print("window drag")
                    // this works because applescript won't block on window drag
                    let appleScriptResult = Scale.windowWeight()
                    print("Window drag result", appleScriptResult)
                    self.calculatingWeight = false
                    guard self.isDragging else { return }
                    self.weight = appleScriptResult
                    Weight.apply(weight: appleScriptResult)
                }
            }
        }
        
        
        if isMultiSelecting && type == .leftMouseUp {
            isMultiSelecting = false
            DispatchQueue.global(qos:.userInteractive).async {
                print("multi select")
                let appleScriptResult = Scale.paths()
                self.currentSelection = appleScriptResult
            }
            //          self.precomputedWeight = 32_000
            //            DispatchQueue.global(qos:.userInteractive).async {
            //                let appleScriptResult = Scale.aggregateWeight()
            //                                print(appleScriptResult)
            //                if (appleScriptResult > 75) {
            //                    self.precomputedWeight = appleScriptResult
            //                }
            //            }
        }
        
        // If there's a filename, that means we are dragging a file icon.
        if !isMultiSelecting && element.getValue(.filename) is NSString, let url = element.getValue(.url) as? URL {
            if !isDraggingItem {
                // clear current selection if what we selected is distinct from the current selection
                if !currentSelection.contains(url) {
                    // this may be overridden below
                    currentSelection = [url]
                }
            }
            //
            //            let parent = element.getValue(.parent) as! AXUIElement
            //            let grandParent = parent.getValue(.parent) as! AXUIElement
            //            let selectedChildren = grandParent.getValue(.selectedChildren)
            //
            //            if selectedChildren != nil {
            //                print((grandParent.getValue(.selectedChildren) as! NSArray).count)
            //            }
            
            switch type {
            case .leftMouseDown:
                if event.flags.contains(.maskCommand) || event.flags.contains(.maskShift) {
                    // this was a multi-select with cmd/shift
                    // calculate with applescript
                    DispatchQueue.global(qos:.userInteractive).async {
                        print("command/shift multi select")
                        let appleScriptResult = Scale.paths()
                        self.currentSelection = appleScriptResult
                    }
                }
                break
            case .leftMouseDragged:
                if !isWindowDragging && !isDraggingItem && weight == nil {
                    isDraggingItem = true
                    // apply optimistically-precomputed weight
                    //                if self.precomputedWeight != nil {
                    //                    Weight.apply(weight:precomputedWeight!)
                    //                    self.weight = self.precomputedWeight
                    //                    self.precomputedWeight = nil
                    //                    break
                    //                }
                    // an app is a directory too
                    if FileManager.default.isDirectory(url: url as URL) {
                        // Apply a guess at first
                        Weight.apply(weight: 16_000)
                        //                    // queue in background
                        //                    DispatchQueue.global(qos:.userInitiated).async {
                        //                        // this will run for an indeterminate amount of time.
                        //                        // if it's fast, then it will adjust to the correct weight.
                        //                        // otherwise, it will likely be max weight anyway!
                        //                        let fileSize = Scale.weight(ofUrl: url)
                        //                        self.calculatingWeight = false
                        //                        guard self.isDragging else { return }
                        //                        Weight.apply(weight:fileSize)
                        //                        self.weight = fileSize
                        //                    }
                    } else {
                        let fileSize = Scale.weight(ofUrl: url)
                        Weight.apply(weight:fileSize)
                    }
                    
                    self.calculatingWeight = true
                    
                    // now: queue for every selection
                    // queue in background
                    DispatchQueue.global(qos:.userInitiated).async {
                        print("file drag")
                        // this will run for an indeterminate amount of time.
                        // if it's fast, then it will adjust to the correct weight.
                        // otherwise, it will likely be max weight anyway!
                        let fileSize = self.currentSelection.map {url in Scale.weight(ofUrl: url)}.reduce(0.0) {(result, val) in result+val};
                        print(fileSize)
                        self.calculatingWeight = false
                        self.weightCalculatedForDrag = true 
                        guard self.isDraggingItem else { return }
                        Weight.apply(weight:fileSize)
                        self.weight = fileSize
                        
                        if fileSize > 1995.0 {
                            if !(self.scrapePlayer?.isPlaying ?? false) {
                                DispatchQueue.global(qos:.background).async {
                                    guard self.shouldPlaySound else {return}
                                    
                                    self.scrapePlayer?.numberOfLoops = -1
                                    self.scrapePlayer?.play()
                                }
                            }
                        }
                    }
                }
                //                if self.precomputedWeight != nil && self.weight != nil {
                //                    self.weight = self.precomputedWeight!
                //                    Weight.apply(weight:self.weight!)
                //                }
                break
            default:
                break
            }
        }
        
        // MARQUEE MULTISELECT
        // TODO compare this to .role
        switch(element.getValue(.roleDescription) as! NSString) {
        case "group", "collection", "section":
            // begin multi selecting
            if !isWindowDragging && !isMultiSelecting && !isDraggingItem && type == .leftMouseDragged {
                isMultiSelecting = true
            }
            break
        default:
            break
        }
        
        // If you don't return the event, it will be suppressed!
        return Unmanaged.passUnretained(event)
    }
    
    func done() {
        CGEvent.tapEnable(tap: self.eventTap, enable: false)
        
        // FIXME: Wait some random period of time and then manually free the
        // event tap pointer?
        // This whole thing is really weird and probably overthinking --
        // stems from the odd unused construction of the EventTap object at main.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let _ = self.selfPtr.autorelease()
        }
    }
}
