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

    @IBAction func newLevel(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let levelDesignerController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelDesigner")
                as! LevelDesignViewController
        renderChildController(levelDesignerController)
    }

    private var levels: [LevelData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        Settings.loadBackground(view: view)

        loadSavedLevel()
        // Add single tap gesture for color selector
        let singleTapForLevel = UITapGestureRecognizer(target: self, action: #selector(handleLevelSelected(_:)))
        singleTapForLevel.delegate = self
        levelSelectorCollection.addGestureRecognizer(singleTapForLevel)

        levelSelectorCollection.collectionViewLayout = UICollectionViewFlowLayout()
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
        levels = LevelGame.retrieveLevels()
        levels.sort { $0.levelName! < $1.levelName! }
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
        guard let levelName = levels[indexPath.item].levelName else {
            return
        }

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let gameEngineController =
            storyBoard.instantiateViewController(
                withIdentifier: "gameEngine")
                as! GameEngineViewController

        // isRectGrid MUST be set before loadedLevel or else
        // bad things will happen
        guard let selectedLevel = LevelGame.retrieveLevel(levelName) else {
            fatalError("Level should be retrieval")
        }
        gameEngineController.setupLevel(level: selectedLevel)
        gameEngineController.isDualCannon = true
        renderChildController(gameEngineController)

        // For editing of level
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let levelDesignerController =
//            storyBoard.instantiateViewController(
//                withIdentifier: "levelDesigner")
//                as! LevelDesignViewController
//        levelDesignerController.loadGrid(levelName: levelName)
//        renderChildController(levelDesignerController)
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
        cell.setHighScore(Int(level.highscore))

        cell.layer.cornerRadius = 50
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 4
        return cell
    }
}

extension SelectLevelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding

        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 * 1.2)
    }
}
