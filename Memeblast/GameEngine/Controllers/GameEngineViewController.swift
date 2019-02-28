//
//  GameEngineViewController.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class GameEngineViewController: UIViewController, UIGestureRecognizerDelegate {
    var isDualCannon = false
    @IBOutlet private var statusView: UIView!

    var isRectGrid = true

    @IBOutlet private var gameBubbleCollection: UICollectionView!

    private let gameEngineBubbleCellIdentifier = "gameEngineBubbleCell"
    lazy var currentLevel = LevelGame(totalBubbles: gameLayout.totalNumberOfBubble, fillType: .invisible, isRect: isRectGrid)

    var loadedLevel: LevelGame?

    var gameLayout: GameLayout {
        if isRectGrid {
            return RectLayout(rows: Constants.numOfRows, firstRowCol: Constants.numOfCols)
        }
        return IsometricLayout(rows: Constants.numOfRows, firstRowCol: Constants.numOfCols)
    }

    lazy private var gameEngine = GameEngine(
        gameplayArea: gameBubbleCollection,
        radius: bubbleRadius,
        firingPosition: firingPosition,
        gameoverLine: gameoverLine,
        gameLayout: gameLayout,
        isDualCannon: isDualCannon)

    private var gameoverLine: CGFloat {
        let numOfGridBubbles = gameBubbleCollection.numberOfItems(inSection: 0)
        let lastBubbleIndexPath = getIndexPathAtIndex(index: numOfGridBubbles - 1)
        guard let lastBubbleFrame = gameBubbleCollection.layoutAttributesForItem(at: lastBubbleIndexPath)?.frame else {
            fatalError("There must be a last bubble!")
        }
        return lastBubbleFrame.origin.y + 2 * bubbleRadius
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
            // For firing bubble from cannon
            let singleTapForGameplayArea = UITapGestureRecognizer(target: self, action: #selector(fireBubble(_:)))
            singleTapForGameplayArea.delegate = self
            view.addGestureRecognizer(singleTapForGameplayArea)

            // For setting cannon angle
            let panningForGameplayArea = UIPanGestureRecognizer(target: self, action: #selector(changeAngle(_:)))
            panningForGameplayArea.delegate = self
            view.addGestureRecognizer(panningForGameplayArea)
        }

        if isDualCannon {
            setupFiringZone(view: leftView)
            setupFiringZone(view: rightView)
        } else {
            setupTap(view: gameBubbleCollection)
        }

        gameEngine.gameDelegate = self
        restartLevel()
    }

    func setupLevel(level: LevelGame) {
        currentLevel = level.clone()
        currentLevel.setEmptyCells(type: .invisible)
        currentLevel.emptyType = .invisible
    }

    @objc
    private func fireBubble(_ sender: UITapGestureRecognizer) {
        gameEngine.fireBubble(fireTowards: sender.location(in: gameBubbleCollection))
    }

    @objc
    func changeAngle(_ sender : UIPanGestureRecognizer) {
        let pos = sender.location(in: gameBubbleCollection)
//        let gameHeight = gameBubbleCollection.frame.height
//        guard pos.y < gameHeight - Constants.cannonHeight else {
//            return
//        }
        guard sender.view != nil else {return}
        switch sender.state {

        case .possible, .began, .changed:
            gameEngine.changeCannonAngle(pos)
        case .ended:
            gameEngine.fireBubble(fireTowards: pos)
        default:
            break
        }
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
        guard let loadedLevel = loadedLevel else {
            fatalError("Level must be loaded before it can be restarted.")
        }

        gameEngine.restartEngine()
        setupLevel(level: loadedLevel)
        gameEngine.setupLevel(level: loadedLevel.clone())
        for cannon in gameEngine.cannons {
            gameEngine.generateFiringBubble(cannon: cannon)
        }
        for index in 0..<gameLayout.totalNumberOfBubble {
            // Apparently reloadData doesn't work here.
            reload(index: index)
        }
    }

    @IBAction func backToLevelSelector(_ sender: UIButton) {
        guard let loadedLevel = loadedLevel else {
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let levelDesignerController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelDesigner")
                as! LevelDesignViewController
        levelDesignerController.isRectGrid = isRectGrid
        levelDesignerController.loadGrid(level: loadedLevel)
        self.present(levelDesignerController, animated: true, completion: nil)
    }

    /// Function to load background
    private func loadBackground() {
        let gameViewHeight = self.view.frame.size.height
        let gameViewWidth = self.view.frame.size.width
        let backgroundImage = UIImage(named: "background.png")
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
    internal func present(_ alert: UIAlertController, animated: Bool) {
        super.present(alert, animated: animated)
    }

    internal func reload(index: Int) {
        let indexPath = getIndexPathAtIndex(index: index)
        gameBubbleCollection.reloadItems(at: [indexPath])
    }

    internal func getPositionAtIndex(index: Int) -> CGPoint? {
        return gameBubbleCollection.layoutAttributesForItem(at: getIndexPathAtIndex(index: index))?.frame.origin
    }

    /// Precondition: indexPath must be in game!
    internal func setBubbleTypeAndGetPosition(bubbleType: BubbleType, indexPath: IndexPath) -> CGPoint? {
        currentLevel.setBubbleTypeAtIndex(index: indexPath.item, bubbleType: bubbleType)
        UIView.performWithoutAnimation {
            gameBubbleCollection.reloadItems(at: [indexPath])
        }
        return gameBubbleCollection.layoutAttributesForItem(at: indexPath)?.frame.origin
    }

    internal func getIndexPathAtIndex(index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }

    internal func getIndexPathAtPoint(point: CGPoint) -> IndexPath? {
        return self.gameBubbleCollection?.indexPathForItem(at: point)
    }
}

public protocol UIGameDelegate: class {
    var currentLevel: LevelGame { get }
    func reload(index: Int)
    func getPositionAtIndex(index: Int) -> CGPoint?
    func setBubbleTypeAndGetPosition(bubbleType: BubbleType, indexPath: IndexPath) -> CGPoint?
    func getIndexPathAtIndex(index: Int) -> IndexPath
    func getIndexPathAtPoint(point: CGPoint) -> IndexPath?
    func present(_ alert: UIAlertController, animated: Bool)
    func restartLevel()
}
