//
//  TodayViewController.swift
//  Shaneglish
//
//  Created by Laurin Brandner on 01/02/16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import NotificationCenter

private let spacing = CGPoint(x: 20, y: 20)

class TodayViewController: UIViewController {
    
    private lazy var entryManager = EntryManager()
    
    private var rx_disposeBag = DisposeBag()
    
    private var wordLabel: UILabel?
    private var meaningLabel: UILabel?
    
    private var exampleLabel: UILabel?
    
    // MARK: - View Lifecycle in
    
    override func loadView() {
        super.loadView()
        
        wordLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .boldSystemFontOfSize(UIFont.labelFontSize())
            label.textColor = .whiteColor()
            
            return label
        }()
        
        meaningLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFontOfSize(UIFont.labelFontSize())
            label.textColor = .whiteColor()
            
            return label
        }()
        
        exampleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = UIColor(white: 1, alpha: 0.7)
            label.font = .italicSystemFontOfSize(UIFont.systemFontSize())
            
            return label
        }()
        
        view.addSubview(wordLabel!)
        view.addSubview(meaningLabel!)
        view.addSubview(exampleLabel!)
        
        let priority = UILayoutPriorityRequired - 1
        constrain(view, wordLabel!, meaningLabel!, exampleLabel!) { view, wordLabel, meaningLabel, exampleLabel in
            wordLabel.left == view.left
            wordLabel.top == view.top + spacing.y ~ priority
            wordLabel.right == view.right - spacing.x
            meaningLabel.left == view.left
            meaningLabel.top == wordLabel.bottom + (spacing.y * (2/3)) ~ priority
            meaningLabel.right == view.right - spacing.x
            exampleLabel.left == view.left + spacing.x
            exampleLabel.top == meaningLabel.bottom + spacing.y ~ priority
            exampleLabel.right == view.right - spacing.x
            exampleLabel.bottom == view.bottom - spacing.y ~ priority
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        entryManager.getNewEntries().subscribeNext { newEntries in
            self.reloadContent()
        }.addDisposableTo(rx_disposeBag)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        wordLabel?.preferredMaxLayoutWidth = size.width - spacing.x
        meaningLabel?.preferredMaxLayoutWidth = size.width - spacing.x
        exampleLabel?.preferredMaxLayoutWidth = size.width - 2 * spacing.x
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    // MARK: - Content
    
    private func reloadContent() {
        let entry = entryManager.allEntries.first

        wordLabel?.text = entry?.word
        meaningLabel?.text = entry?.meaning
        exampleLabel?.text = entry?.example
    }
    
}

// MARK: - NCWidgetProviding
extension TodayViewController: NCWidgetProviding {
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        entryManager.getNewEntries().subscribe(onNext: { gotNewEntries in
            self.reloadContent()
            
            let result: NCUpdateResult = gotNewEntries ? .NewData : .NoData
            completionHandler(result)
        }, onError: { _ in
            completionHandler(.Failed)
        }, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: defaultMarginInsets.left, bottom: 0, right: 0)
    }
    
}
