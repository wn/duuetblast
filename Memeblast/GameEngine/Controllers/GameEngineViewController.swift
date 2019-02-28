//
//  GameEngineViewController.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class GameEngineViewController: UIViewController, UIGestureRecognizerDelegate {
    // UI outlets
    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private weak var timeLabel: UILabel!

    // MARK: Level's settings
    lazy var currentLevel = LevelGame(totalBubbles: gameLayout.totalNumberOfBubble, fillType: .invisible, isRect: isRectGrid)
    var loadedLevel: LevelGame?

    // MARK: Layout properties
    var isDualCannon = false
    @IBOutlet private weak var gameBubbleCollection: UICollectionView!
    private let gameEngineBubbleCellIdentifier = "gameEngineBubbleCell"
    var isRectGrid = true

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

    private var gameoverLine: CGFloat {
        let numOfGridBubbles = gameBubbleCollection.numberOfItems(inSection: 0)
        let lastBubbleIndexPath = getIndexPathAtIndex(index: numOfGridBubbles - 1)
        guard let lastBubbleFrame = gameBubbleCollection.layoutAttributesForItem(at: lastBubbleIndexPath)?.frame else {
            fatalError("There must be a last bubble!")
        }
        return lastBubbleFrame.origin.y + 2 * bubbleRadius
    }

    private var gameEngine: GameEngine?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBackground()

        gameBubbleCollection!.collectionViewLayout = viewLayout

        // Create left and right view
        let gameWidth = gameBubbleCollection.frame.width
        let gameHeight = gameBubbleCollection.frame.height
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: gameWidth / 2, height: gameHeight))
        leftView.backgroundColor = .yellow

        let rightView = UIView(frame: CGRect(x: gameWidth / 2, y: 0, width: gameWidth / 2, height: gameHeight))
        rightView.backgroundColor = .red

        func setupFiringZone(view: UIView) {
            gameBubbleCollection.addSubview(view)
            gameBubbleCollection.sendSubviewToBack(view)
            setupTap(view: view)
            view.alpha = 0.1
        }

        func setupTap(view: UIView) {
            let longPressForGameplayArea = UILongPressGestureRecognizer(target: self, action: #selector(fireBubble(_:)))
            longPressForGameplayArea.delegate = self
            longPressForGameplayArea.minimumPressDuration = 0
            view.addGestureRecognizer(longPressForGameplayArea)
        }

        if isDualCannon {
            setupFiringZone(view: leftView)
            setupFiringZone(view: rightView)
        } else {
            setupTap(view: gameBubbleCollection)
        }

        let gameEngineTemp = GameEngine(
            gameplayArea: gameBubbleCollection,
            radius: bubbleRadius,
            firingPosition: firingPosition,
            gameoverLine: gameoverLine,
            gameLayout: gameLayout,
            isDualCannon: isDualCannon)

        gameEngine = gameEngineTemp

        gameEngine?.gameDelegate = self
        restartLevel()
    }

    func setupLevel(level: LevelGame) {
        currentLevel = level.clone()
        currentLevel.setEmptyCells(type: .invisible)
        currentLevel.emptyType = .invisible
    }

    @objc
    private func fireBubble(_ sender: UILongPressGestureRecognizer) {
        let pos = sender.location(in: gameBubbleCollection)
        guard sender.view != nil else {return}
        switch sender.state {

        case .possible, .began, .changed:
            gameEngine?.changeCannonAngle(pos)
        case .ended:
            gameEngine?.fireBubble(fireTowards: pos)
        default:
            break
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // We have to set game over to be true as game engine
        // contains async code, which does variable capturing.
        // Failure to set game over to be true will cause
        // memory leak.
        gameEngine?.completedGame(.falling)
        gameEngine?.gameOver = true
    }


    // Get center of firing position
    public var firingPosition: CGPoint {
        return CGPoint(x: gameBubbleCollection.frame.width / 2, y: gameBubbleCollection.frame.height - bubbleRadius)
    }

    private var bubbleRadius: CGFloat {
        return gameBubbleCollection.frame.width / CGFloat(Constants.numOfCols) / 2
    }

    @IBAction func restartLevel(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Restart Level!",
            message: "Are you sure you want to restart level?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            self.restartLevel()
        })
        self.present(alert, animated: true)
    }

    func restartLevel() {
        guard let loadedLevel = loadedLevel, let gameEngine = gameEngine else {
            fatalError("Level must be loaded before it can be restarted.")
        }

        gameEngine.restartEngine()
        setupLevel(level: loadedLevel)
        gameEngine.setupLevel(level: loadedLevel.clone())
        gameEngine.cannons.forEach { gameEngine.generateFiringBubble(cannon: $0) }
        for index in 0..<gameLayout.totalNumberOfBubble {
            // Apparently reloadData doesn't work here.
            reload(index: index)
        }
    }

    @IBAction func backToLevelSelector(_ sender: UIButton) {
        derenderChildController()
    }

    /// Function to load background
    private func loadBackground() {
        let gameViewHeight = self.view.frame.size.height
        let gameViewWidth = self.view.frame.size.width
        let backgroundImage = UIImage(named: Constants.background)
        let background = UIImageView(image: backgroundImage)
        background.frame = CGRect(x: 0, y: 0, width: gameViewWidth, height: gameViewHeight)
        self.view.addSubview(background)
        self.view.sendSubviewToBack(background)
    }
}

// Extension to mainain collectionView actions.
extension GameEngineViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentLevel.count
    }

    // Make a cell for each cell index path
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: gameEngineBubbleCellIdentifier,
                for: indexPath as IndexPath)
                as! GameEngineBubbleCollectionViewCell
        let selectedTheme = Settings.selectedTheme
            let bubbleType = currentLevel.getBubbleTypeAtIndex(index: indexPath.item)
        cell.setImage(imageUrl: selectedTheme.getBubbleTypePath(type: bubbleType))
            gameBubbleCollection.bringSubviewToFront(cell)
            return cell
    }
}

extension GameEngineViewController: GridLayoutDelegate {
    // For GridLayoutDelegate. Used to determine the maximum number of rows to generate
    // in the grid.
    func getHeightOfGameArea() -> CGFloat {
        return gameBubbleCollection.frame.size.height
    }
}

/// Helper functions for Collection View
extension GameEngineViewController: UIGameDelegate {
    func present(_ alert: UIAlertController, animated: Bool) {
        super.present(alert, animated: animated)
    }

    func reload(index: Int) {
        let indexPath = getIndexPathAtIndex(index: index)
        gameBubbleCollection.reloadItems(at: [indexPath])
    }

    func getPositionAtIndex(index: Int) -> CGPoint? {
        return gameBubbleCollection.layoutAttributesForItem(at: getIndexPathAtIndex(index: index))?.frame.origin
    }

    /// Precondition: indexPath must be in game!
    func setBubbleTypeAndGetPosition(bubbleType: BubbleType, index: Int) -> CGPoint? {
        let indexPath = getIndexPathAtIndex(index: index)
        currentLevel.setBubbleTypeAtIndex(index: indexPath.item, bubbleType: bubbleType)
        UIView.performWithoutAnimation {
            gameBubbleCollection.reloadItems(at: [indexPath])
        }
        return gameBubbleCollection.layoutAttributesForItem(at: indexPath)?.frame.origin
    }

    func getIndexPathAtIndex(index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }

    func getIndexPathAtPoint(point: CGPoint) -> IndexPath? {
        return self.gameBubbleCollection?.indexPathForItem(at: point)
    }

    func setTime(seconds: Int) {
        let min = seconds / 60
        let sec = seconds % 60
        timeLabel.text = "Time left: \(min) min \(sec) seconds"
    }
}

public protocol UIGameDelegate: class {
    var currentLevel: LevelGame { get }
    func reload(index: Int)
    func getPositionAtIndex(index: Int) -> CGPoint?
    func setBubbleTypeAndGetPosition(bubbleType: BubbleType, index: Int) -> CGPoint?
    func getIndexPathAtIndex(index: Int) -> IndexPath
    func getIndexPathAtPoint(point: CGPoint) -> IndexPath?
    func present(_ alert: UIAlertController, animated: Bool)
    func restartLevel()
    func setTime(seconds: Int)
}
