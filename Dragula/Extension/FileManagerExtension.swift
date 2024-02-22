//
//  FileManagerExtension.swift
//  Dragula
//
//

import Foundation

extension FileManager {
    func size(ofUrl url: URL) -> UInt64 {
        let isDirectoryResourceValue: URLResourceValues
        do {
            isDirectoryResourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
            if isDirectoryResourceValue.isDirectory ?? false {
                return sizeOfDirectory(url:url)
            } else {
                return sizeOfFile(url:url) ?? 0
            }
        } catch {
            
        }
        return 0
    }
    
    func sizeOfFile(url: URL) -> UInt64? {
        guard let attrs = try? attributesOfItem(atPath: url.path) else {
            return nil
        }
        
        return attrs[.size] as? UInt64
    }

    func isDirectory(url: URL) -> Bool {
        let isDirectoryResourceValue: URLResourceValues
        do {
            isDirectoryResourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
            return isDirectoryResourceValue.isDirectory == true
        } catch {
            return false
        }
    }
    
    func sizeOfDirectory(url: URL) -> UInt64 {
        let contents: [URL]
        do {
            contents = try contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])
        } catch {
            return 0
        }

        var size: UInt64 = 0

        for url in contents {
            let isDirectoryResourceValue: URLResourceValues
            do {
                isDirectoryResourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
            } catch {
                continue
            }
        
            if isDirectoryResourceValue.isDirectory == true {
                size += sizeOfDirectory(url: url)
            } else {
                let fileSizeResourceValue: URLResourceValues
                do {
                    fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
                } catch {
                    continue
                }
            
                size += UInt64(fileSizeResourceValue.fileSize ?? 0)
            }
        }
        return size
    }
}
