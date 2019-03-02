// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A view controller to control level designing view. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit
import AVFoundation
import CoreData

class LevelDesignViewController: UIViewController {
    @IBOutlet private var gameArea: UIView!
    @IBOutlet private var paletteViewArea: UIView!

    @IBOutlet var startButton: UIButton!

    @IBOutlet var timeStepper: UIStepper!
    @IBOutlet var numOfPlayer: UISegmentedControl!

    @IBOutlet private var colorSelectorCollection: UICollectionView!
    let paletteCellIdentifier = "paletteSelectorBubbleCell"
    @IBOutlet private var gameBubbleCollection: UICollectionView!
    let gameBubbleCellIdentifier = "gameBubbleCell"

    @IBAction func timeSetting(_ sender: UIStepper) {
        let time = Int(sender.value)
        timeLabel?.text = "Time: \(Int(time))"
        self.time = time
        currentLevel.time = time
    }

    @IBAction func startGame(_ sender: UIButton) {
        guard checkValidGrid() else {
            return
        }
        Settings.playSoundWith(Constants.start_game_sound)
        transitToGame()
    }

    func checkValidGrid() -> Bool {
        guard !currentLevel.isEmpty else {
            emptyGridAlert()
            return false
        }
        guard haveBubbleConnectedToTopWall else {
            noFirstRowAlert()
            return false
        }
        guard containsPlayableBubble else {
            noPlayableBubbleAlert()
            return false
        }
        return true
    }

    /// Button to load level. Switch to levelSelector view.
    @IBAction func loadLevel(_ sender: UIButton) {
        if !currentLevel.isEmpty {
            loseCurrentDataAlert()
        } else {
            presentLevelSelector()
        }
    }

    var timeLabel: UILabel?
    lazy var time: Int = currentLevel.time
    var isRectGrid = false
    let paletteBubbles = PaletteBubbles()
    //var levelName: String?

    var dualCannon: Bool {
        // TODO: ADD TO CORE DATA
        return numOfPlayer.selectedSegmentIndex == 1
    }

    lazy var currentLevel = LevelGame(totalBubbles: gameLayout.totalNumberOfBubble, fillType: .empty, isRect: isRectGrid)
    
    var gameLayout: GameLayout {
        if isRectGrid {
        return RectLayout(rows: Constants.numOfRows, firstRowCol: Constants.numOfCols)
        }
        return IsometricLayout(rows: Constants.numOfRows, firstRowCol: Constants.numOfCols)
    }

    var viewLayout: GridLayout {
        var result: GridLayout = IsometricViewLayout()
        if isRectGrid {
            result = RectViewLayout()
        }
        result.delegate = self
        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Settings.loadBackground(view: view)

        gameBubbleCollection!.collectionViewLayout = viewLayout

        addGestures()

        // Render time label
        let frameWidth = gameBubbleCollection.frame.width
        let frameHeight = gameBubbleCollection.frame.height
        let posX = frameWidth / 2
        let posY = 5 * frameHeight / 6
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight))
        timeLabel.center = CGPoint(x: posX, y: posY)

        timeLabel.textAlignment = .center
        timeLabel.text = "Time: \(time)"
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 120, weight: .light)
        timeLabel.alpha = 0.6
        gameBubbleCollection.addSubview(timeLabel)
        gameBubbleCollection.sendSubviewToBack(timeLabel)

        self.timeLabel = timeLabel
        timeStepper.value = Double(currentLevel.time)
    }

    var containsPlayableBubble: Bool {
        for index in 0..<gameLayout.totalNumberOfBubble {
            let type = currentLevel.getBubbleTypeAtIndex(index: index)
            if BubbleType.isPlayableBubble(type: type) {
                return true
            }
        }
        return false
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

    private func noPlayableBubbleAlert() {
        let alert = UIAlertController(
            title: "No playable bubble",
            message: "There must be a playable bubble. Empty grid or indestructible bubble doesn't count.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sorry boss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func loseCurrentDataAlert() {
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

    private func transitToGame() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let gameEngineController =
            storyBoard.instantiateViewController(
                withIdentifier: "gameEngine")
                as! GameEngineViewController

        // isRectGrid MUST be set before loadedLevel or else
        // bad things will happen
        gameEngineController.isRectGrid = isRectGrid
        gameEngineController.loadedLevel = currentLevel.clone()
        gameEngineController.isDualCannon = dualCannon
        renderChildController(gameEngineController)
    }

    func takeScreenshot() -> UIImage? {
        // Remove time and all empty bubbles
        let timeString = timeLabel?.text
        timeLabel?.text = ""
        currentLevel.setEmptyCells(type: .invisible)

        gameBubbleCollection.reloadData()
        UIGraphicsBeginImageContext(gameBubbleCollection.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        gameBubbleCollection.layer.render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Show time and all empty bubbles
        currentLevel.setEmptyCells(type: .empty)
        gameBubbleCollection.reloadData()
        timeLabel?.text = timeString
        return screenshot
    }

    // Save current grid arrangement to core data and show alert.
    private func saveAndAlert(levelName: String) {
        let context = AppDelegate.viewContext
        var title = "Saved"
        var message = "Level \(levelName) has been saved successfully! 🥰"
        let confirmAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let screenshot = takeScreenshot(), let pngData = screenshot.pngData() else {
            return
        }
        guard levelName.count >= 3 && levelName.count <= 20 else {
            // TODO: NEW ALERT
            title = "Saving failed"
            message = "Name of level should be between 3 and 20 characters."
            let didNotSaveAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            didNotSaveAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(didNotSaveAlert, animated: true)
            return
        }
        currentLevel.saveGridBubblesToDatabase(name: levelName, isRectGrid: isRectGrid, time: self.time, screenshot: pngData)
        do {
            try context.save()
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(confirmAlert, animated: true)
        } catch {
            self.savingFailureAlert()
        }

    }

    /// Present the level selector storyboard to user.
    private func presentLevelSelector() {
        derenderChildController(true)
    }
}

/// Level setup from core data
extension LevelDesignViewController {
    /// Button to save current level.
    /// Saving using core data solution from https://www.youtube.com/watch?v=dIXkR-2rdvM
    /// Alert solution inspired from https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
    @IBAction func saveLevel(_ sender: UIButton) {
        guard checkValidGrid() else {
            return
        }
        if let levelName = currentLevel.levelName {
            // Override
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
                var levelName = alert.textFields?.first?.text ??  ""
                while levelName.hasPrefix(" ") {
                    levelName = String(levelName.dropFirst())
                }
                while levelName.hasSuffix(" ") {
                    levelName = String(levelName.dropLast())
                }
                self.saveAndAlert(levelName: levelName)
            })
            self.present(alert, animated: true)
        }
    }

    // Set up grid for level with name `levelName`.
    func loadGrid(levelName: String) {
        guard let loadedLevel = LevelGame.retrieveLevel(levelName) else {
            cantRetrieveDataAlert()
            return
        }
        self.isRectGrid = loadedLevel.isRect
        self.time = loadedLevel.time
        currentLevel = loadedLevel
    }

    private func cantRetrieveDataAlert() {
        let alert = UIAlertController(
            title: "Loading failed!",
            message: "Unable to fetch data. Just uninstall and reinstall.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK Can", style: .default, handler: nil))
        self.present(alert, animated: true)
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
    /// For GridLayoutDelegate. Used to determine the maximum number of rows to generate
    /// in the grid.
    func getHeightOfGameArea() -> CGFloat {
        return gameBubbleCollection.frame.size.height
    }
}

/// Extension to mainain collectionView actions.
extension LevelDesignViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellRadius = colorSelectorCollection.frame.size.height / 2 + 1

        return CGSize(width: cellRadius, height: cellRadius)
    }

    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorSelectorCollection {
            return paletteBubbles.count
        } else {
            return currentLevel.count
        }
    }

    /// Make a cell for each cell index path
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
            cell.setupImage(imageUrl: Settings.selectedTheme.getBubbleTypePath(type: selectedPaletteBubble.bubbleType), isSelected: selectedPaletteBubble.isSelected)
            let cellDiameter = colorSelectorCollection.frame.height / 2
            let yPos = cell.frame.origin.y + cellDiameter / 2
            cell.frame = CGRect(x: cell.frame.origin.x, y: yPos, width: cellDiameter, height:cellDiameter)
            return cell
        case gameBubbleCollection:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: gameBubbleCellIdentifier,
                for: indexPath as IndexPath)
                as! GameBubbleCollectionViewCell
            let bubbleType = currentLevel.getBubbleTypeAtIndex(index: indexPath.item)
            cell.setImage(imageUrl: Settings.selectedTheme.getBubbleTypePath(type: bubbleType))
            return cell
        default:
            fatalError("There should only be two collectionView.")
        }
    }
}

extension LevelDesignViewController: UIGestureRecognizerDelegate {
    func addGestures() {
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

    /// Erase bubble when grid bubble was long-pressed.
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

    /// Set grid bubble to currently selected bubble type when panning.
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
