// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A view controller to control level designing view. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit
import CoreData

class LevelDesignViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet private var gameArea: UIView!
    @IBOutlet private var paletteViewArea: UIView!

    @IBOutlet private var colorSelectorCollection: UICollectionView!
    let paletteCellIdentifier = "paletteSelectorBubbleCell"

    @IBOutlet private var gameBubbleCollection: UICollectionView!
    let gameBubbleCellIdentifier = "gameBubbleCell"

    var currentLevel = LevelGame(rows: Settings.numberOfRow, col: Settings.numberOfColumns, fillType: .empty)
    let gameLayout = IsometricLayout(rows: Settings.numberOfRow, firstRowCol: Settings.numberOfColumns, secondRowCol: Settings.numberOfColumns)
    let paletteBubbles = PaletteBubbles()

    var levelName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBackground()

        guard let layout = gameBubbleCollection?.collectionViewLayout as? IsometricViewLayout else {
            fatalError("There should be a layout for gameBubbleCollection!")
        }

        layout.delegate = self

        // The following blocks are for adding gestures:

        // Add single tap gesture for color selector
        let singleTapForPalette = UITapGestureRecognizer(target: self, action: #selector(handlePaletteTap(_:)))
        singleTapForPalette.delegate = self
        colorSelectorCollection.addGestureRecognizer(singleTapForPalette)

        // Add long press gesture for game bubble
        let longPressForGameBubble = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressForGameBubble.minimumPressDuration = 0.5
        longPressForGameBubble.delegate = self
        longPressForGameBubble.delaysTouchesBegan = true
        gameBubbleCollection.addGestureRecognizer(longPressForGameBubble)

        // Add single tap gesture for game bubble
        let singleTapForGameBubble = UITapGestureRecognizer(target: self, action: #selector(handleGameBubbleTap(_:)))
        singleTapForGameBubble.delegate = self
        gameBubbleCollection.addGestureRecognizer(singleTapForGameBubble)

        // Add panning gesture for game bubble
        let panningGameBubble = UIPanGestureRecognizer(target: self, action: #selector(handlePanning(_:)))
        panningGameBubble.delegate = self
        panningGameBubble.minimumNumberOfTouches = 1
        panningGameBubble.maximumNumberOfTouches = 1
        gameBubbleCollection.addGestureRecognizer(panningGameBubble)
    }

    @IBAction func startGame(_ sender: UIButton) {
        if !currentLevel.isEmpty {
            if haveBubbleConnectedToTopWall {
                transitToGame()
            } else {
                noFirstRowAlert()
            }
        } else {
            emptyGridAlert()
        }
    }

    var haveBubbleConnectedToTopWall: Bool {
        for index in gameLayout.getRowIndexes(0) {
            if !currentLevel.isEmptyAtIndex(index: index) {
                return true
            }
        }
        return false
    }

    private func emptyGridAlert() {
        let alert = UIAlertController(
            title: "Empty grid",
            message: "Whachu tryna do with empty?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sorry boss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    private func noFirstRowAlert() {
        let alert = UIAlertController(
            title: "First row cannot be empty",
            message: "If the first row is empty, the game will end immediately.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sorry boss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    private func transitToGame() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let levelSelectorController =
            storyBoard.instantiateViewController(
                withIdentifier: "gameEngine")
                as! GameEngineViewController
        levelSelectorController.loadedLevel = currentLevel.clone()
        self.present(levelSelectorController, animated: true, completion: nil)
    }

    /// Button to save current level.
    /// Saving using core data solution from https://www.youtube.com/watch?v=dIXkR-2rdvM
    /// Alert solution inspired from https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
    @IBAction func saveLevel(_ sender: UIButton) {

        if let levelName = levelName {
            // Override
            _ = LevelData.deleteLevel(name: levelName)
            self.saveAndAlert(levelName: levelName)
        } else {
            // Prompt for new name
            let alert = UIAlertController(
                title: "Save Level!",
                message: "What would you like to call this level? Note: Name should be less than 20 characters. ",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            alert.addTextField { textField in
                textField.placeholder = "Input level name here..."
            }

            alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
                let levelName = alert.textFields?.first?.text ??  ""
                self.saveAndAlert(levelName: levelName)
            })
            self.present(alert, animated: true)
        }
    }

    /// Button to load level. Switch to levelSelector view.
    @IBAction func loadLevel(_ sender: UIButton) {
        if !currentLevel.isEmpty {
            let alert = UIAlertController(
                title: "Are you sure you want to continue?",
                message: "Your current data will be loss.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                self.presentLevelSelector()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                return
            })
            self.present(alert, animated: true)
        }
        presentLevelSelector()
    }

    // Set up grid for level with name `levelName`.
    func loadGrid(levelName: String) {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LevelData")
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)
            for level in result as! [LevelData] {
                self.updateGridIfMatch(name: levelName, level: level)
            }
        } catch {
            let alert = UIAlertController(
                title: "Loading failed!",
                message: "Unable to fetch data. Just uninstall and reinstall.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK Can", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        self.levelName = levelName
    }

    func loadGrid(level: LevelGame) {
        currentLevel = level
    }

    @IBAction func resetGrid(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Reset level design",
            message: "Are you sure you want to reset the grid? This move is not reversible.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            self.currentLevel.eraseAllBubbles()
            self.gameBubbleCollection.reloadData()
        })
        self.present(alert, animated: true)
    }

    // Save current grid arrangement to core data and show alert.
    private func saveAndAlert(levelName: String) {
        let context = AppDelegate.viewContext
        var title = "Saved"
        var message = "Level \(levelName) has been saved successfully! 🥰"
        var confirmAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard levelName.count >= 3 && levelName.count <= 20 else {
            title = "Saving failed"
            message = "Name of level should be between 3 and 20 characters."
            let didNotSaveAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            didNotSaveAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(didNotSaveAlert, animated: true)
            return
        }
        currentLevel.saveGridBubblesToDatabase(name: levelName)
        do {
            try context.save()
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.presentLevelSelector()
            })
            self.levelName = levelName
        } catch {
            title = "Saving failed"
            message = "Try again. If problem persist, just minus marks...."
            confirmAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        self.present(confirmAlert, animated: true)
    }

    // Set up grid if the name provided matches level.
    private func updateGridIfMatch(name: String, level: LevelData) {
        guard let levelName = level.value(forKey: "levelName") as? String,
            name == levelName,
            let levelBubbles = level.bubbles as? Set<GridBubbleData> else {
            return
        }
        for bubble in levelBubbles {
            guard let index = bubble.value(forKey: "position") as? Int,
                let bubbleTypeIndex = bubble.value(forKey: "bubbleTypeId") as? Int else {
                fatalError("Database should not have saved an out of bound index or bubbleType," +
                    "and they should be of type Int!")
            }
            self.currentLevel.setBubbleTypeAtIndex(index: index, bubbleTypeIndex: bubbleTypeIndex)
        }
    }

    /// Function to load background
    private func loadBackground() {
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        let backgroundImage = UIImage(named: "background.png")
        let background = UIImageView(image: backgroundImage)
        background.frame = CGRect(x: 0, y: 0, width: gameViewWidth, height: gameViewHeight)
        gameArea.addSubview(background)
        gameArea.sendSubviewToBack(background)
    }

    // Present the level selector storyboard to user.
    private func presentLevelSelector() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let levelSelectorController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelSelector")
                as! SelectLevelViewController
        self.present(levelSelectorController, animated: true, completion: nil)
    }

    // Present the alert indicating that saving of data has failed.
    private func savingFailureAlert() {
        let alert = UIAlertController(
            title: "Saving has failed.",
            message: "Please try again. If issue persist, just deduct marks. 😭 ",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension LevelDesignViewController: GridLayoutDelegate {
    // For GridLayoutDelegate. Used to determine the maximum number of rows to generate
    // in the grid.
    func getHeightOfGameArea() -> CGFloat {
        return gameBubbleCollection.frame.size.height
    }
}

// Extend view controller to hold gesture actions
extension LevelDesignViewController {
    /// Gesture to set currently selected palette
    @objc
    func handlePaletteTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.colorSelectorCollection)
        guard let indexPath = (self.colorSelectorCollection?.indexPathForItem(at: point)) else {
            return
        }

        paletteBubbles.togglePaletteBubble(index: indexPath.item)
        colorSelectorCollection.reloadData()
    }

    /// Gesture to handle tapping of grid bubbles.
    @objc
    func handleGameBubbleTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.gameBubbleCollection)
        guard let indexPath = (self.gameBubbleCollection?.indexPathForItem(at: point)) else {
            return
        }

        if let currentPaletteColorType = paletteBubbles.getCurrentlySelectedPaletteType() {
            currentLevel.setBubbleTypeAtIndex(
                index: indexPath.item,
                bubbleType: currentPaletteColorType)
        } else {
            currentLevel.cycleTypeAtIndex(index: indexPath.item)
        }
        gameBubbleCollection.reloadItems(at: [indexPath])
    }

    // Erase bubble when grid bubble was long-pressed.
    @objc
    func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == UIGestureRecognizer.State.began else {
            return
        }

        let point = sender.location(in: self.gameBubbleCollection)
        guard let indexPath = gameBubbleCollection?.indexPathForItem(at: point) else {
            return
        }
        currentLevel.setBubbleTypeAtIndex(index: indexPath.item, bubbleType: .empty)
        gameBubbleCollection.reloadItems(at: [indexPath])
    }

    // Set grid bubble to currently selected bubble type when panning.
    @objc
    func handlePanning(_ sender: UIPanGestureRecognizer) {
        guard sender.state == UIGestureRecognizer.State.changed else {
            return
        }

        let point = sender.location(in: gameBubbleCollection)
        guard let indexPath = gameBubbleCollection?.indexPathForItem(at: point) else {
            return
        }
        guard let currentPaletteColorType = paletteBubbles.getCurrentlySelectedPaletteType() else {
            return
        }
        currentLevel.setBubbleTypeAtIndex(
            index: indexPath.item,
            bubbleType: currentPaletteColorType)
        gameBubbleCollection.reloadItems(at: [indexPath])
    }
}

// Extension to mainain collectionView actions.
extension LevelDesignViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorSelectorCollection {
            return paletteBubbles.count
        } else {
            return currentLevel.count
        }
    }

    // Make a cell for each cell index path
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case colorSelectorCollection:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: paletteCellIdentifier,
                for: indexPath as IndexPath)
                as! PaletteBubbleCollectionViewCell
            let selectedPaletteBubble = paletteBubbles.getBubbleAtIndex(index: indexPath.item)
            cell.setupImage(imageUrl: selectedPaletteBubble.imageUrl, isSelected: selectedPaletteBubble.isSelected)
            return cell
        case gameBubbleCollection:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: gameBubbleCellIdentifier,
                for: indexPath as IndexPath)
                as! GameBubbleCollectionViewCell
            let bubbleType = currentLevel.getBubbleTypeAtIndex(index: indexPath.item)
            cell.setImage(imageUrl: bubbleType.imageUrl)
            return cell
        default:
            fatalError("There should only be two collectionView.")
        }
    }
}
