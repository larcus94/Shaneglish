//
//  Gangsta.swift
//  Gangsta
//
//  Created by Laurin Brandner on 31/01/16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import Foundation
import Alamofire
import Kanna
import RxSwift

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM dd"
    
    return formatter
}()

struct Gangsta {
    
    static func getDailyEntries() -> Observable<[Entry]> {
        return Observable.create { observer in
            let URL = NSURL(string: "https://www.urbandictionary.com")!
            let request = Alamofire.request(.GET, URL).responseData { response in
                switch response.result {
                case .Success(let HTML):
                    observer.onNext(parseHTML(HTML))
                case .Failure(let error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
    private static func parseHTML(HTML: NSData) -> [Entry] {
        guard let document = Kanna.HTML(html: HTML, encoding: NSUTF8StringEncoding) else {
            return []
        }
        
        let words = document.xpath("//a[@class='word']")
        let meanings = document.xpath("//div[@class='meaning']")
        let examples = document.xpath("//div[@class='example']")
        let dateStrings = document.xpath("//div[@class='ribbon']")
        
        let count = min(words.count, min(meanings.count, examples.count))
        let trimCharacters = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        
        return (0 ..< count).flatMap { index in
            guard let word = words[index].text?.stringByTrimmingCharactersInSet(trimCharacters),
                   meaning = meanings[index].text?.stringByTrimmingCharactersInSet(trimCharacters),
                   example = examples[index].text?.stringByTrimmingCharactersInSet(trimCharacters),
                dateString = dateStrings[index].text?.stringByTrimmingCharactersInSet(trimCharacters) else {
                return nil
            }
            
            let date = dateFormatter.dateFromString(dateString) ?? today
            let components = calendar.components([.Month, .Day], fromDate: date)
            components.year = calendar.component(.Year, fromDate: today)
            let adaptedDate = calendar.dateFromComponents(components) ?? today
            
            return Entry(word: word, meaning: meaning, example: example, date: adaptedDate)
        }
    }
    
}
