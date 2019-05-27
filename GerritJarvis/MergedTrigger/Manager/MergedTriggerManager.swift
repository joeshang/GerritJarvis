//
//  MergedTriggerManager.swift
//  GerritJarvis
//
//  Created by Chuanren Shang on 2019/5/27.
//  Copyright © 2019 Chuanren Shang. All rights reserved.
//

import Cocoa

class MergedTriggerManager: NSObject {
    static let DefaultPath = "$PATH:/opt/local/bin:/usr/local/bin:"
    static let shared = MergedTriggerManager()

    var path: String?

    func triggerNameInFolder() -> [String] {
        guard let folder =  triggerFolder() else {
            return []
        }
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            return contents
        } catch {
            return []
        }
    }

    func saveTrigger(content: String, change: Change, completion: (Bool) -> Void) {
        guard let url = urlForFile(name: change.changeNumberKey()) else {
            completion(false)
            return
        }
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            var attributes = [FileAttributeKey : Any]()
            attributes[.posixPermissions] = 0o777
            do {
                try FileManager.default.setAttributes(attributes, ofItemAtPath: url.path)
                completion(true)
            } catch {
                completion(false)
            }
        } catch {
            completion(false)
        }
    }

    func fetchTrigger(change: Change) -> String? {
        guard let url = urlForFile(name: change.changeNumberKey()) else {
            return nil
        }
        do {
            return try String(contentsOf: url)
        } catch {
            return nil
        }
    }

    func hasTrigger(change: Change) -> Bool {
        let fileManager = FileManager.default
        guard let appFolder = triggerFolder() else {
            return false
        }
        var isDirectory: ObjCBool = false
        let path = appFolder.appendingPathComponent(change.changeNumberKey()).path
        return fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    }

    func callTrigger(change: Change) {
        guard let url = urlForFile(name: change.changeNumberKey()) else {
            return
        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let task = Process()
            let pipe = Pipe()
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.arguments = [ url.path ]
            task.standardOutput = pipe
            task.environment = [ "PATH":  self.path ?? MergedTriggerManager.DefaultPath ]
            task.terminationHandler = { process in
                let handle = pipe.fileHandleForReading
                let data = handle.readDataToEndOfFile()
                let printing = String(data: data, encoding: String.Encoding.utf8)
                print(printing!)
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {

                }
            }
            do {
                try task.run()
            } catch {
                return
            }

            task.waitUntilExit()
        }
    }

    private func urlForFile(name: String) -> URL? {
        let fileManager = FileManager.default
        guard let appFolder = triggerFolder() else {
            return nil
        }
        var isDirectory: ObjCBool = false
        let folderExists = fileManager.fileExists(atPath: appFolder.path,
                                                  isDirectory: &isDirectory)
        if !folderExists || !isDirectory.boolValue {
            do {
                try fileManager.createDirectory(at: appFolder,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                return nil
            }
        }

        let dataFileUrl = appFolder.appendingPathComponent(name)
        return dataFileUrl
    }

    private func triggerFolder() -> URL? {
        guard let folder = FileManager.default.urls(for: .applicationSupportDirectory,
                                                    in: .userDomainMask).first else {
            return nil
        }

        return folder.appendingPathComponent("GerritJarvis/MergedTrigger")
    }

}
