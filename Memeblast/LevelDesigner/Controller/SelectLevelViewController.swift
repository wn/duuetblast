// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A view controller to control selection of saved levels. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit
import CoreData

class SelectLevelViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var levelSelectorCollection: UICollectionView!

    let levelSelectionCellIdentifier = "levelSelectionCell"

    private var levels: [LevelData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        Settings.loadBackground(view: view)

        loadSavedLevel()
        // Add single tap gesture for color selector
        let singleTapForLevel = UITapGestureRecognizer(target: self, action: #selector(handleLevelSelected(_:)))
        singleTapForLevel.delegate = self
        levelSelectorCollection.addGestureRecognizer(singleTapForLevel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure that we update highscores and newly saved level
        loadSavedLevel()
        levelSelectorCollection.reloadData()
    }

    /// Load saved levels and show in UITableView
    /// Read from database and show name of all saved levels in UITableView.
    func loadSavedLevel() {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LevelData")
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request) as! [LevelData]
            levels = result
        } catch {
            return
        }

        levelSelectorCollection?.reloadData()
    }
}

extension SelectLevelViewController {
    /// Gesture to set load selected level.
    @objc
    func handleLevelSelected(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.levelSelectorCollection)
        guard let indexPath = (self.levelSelectorCollection?.indexPathForItem(at: point)) else {
            return
        }

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let selectedLevel = levels[indexPath.item]
        let levelDesignerController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelDesigner")
                as! LevelDesignViewController
        guard let levelName = selectedLevel.levelName else {
            return
        }
        levelDesignerController.loadGrid(levelName: levelName)
        renderChildController(levelDesignerController)
    }

    /// Button to create a new level.
    @IBAction func renderMainMenu(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC =
            storyBoard.instantiateViewController(
                withIdentifier: "mainMenu")
                as! StartGameController
        derenderChildController(false)
        renderChildController(newVC)
    }
}

extension SelectLevelViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count
    }

    /// Make a cell for each cell index path
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: levelSelectionCellIdentifier,
            for: indexPath as IndexPath)
            as! LevelSelectionCollectionViewCell
        let level = levels[indexPath.item]
        cell.setLevelName(name: level.levelName)
        cell.setImage(level.screenshot)
        levelSelectorCollection.bringSubviewToFront(cell)
        return cell
    }
}
