//
//  TableViewController.swift
//  Shaneglish
//
//  Created by Laurin Brandner on 31/01/16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import Whisper

private let refreshAnimationKey = "refreshAnimation"

class TableViewController: UICollectionViewController {
    
    private lazy var entryManager = EntryManager()
    
    private var rx_disposeBag = DisposeBag()
    
    private var prototypeCell: Cell?
    
    private var loading = false {
        didSet {
            reloadLoadingAnimation()
        }
    }
    
    private lazy var refreshButton: UIButton = {
        let image = UIImage(named: "Refresh")?.imageWithRenderingMode(.AlwaysTemplate)
        let button = UIButton()
        button.setImage(image, forState: .Normal)
        button.adjustsImageWhenDisabled = false
        button.tintColor = .whiteColor()
        button.sizeToFit()
        
        return button
    }()
    
    // MARK: - Initialization
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        rx_disposeBag = DisposeBag()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shaneglish"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
        refreshButton.addTarget(self, action: "refresh", forControlEvents: .TouchUpInside)
        
        collectionView?.backgroundColor = .whiteColor()
        
        let cellClass = Cell.self
        collectionView?.registerClass(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
        
        reloadCollectionView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Observable.just(()).delaySubscription(0.5, scheduler: MainScheduler.instance).subscribeNext {
            self.refresh()
        }.addDisposableTo(rx_disposeBag)
    }
    
    // MARK: - Content
    
    @objc private func refresh() {
        if refreshButton.layer.animationForKey(refreshAnimationKey) == nil {
            loading = true
            entryManager.getNewEntries().lastFor(0.5)
                .subscribe(onNext: { gotNewEntries in
                    if gotNewEntries {
                        self.reloadCollectionView()
                    }
                }, onError: { _ in
                    if let navigationController = self.navigationController {
                        let message = Message(title: "Yo, check ur interwebz", backgroundColor: .redColor())
                            Whisper(message, to: navigationController, action: .Show)
                        }
                    }, onCompleted: nil, onDisposed: {
                    self.loading = false
                }).addDisposableTo(rx_disposeBag)
        }
    }
    
    private func reloadCollectionView() {
        collectionView?.reloadData()
        
        if entryManager.allEntries.count > 0 {
            collectionView?.backgroundView = nil
        }
        else {
            let label = UILabel()
            label.text = "¯\\_(ツ)_/¯"
            label.font = .systemFontOfSize(22)
            label.textAlignment = .Center
            label.textColor = .lightGrayColor()
            
            collectionView?.backgroundView = label
        }
    }
    
    private func reloadLoadingAnimation() {
        let keyPath = "transform.rotation.z"
        let animation = CABasicAnimation(keyPath: keyPath)
        
        let fullRotation = 2 * M_PI
        let duration: CFTimeInterval = 0.5
        
        let currentRotation = refreshButton.layer.presentationLayer()?.valueForKeyPath(keyPath) as? Double ?? 0
        animation.fromValue = currentRotation
        animation.toValue = fullRotation
        
        if loading {
            animation.repeatCount = Float.infinity
            animation.duration = duration
        }
        else {
            let rotation = currentRotation > 0 ? fullRotation - currentRotation : (abs(currentRotation) + fullRotation)
            animation.duration = (rotation/fullRotation) * duration
        }
        
        refreshButton.layer.addAnimation(animation, forKey: refreshAnimationKey)
    }
    
}

// MARK: - UICollectionViewDataSource
extension TableViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entryManager.allEntries.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(Cell.self), forIndexPath: indexPath) as! Cell
        cell.entry = entryManager.allEntries[indexPath.item]
        cell.separatorView.hidden = indexPath.item  == entryManager.allEntries.count - 1
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension TableViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        if let URL = entryManager.allEntries[indexPath.item].URL {
            let controller = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
            controller.popoverPresentationController?.sourceView = collectionView
            
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                controller.popoverPresentationController?.sourceRect = cell.frame
            }
            
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TableViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if prototypeCell == nil {
            prototypeCell = prototypeCell ?? Cell(frame: collectionView.bounds)
        }
        
        prototypeCell!.entry = entryManager.allEntries[indexPath.item]
        
        let height = prototypeCell!.preferredHeightForWidth(collectionView.bounds.width)
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
}

extension Observable {
    
    private func lastFor(dueTime: MainScheduler.TimeInterval) -> Observable<E> {
        let observable: Observable<()> = .just(())
        let delay = observable.delaySubscription(dueTime, scheduler: MainScheduler.instance)
        return Observable.combineLatest(delay, self) { $1 }
    }
    
}
