//
//  Entry.swift
//  UrbanDictionary
//
//  Created by Laurin Brandner on 31/01/16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import Foundation

private let wordKey = "word"
private let meaningKey = "meaning"
private let exampleKey = "example"
private let dateKey = "date"

struct Entry {
    
    let word: String
    
    let meaning: String
    
    let example: String
    
    let date: NSDate
    
    var URL: NSURL {
        let encodedWord = word.componentsSeparatedByCharactersInSet(.whitespaceAndNewlineCharacterSet()).joinWithSeparator("+")
        return NSURL(string: "http://www.urbandictionary.com/define.php?term=\(encodedWord)")!
    }
    
    var payload: [String: AnyObject] {
        return [wordKey: word, meaningKey: meaning, exampleKey: example, dateKey: date.timeIntervalSince1970]
    }
    
    init(word: String, meaning: String, example: String, date: NSDate) {
        self.word = word
        self.meaning = meaning
        self.example = example
        self.date = date
    }
    
    init?(payload: [String: AnyObject]) {
        guard let word = payload[wordKey] as? String,
               meaning = payload[meaningKey] as? String,
               example = payload[exampleKey] as? String,
             timestamp = payload[dateKey] as? NSTimeInterval else {
            return nil
        }
        
        self.init(word: word, meaning: meaning, example: example, date: NSDate(timeIntervalSince1970: timestamp))
    }
    
}

extension Entry: Equatable {
    
    var hashValue: Int {
        return word.hashValue ^ meaning.hashValue ^ example.hashValue ^ date.hashValue
    }
    
}

func ==(lhs: Entry, rhs: Entry) -> Bool {
    return lhs.word == rhs.word && lhs.meaning == rhs.meaning && lhs.example == rhs.example && lhs.date == rhs.date
}
