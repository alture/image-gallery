//
//  ImageGalleryTableViewController.swift
//  Image Gallery
//
//  Created by Redemax on 4/16/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    
    // MARK: - ImageGalleryTableViewControllerDataSource
    
    var imageGalleryDocuments = ImageGalleryDocuments()
    
    // MARK: - Storyboard
    
    @IBAction private func addItem(_ sender: UIBarButtonItem) {
        imageGalleryDocuments.addNewImageGallery()
        
        let indexPath = IndexPath(row: imageGalleryDocuments.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc private func tapHandler(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cell = recognizer.view as? TextFieldTableViewCell {
                cell.textField.isEnabled = true
            }
        default:
            break
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
    private func updateImageCVC(at indexPath: IndexPath) {
        if let cvc = splitDetailConcentrationViewController {
            cvc.imageGallery = imageGalleryDocuments.imageGalleryAtIndexPath(indexPath)
            cvc.delegate = self
            cvc.currentIndex = indexPath.row
        } else {
            performSegue(withIdentifier: "ShowImages", sender: indexPath)
        }
    }
    
    // MARK: - TableViewControllerDelegate, TableViewControllerDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageGalleryDocuments.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            if let customCell = cell as? TextFieldTableViewCell {
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
                tap.numberOfTapsRequired = 2
                customCell.addGestureRecognizer(tap)
                customCell.textField?.text = imageGalleryDocuments.getTitleOfDocumentAtIndexPath(indexPath)
                customCell.resignationHandler = { [weak self] in
                    if let text = customCell.textField.text {
                        self?.imageGalleryDocuments.renameTitleAtIndexPath(indexPath, with: text)
                        self?.updateImageCVC(at: indexPath)
                        customCell.textField.isEnabled = false
                        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RemovedCell", for: indexPath)
            let label = cell.viewWithTag(1000) as! UILabel
            label.text = imageGalleryDocuments.getTitleOfDocumentAtIndexPath(indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleForHeader: String?
    
        if section == 1 {
            titleForHeader = "Deleted Images"
        }

        return titleForHeader
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.imageGalleryDocuments.removeImageGalleyAtIndexPath(indexPath)
            let firstIndex = IndexPath(row: self.imageGalleryDocuments.count - 1, section: 0)
            self.updateImageCVC(at: firstIndex)
            tableView.reloadData()
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let restoreAction = UIContextualAction(style: .destructive, title: "Restore") { (action, view, completionHandler) in
            self.imageGalleryDocuments.restoreImageGalleryAtIndexPath(indexPath)
            tableView.reloadData()

//            tableView.performBatchUpdates({
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                let destinationIndexPath = IndexPath(row: self.items.count - 1, section: 0)
//                tableView.insertRows(at: [destinationIndexPath], with: .fade)
//            })
            completionHandler(true)
        }
        restoreAction.backgroundColor = UIColor.gray
        
        let configuration = UISwipeActionsConfiguration(actions: indexPath.section == 1 ? [restoreAction] : [])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1 {
            updateImageCVC(at: indexPath)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == "ShowImage"
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowImages" {
            if let indexPath = sender as? IndexPath {
                if let galleryCVC = segue.destination.contents as? ImageGalleryCollectionViewController {
                    galleryCVC.imageGallery = imageGalleryDocuments.imageGalleryAtIndexPath(indexPath)
                    galleryCVC.delegate = self
                    galleryCVC.currentIndex = indexPath.row
                }
            }
        }
    }

}

extension ImageGalleryTableViewController: ImageGalleryCollectionViewControllerDelegate {
    
    func reloadImageGallery(_ imageGallery: ImageGallery, at index: Int) {
        imageGalleryDocuments.updateImageGallery(imageGallery, at: index)
        tableView.reloadData()
    }
    
}

// MARK: - UISplitViewControllerDelegate

extension ImageGalleryTableViewController: UISplitViewControllerDelegate {
    
    private func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    private var splitDetailConcentrationViewController: ImageGalleryCollectionViewController? {
        let imageCVC: ImageGalleryCollectionViewController?
        if let navCon = splitViewController?.viewControllers.last as? UINavigationController {
            imageCVC = navCon.visibleViewController as? ImageGalleryCollectionViewController
            return imageCVC
        }
        
        return nil
    }
    
}
