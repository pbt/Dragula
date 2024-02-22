//
//  Scale.swift
//  Dragula
//
//

import Foundation
import PointerKit

fileprivate let script = """
set theSize to 0

tell application "Finder"
    set theSelection to the selection as alias list
    repeat with theItem in theSelection
        set theInfo to (info for theItem)
        set theSize to theSize + (size of theInfo)
    end repeat
end tell
return theSize

"""

fileprivate let windowscript = """
set theSize to 0

tell application "Finder"
    if exists window 1 then
        set theSelection to the target of Finder window 1 as alias
        set theInfo to (info for theSelection)
        set theSize to (size of theInfo)
    end if
end tell

return theSize
"""

fileprivate let selectscript = """
set thePaths to ""

tell application "Finder"
    set theSelection to the selection as alias list
    repeat with theItem in theSelection
        set thePaths to thePaths & POSIX path of theItem & ":"
    end repeat
    return thePaths
end tell
"""

fileprivate let osascript = "/usr/bin/osascript"

enum Scale {
    static func weight(ofUrl url: URL) -> Double {
        Double(FileManager.default.size(ofUrl: url)).toNormalizedResolutionValue()
    }
    
    static func windowWeight() -> Double {
        let task = Process()
        task.executableURL = URL(filePath: osascript)
        task.arguments = ["-e", windowscript]
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        do {
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = Double(String(decoding: outputData, as: UTF8.self).trimmingCharacters(in:.whitespacesAndNewlines))
            switch output {
            case .some(let size):
                return size.toNormalizedResolutionValue()
            default:
                return 0.0.toNormalizedResolutionValue()
            }
        } catch {
        }
        return 0.0.toNormalizedResolutionValue()
    }
    static func aggregateWeight() -> Double {
        let task = Process()
        task.executableURL = URL(filePath: osascript)
        task.arguments = ["-e", script]
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        do {
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = Double(String(decoding: outputData, as: UTF8.self).trimmingCharacters(in:.whitespacesAndNewlines))
            switch output {
            case .some(let size):
                return size.toNormalizedResolutionValue()
            default:
                return 0.0.toNormalizedResolutionValue()
            }
        } catch {
        }
        return 0.0.toNormalizedResolutionValue()
    }
    static func paths() -> [URL] {
        let task = Process()
        task.executableURL = URL(filePath: osascript)
        task.arguments = ["-e", selectscript]
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        do {
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outputData, as: UTF8.self).trimmingCharacters(in:.whitespacesAndNewlines)
            return output.split(separator: ":").map {(path) -> URL in URL(filePath: String(path))}
        } catch {
        }
        return []
    }
}
