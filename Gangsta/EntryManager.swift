//
//  EntryManager.swift
//  UrbanDictionary
//
//  Created by Laurin Brandner on 31/01/16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import Foundation
import RxSwift

private let maxEntryCount = 50
private let entryKey = "entries"

class EntryManager {
    
    private let defaults = NSUserDefaults(suiteName: "group.ch.laurinbrandner.Shaneglish") ?? NSUserDefaults.standardUserDefaults()
    
    private(set) var allEntries = [Entry]()
    
    // MARK: - Initialization
    
    init() {
        if let entryPayloads = defaults.arrayForKey(entryKey) as? [[String: AnyObject]] {
            allEntries = entryPayloads.flatMap { Entry(payload: $0) }
        }
    }
    
    // MARK: -
    
    private func addEntries(newEntries: [Entry]) -> Bool {
        var entries = allEntries
        for (index, entry) in newEntries.enumerate() {
            if !entries.contains(entry) {
                entries.insert(entry, atIndex: index)
            }
        }
        entries = Array(entries.prefix(maxEntryCount))
        
        if entries != allEntries {
            allEntries = entries
            
            defaults.setObject(entries.map { $0.payload }, forKey: entryKey)
            defaults.synchronize()
            
            return true
        }
        
        return false
    }
    
    func getNewEntries() -> Observable<Bool> {
        return Gangsta.getDailyEntries().map { self.addEntries($0) }
    }
    
}
