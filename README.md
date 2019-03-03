CS3217 Problem Set 5
==

**Name:** Ang Wei Neng

**Matric No:** A0164178X

**Tutor:** Wang Yanhao

## Tips

1. CS3217's Gitbook is at https://www.gitbook.com/book/cs3217/problem-sets/details. Do visit the Gitbook often, as it contains all things relevant to CS3217. You can also ask questions related to CS3217 there.
2. Take a look at `.gitignore`. It contains rules that ignores the changes in certain files when committing an Xcode project to revision control. (This is taken from https://github.com/github/gitignore/blob/master/Swift.gitignore).
3. A Swiftlint configuration file is provided for you. It is recommended for you to use Swiftlint and follow this configuration. Keep in mind that, ultimately, this tool is only a guideline; some exceptions may be made as long as code quality is not compromised.
4. Do not burn out. Have fun!

### Rules of Your Game

- Clear bubbles before the time ends to earn points. 

- How to win points:
    - Clear bubbles
    - Finish game before time ends
        - Remaining time will be converted to scores
    - Fire as little bubbles as possible. Each firing of cannon cost 300 points.

- How to not lose:
    - Do not hit chainsaw 
    - Do not allow grid bubbles to cross the gameover line
    - Clear game before time ends

- Special notes:
    - A random bubble will spawn every 10 seconds
    - Chainsaw is in game to prevent you from randomly spamming
    - This is a cooperative game. For multiplayer, you should work with your team to fire less bubbles to clear as many bubbles as possible. 
    - When game has ended, bubbles will freeze in the background. THIS IS A FEATURE. players can see the last instance of when they end the game. :)


### Problem 1: Cannon Direction

For single player: Hold anywhere on the screen to adjust cannon direction. Release to fire. Tapping on screen works too. 

For two player: Same as single player, but tapping zone is restricted to each cannons's half, indicated by the yellow and red tint in the background. 

Note: Cannon angle can only be between 0 to 180 degrees.

### Problem 2: Upcoming Bubbles

NA.

### Problem 3: Integration

When level is selected, a `LevelGame` object will be passed to the `GameEngineViewController` to run. `GameEngineViewController` will create a `GameEngine` object, which in turn create a `RnderingEngine` to render the game.

Advantages: 
- This method of passing an object around ensure that the state is consistant throughout the gameflow. 
- All the `GameEngineViewController` requires is the `LevelGame` object to init the game, which allows for easy extendability of code if we wish to render the game from another ViewController in the future (i.e. start a randomly generated game, based on random bubbles in the grids).

Disadvantages:
- When playing the game, we need to make a clone copy of `LevelGame` to allow players to restart the game. This cloning cause space inefficiency. However, it's important to note that alternative design that allows for restarting of game will also incur this space penalty. 

### Problem 4.4

My general strategy is, upon a bubble hitting a special bubble, activate that bubble. 

Once bubble is activated, we will activate surrounding bubbles, if they are also special bubbles. This is an action similiar to BFS. 

For example, if we have an isolated bomb bubble on its own, surrounded by normal bubbles, and we have another bomb and star bubble, side by side. When we hit the bomb bubble, the star bubble should be activated. Since the star bubble was activated by a bomb, all bomb bubbles will be destroyed. The isolated bomb bubble will be activated, causing the surrounding normal bubbles to be destroyed. 

Pretty cool. 

### Problem 7: Class Diagram

![Class Diagram](class-diagram.jpg)

#### Models

1. `Bubble` and `BubbleType` represents Bubbles in the game, whether its from the grid or from the palette. `BubbleType` reflect the type of bubble.
2. `PaletteBubble` and `PaletteBubbles` are models for the palette. `PaletteBubble` represent a single bubble in the palette, and `PaletteBubbles` represent the set of bubbles in the palette.
3. `Level` and `GridBubble` are models that represent the grids in the level design. GridBubble contains the state for a single bubble in the grid, while Level contains the state for all `GridBubble` in the grid. Level should encapsulate the state of the current level design. 
4. `LevelData` and `GridBubbleData` are `NSManagedObject` used for Core Data. Creation of these object result in new entries being created in the database.
5. `GameBubble`, `CannonObject`, `Wall` is used to modal their object. They are subclasses of `GameObject`
#### Controller

1. `LevelDesignViewController` controls the logic in the level design storyboard, particularly the palettecollectionview and the gridcollectionview.
2. `SelectLevelViewController` controls the logic in the level selection storyboard, particularly the collectionview.
3. `GameEngineViewController`: 
    - This is the class that will feed data to the game engine to run. 
    - It is also in charge of modifying collectionView.
4. `GameEngine`: 
    - This is where all the game logic happens, such as 
        - detecting collisions
        - dropping bubbles to grids
        - Generating firing bubbles
        - Moving bubbles in gamearea
        - Performing logic such as destroying if match, drop if unconnected
        - Performing coordination between rendering engine and game objects.
5. `PhysicsEngine`:
    - This is the engine that performs all physics in the game, given vectors as inputs. 
6. `RenderEngine`:
    - In charge of rendering objects in the game area that isn't snapped to any collectionview cell.

#### View
1. `GridLayout` determines the layout of the grid bubbles in level design
2. `BubbleCollectionViewCell` is a collectionviewcell that contains the image to be rendered.
3. `GameBubbleCollectionViewCell` is a collectionviewcell that inherits from `BubbleCollectionViewCell` and performs rendering of the gridbubble in level design view.
4. `PaletteBubbleCollectionViewCell` is a collectionviewcell that inherits from `BubbleCollectionViewCell` and performs rendering of the palette in level design view.
5. `LevelSelectionCollectionViewCell` is a collectionviewcell that renders the table in level selection.
6. `GameEngineBubbleCollectionViewCell` is a collectionviewcell that renders the bubble in game.
7. `GameBubbleView` is a view for the bubbles in the game
8. `CannonView` is a view for the cannon

#### Others
1. `Constants` Store all constant value in the game
2. `Settings` In charge of setting music and images of the game
3. `Level` and `LevelGame` models the levels in the game. Used by `LevelDesignViewController` and `GameEngineViewController`
4. `MusicPlayer` is used to play music logic
5. `BubbleTheme` is used to generate file name of bubbles based on theme. Game currently only have one theme.
6. `GameLayout`, `RectLayout`, `IsometricLayout` is used to determine layout logic such as nearest neighbours.
7. `GridLayout`, `RectViewLayout` and `IsometricViewLayout` is used to render the arrangement of the collectionview for rect and isometric arrangement.

### Problem 8: Testing


### Problem 9: The Bells & Whistles

- Cannon has animation!!
- Music and sound effects
- Obviously multiplayer mode since it is required
- More special bubbles
    - Chainsaw: Always in game. On collision with chainsaw -> Game over.
    - Magnet: Currently does nothing. (i.e. Normal bubble)
    - Random (Question mark icon): On collision, becomes a random power-up.
    - Rubbish Bin: On collision, both bin and bubble disappear.
    - Rocket: This is released by the cannon with 10% probability. On firing, drop anything on its path due to its fast speed. 
    - Nice bubble assets
- Score
    - With cool scoring algorithms
- Highscore system
- Timer with configurable settings
- Very very very nice UI (took me 3 days * 14h)
    - SelectLevel button in Start Menu has animation
    - Time and score can be seen while playing the game
        - When time is below 20, time text becomes orange
        - When time is below 5, time textbecomes red
        - When highscore is broken, score text become gold colour. 
- Nice background
- End game screen
    - Show if broke highscore or not.
- Allow deletion of levels!
- Note that editing of levels is trival, but I did not implement it as it doesn't make sense for one guy to create a level and another guy to edit it. 
- Alot of nice popups for user confirmation

### Problem 10: Final Reflection

TODO
