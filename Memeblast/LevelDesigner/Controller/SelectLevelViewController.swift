// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A view controller to control selection of saved levels. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit
import CoreData
import AVFoundation

class SelectLevelViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet private var levelSelectorCollection: UITableView!
    let levelSelectionCellIdentifier = "levelSelectionCell"

    private var levels: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedLevel()
        // Add single tap gesture for color selector
        let singleTapForLevel = UITapGestureRecognizer(target: self, action: #selector(handleLevelSelected(_:)))
        singleTapForLevel.delegate = self
        levelSelectorCollection.addGestureRecognizer(singleTapForLevel)
    }

    /// Load saved levels and show in UITableView
    /// Read from database and show name of all saved levels in UITableView.
    func loadSavedLevel() {
        levels = LevelData.namesOfSavedGames
        levelSelectorCollection?.reloadData()
    }
}

extension SelectLevelViewController {
    /// Gesture to set load selected level.
    @objc
    func handleLevelSelected(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.levelSelectorCollection)
        guard let indexPath = (self.levelSelectorCollection?.indexPathForRow(at: point)) else {
            return
        }

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let selectedLevel = levels[indexPath.item]
        let levelDesignerController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelDesigner")
                as! LevelDesignViewController
        levelDesignerController.loadGrid(levelName: selectedLevel)
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

extension SelectLevelViewController: UITableViewDelegate, UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: levelSelectionCellIdentifier,
            for: indexPath as IndexPath)
            as! LevelSelectionTableViewCell
        cell.setLevelName(name: levels[indexPath.item])
        return cell
    }

    internal func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            let levelName = self.levels[indexPath.item]
            if LevelData.deleteLevel(name: levelName) {
                self.levels.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        return [delete]

    }
}
