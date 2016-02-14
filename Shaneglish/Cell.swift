//
//  Cell.swift
//  Shaneglish
//
//  Created by Laurin Brandner on 31/01/16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import UIKit
import Cartography

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("MM dd", options: 0, locale: NSLocale.currentLocale())
    
    return formatter
}()

class Cell: UICollectionViewCell {
    
    var entry: Entry? {
        didSet {
            wordLabel.text = entry?.word
            dateLabel.text = entry.map { dateFormatter.stringFromDate($0.date) }
            meaningLabel.text = entry?.meaning
            exampleLabel.text = entry?.example
        }
    }
    
    private let wordLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFontOfSize(20)
        label.textColor = UIColor(red: 20/255, green: 79/255, blue: 230/255, alpha: 1)
        
        return label
    }()
    
    private let meaningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFontOfSize(UIFont.labelFontSize())
        
        return label
    }()
    
    private let exampleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 44/255, green: 53/255, blue: 60/255, alpha: 1)
        label.font = .italicSystemFontOfSize(UIFont.systemFontSize())
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFontOfSize(UIFont.smallSystemFontSize())
        label.textAlignment = .Right
        
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.85, alpha: 1)
        
        return view
    }()
    
    override var highlighted: Bool {
        didSet {
            reloadBackgroundColor()
        }
    }
    
    override var selected: Bool {
        didSet {
            reloadBackgroundColor()
        }
    }

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        contentView.addSubview(wordLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(meaningLabel)
        contentView.addSubview(exampleLabel)
        contentView.addSubview(separatorView)
        
        let spacing = CGPoint(x: 20, y: 10)
        
        dateLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        
        constrain(contentView, wordLabel, dateLabel) { contentView, wordLabel, dateLabel in
            wordLabel.left == contentView.left + spacing.x
            wordLabel.top == contentView.top + 2 * spacing.y
            wordLabel.right == dateLabel.left
            dateLabel.right == contentView.right - spacing.x
            dateLabel.top == wordLabel.top
        }
        
        constrain(contentView, wordLabel, meaningLabel, exampleLabel) { contentView, wordLabel, meaningLabel, exampleLabel in
            meaningLabel.left == contentView.left + spacing.x
            meaningLabel.top == wordLabel.bottom + spacing.y
            meaningLabel.right == contentView.right - spacing.x
            exampleLabel.left == contentView.left + 2 * spacing.x
            exampleLabel.top == meaningLabel.bottom + 2 * spacing.y
            exampleLabel.right == contentView.right - spacing.x
            exampleLabel.bottom == contentView.bottom - 2 * spacing.y
        }
        
        constrain(contentView, separatorView) { contentView, separatorView in
            separatorView.left == contentView.left + spacing.x
            separatorView.right == contentView.right
            separatorView.bottom == contentView.bottom
            separatorView.height == 1
        }
    }
    
    // MARK: - Layout
    
    func preferredHeightForWidth(width: CGFloat) -> CGFloat {
        frame = CGRect(origin: CGPoint(), size: CGSize(width: width, height: UIScreen.mainScreen().bounds.height))
        layoutIfNeeded()
        
        wordLabel.preferredMaxLayoutWidth = wordLabel.frame.width
        meaningLabel.preferredMaxLayoutWidth = meaningLabel.frame.width
        exampleLabel.preferredMaxLayoutWidth = exampleLabel.frame.width
        
        return systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    // MARK: -
    
    private func reloadBackgroundColor() {
        backgroundColor = highlighted || selected ? UIColor(white: 0.94, alpha: 1) : .whiteColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        entry = nil
        separatorView.hidden = false
    }
    
}
