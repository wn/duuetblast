// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A view controller to control selection of saved levels. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit
import CoreData

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
        self.present(levelDesignerController, animated: true, completion: nil)
    }

    /// Button to create a new level.
    @IBAction func createNewLevel(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let levelDesignerController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelDesigner")
                as! LevelDesignViewController
        let alert = UIAlertController(title: "Rectangular OR Isometric?", message: "FUCKING MODULE", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Rectangular", style: .default) { _ in
            levelDesignerController.isRectGrid = true
            self.present(levelDesignerController, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Isometric", style: .default) { _ in
            levelDesignerController.isRectGrid = false
            self.present(levelDesignerController, animated: true, completion: nil)
        })
        self.present(alert, animated: true)
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
