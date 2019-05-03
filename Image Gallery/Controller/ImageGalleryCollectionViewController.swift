//
//  ImageGalleryCollectionViewController.swift
//  Image Gallery
//
//  Created by Redemax on 4/16/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import UIKit

protocol ImageGalleryCollectionViewControllerDelegate {
    func reloadImageGallery(_ imageGallery: ImageGallery, at index: Int)
}

class ImageGalleryCollectionViewController: UICollectionViewController {
    
    // MARK: UICollectionViewDataSource
    
    var imageGallery: ImageGallery! {
        didSet {
            collectionView.reloadData()
            title = imageGallery.title
        }
    }
    
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var delegate: ImageGalleryCollectionViewControllerDelegate?
    var currentIndex = 0
    
    private var animatedCell: [UICollectionViewCell] = []
    
    // MARK: Storyboard
    
    @IBOutlet weak var emptyImageGalleryView: UIView!
        
    @IBAction func deleteSelected() {
        if let selected = collectionView.indexPathsForSelectedItems {
            let items = selected.map { $0.item }.sorted().reversed()
            collectionView.performBatchUpdates({
                for item in items {
                    imageGallery?.removeItem(at: item)
                }
                collectionView.deleteItems(at: selected)
            }, completion: nil)
            delegate?.reloadImageGallery(imageGallery, at: currentIndex)
        }
        
        navigationController?.isToolbarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundView = emptyImageGalleryView
        collectionView.backgroundView?.isHidden = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        self.collectionView.delegate = self
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        collectionView.addGestureRecognizer(pinch)
        
        configureItemSize()
        
        navigationItem.leftBarButtonItem = editButtonItem        
        navigationController?.isToolbarHidden = true
    }
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            let scale = recognizer.scale
            print(scale)
            configureItemSize(with: scale)
        default:
            break
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let imageGallery = imageGallery, imageGallery.images.isEmpty {
            collectionView.backgroundView?.isHidden = false
        } else {
            collectionView.backgroundView?.isHidden = true
        }
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageGalleryCollectionViewCell
        
        if !animatedCell.contains(cell) {
            cell.alpha = 0.0
            
            UIView.animate(
            withDuration: 0.33) {
                cell.alpha = 1.0
            }
        }
        
        let url = imageGallery?.images[indexPath.row].url
        cell.urlOfImage = url
        cell.isEditing = isEditing
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            print(indexPath.row)
        } else {
            navigationController?.isToolbarHidden = false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0 {
            navigationController?.isToolbarHidden = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        configureItemSize()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        let indexPaths = collectionView.indexPathsForVisibleItems
        collectionView.allowsMultipleSelection = isEditing
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
        }
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageGalleryCollectionViewCell
            cell.isEditing = isEditing
        }
        
        if !editing {
            navigationController?.isToolbarHidden = true
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImageGalleryCollectionViewController: UICollectionViewDelegateFlowLayout {
    private func configureItemSize(with scale: CGFloat = 1.0) {
        let width = (view.frame.size.width - 60) / (3.0 * scale)
        flowLayout?.itemSize = CGSize(width: width, height: width)
        flowLayout?.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return flowLayout?.itemSize ?? CGSize(width: 300, height: 300)
    }
}

// MARK: - UICollectionViewDragDelegate

extension ImageGalleryCollectionViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let url = (collectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.urlOfImage, !isEditing {
            let convertedURL = url as NSURL
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: convertedURL))
            dragItem.localObject = convertedURL
            return [dragItem]
        }
        return []
    }
    
}

// MARK: - UICollectionViewDropDelegate

extension ImageGalleryCollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if (session.localDragSession?.localContext as? UICollectionView) == collectionView {
            return session.canLoadObjects(ofClass: NSURL.self) || session.canLoadObjects(ofClass: UIImage.self)
        }
        
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        if !isEditing {
            for item in coordinator.items {
                if let sourceIndexPath = item.sourceIndexPath {
                    if item.dragItem.localObject is NSURL {
                        collectionView.performBatchUpdates({
                            imageGallery.moveItem(at: sourceIndexPath.item, to: destinationIndexPath.item)
                            delegate?.reloadImageGallery(imageGallery, at: currentIndex)
                            collectionView.deleteItems(at: [sourceIndexPath])
                            collectionView.insertItems(at: [destinationIndexPath])
                        }, completion: nil)
                        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    }
                } else {
                    let placeholderContext = coordinator.drop(
                        item.dragItem,
                        to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                    item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                        DispatchQueue.main.async {
                            if let url = (provider as? URL)?.imageURL {
                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                    self.imageGallery.addItem(at: insertionIndexPath.item, with: url)
                                    self.delegate?.reloadImageGallery(
                                       self.imageGallery, at: self.currentIndex)
                                })
                            } else {
                                placeholderContext.deletePlaceholder()
                            }
                        }
                    }
                }
            }
        }
    }

}



