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

How to win points:
    - Clear bubbles
    - Finish game before time ends
        - Remaining time will be converted to scores
    - Fire as little bubbles as possible. Each firing of cannon cost 300 points.

How to not lose:
    - Do not hit chainsaw 
    - Do not allow grid bubbles to cross the gameover line
    - Clear game before time ends

Special notes:
    - A random bubble will spawn every 10 seconds
    - Chainsaw is in game to prevent you from randomly spamming
    - This is a cooperative game. For multiplayer, you should work with your team to fire less bubbles to clear as many bubbles as possible. 


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

![Class Diagram](class-diagram.png)



### Problem 8: Testing

TODO

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
- Allow deletion of levels!
- Note that editing of levels is trival, but I did not implement it as it doesn't make sense for one guy to create a level and another guy to edit it. 
- Alot of nice popups for user confirmation

### Problem 10: Final Reflection

TODO
