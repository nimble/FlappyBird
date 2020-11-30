/*
* A program used to simulate the flappy bird game.
*@author Adam Rodrigues
*@author Jona Sahota
*/

/*The background image.*/
var background :int := Pic.FileNew("images/background.jpg")

/**The title image.*/
var title :int := Pic.FileNew("images/texts/title.gif");

/**The standard bird image animation=0*/
var standard :int := Pic.FileNew("images/bird/standard.gif");

/**The standard bird image animation=0*/
var down :int := Pic.FileNew("images/bird/down.gif");

/**The standard bird image animation=0*/
var up :int := Pic.FileNew("images/bird/up.gif");

/**The footer image*/
var footer :int := Pic.FileNew("images/footer.jpg");

/**The play button*/
var playButton :int := Pic.FileNew("images/buttons/play.gif")

/**The tap button.*/
var tap :int := Pic.FileNew("images/tap.gif")

/**The get ready text.*/
var getReady :int := Pic.FileNew("images/texts/getready.gif")

/**The game over gif.*/
var overPic :int := Pic.FileNew("images/texts/gameover.gif")

/**The down pipe image.*/
var downPipe :int := Pic.FileNew("images/downpipe.gif")

/**The up pipe*/
var upPipe :int := Pic.FileNew("images/uppipe.gif")

/**The dead image*/
var dead :int := Pic.FileNew("images/bird/dead.gif")

/**The panel image*/
var panel :int := Pic.FileNew("images/panel.gif")

/**The bronze medal*/
var bronze :int := Pic.FileNew("images/bronze.gif")

/**The silver medal*/
var silver :int := Pic.FileNew("images/silver.gif")

/**The gold medal*/
var gold :int := Pic.FileNew("images/gold.gif")

/**The platinum medal*/
var platinum :int := Pic.FileNew("images/platinum.gif")

/**The game state*/
var state :int := 0

/**The animation state of the bird*/
var animation :int :=0

/**The font to use.*/
var font := Font.New ("serif:12")
var scoreFont := Font.New ("serif:24:bold")
var hsFont := Font.New ("serif:16:bold")

/**The mouse x.*/
var mouseX :int := 0

/**The mouse y.*/
var mouseY :int := 0

/**The mouse buttons state*/
var button :int := 0

/**The speed the pipe moves at*/
var pipeSpeed :int := 3

/**The length of the pipes*/
var pipeLength :int := 1000

/**The pipe locations*/
var pipes : flexible array 1 .. pipeLength of int

/**The downward heights*/
var downHeights : flexible array 1 .. pipeLength of int

/**The upward heights.*/
var upHeights : flexible array 1 .. pipeLength of int

/**The x coord of the starting pipes*/
var pipeCount :int := 600

/**The bird y*/
var birdY :int := 306

/**The bird state*/
var birdState :int := 0

/**The keyboard characters.*/
var chars : array char of boolean

/**If the space bar is released.*/
var spaceReleased :boolean := true

%the counter used to change positions of the sprite.
var posCounter : int := 0

/**If the game is over*/
var gameOver :boolean := false

/**The birds x*/
var birdX :int := 70

/**Flappy Bird Score*/
var score : int := 0 

/**Our highscore*/
var highScore :int := 0

/**The velocity*/
var velocity :real := 0.0

/**A key counter*/
var keyCount :int := 0

%preLoad assets
Music.PreLoad("dead.wav")
Music.PreLoad("coin.wav")
Music.PreLoad("flap.wav")

process flapSound
     Music.PlayFileStop 
Music.PlayFile("flap.wav")
end flapSound

process playCoin
 Music.PlayFileStop 
Music.PlayFile("coin.wav")
end playCoin

process playDead
Music.PlayFile("dead.wav")
end playDead

%creates the pipes.
procedure createPipes 
pipeCount := 600
for i : 1 .. pipeLength   %initializes array
	pipes (i) := pipeCount
	downHeights(i) :=  Rand.Int(300, 320)
	upHeights(i) := Rand.Int(-60, -5)
	pipeCount := pipeCount + 130
end for
pipeCount := 600
birdY := 306
end createPipes 


/**Writes the highscore to a file*/
procedure writeHighscore
var stream : int
var myText : string := intstr(score)
open : stream, "hs.txt", write
write : stream, myText
end writeHighscore

/**Reads the highscores from the file*/
procedure readHighscore
var stream : int
var myText : string := ""
open : stream, "hs.txt", read
read : stream, myText
if (myText not = "") then
highScore := strint(myText)
end if
end readHighscore

readHighscore
createPipes

/**Checks if a pipe is actively under the bird*/
function isActivePipe(index : int) : boolean
if (gameOver) then
result false
end if
var pipeX : int := pipes(index)
%bird is 34 pixels wide
%pipes are 49 pixels wide
%active area starts at 70 px
if (pipeX - 25 <= birdX and pipeX >= birdX - 44) then
result true
end if
result false
end isActivePipe

/**Checks if their is a collision with the pipe & the bird.*/
function isCollision : boolean
if (gameOver) then
result false
end if
var hit := false
for i : 1 .. pipeLength
if (isActivePipe(i)) then
    var downHeight :int := downHeights(i) - 12
    var upOff :int := (upHeights(i) * 1) + 222
    if (birdY >= downHeight or birdY <= upOff) then
    hit := true
    end if
   result hit
end if
end for
result hit
end isCollision

/**Processes the logic of the bird*/
procedure processLogic
    posCounter := posCounter + 1
    if (posCounter mod 20  = 0) then

      if (birdState = 0) then
	birdState := 1
	else if (birdState = 1) then
	birdState := 2
	else
	birdState := 0
	end if
	end if
    end if
  var lowHigh : boolean := birdY <= 90 or birdY >= 401
  if (not gameOver and (lowHigh or isCollision)) then
    gameOver := true
    birdState := 3
    fork playDead
    if (score > highScore) then
	writeHighscore
	highScore := score
    end if
    return
  end if
  if (keyCount mod 2 = 0) then 
  velocity := velocity + 0.5
  if (velocity > 2) then
    velocity := 2
   end if
 birdY := birdY - round(velocity)
 end if
end processLogic


/**Handles the drawing of the bird*/
procedure drawBird
    var image := 0
    if (birdState = 0) then
	image := standard
    else if (birdState = 1) then
	image := down
    else if (birdState = 2) then
	image := up
    else if (birdState = 3) then
     image:= dead
     end if
     end if
    end if
    end if
    Pic.Draw(image, birdX, birdY, picMerge)
    if (not gameOver) then
    processLogic
    else
    Pic.Draw(overPic, 210, 290, picMerge)
    Pic.Draw(panel, 180, 130, picMerge)
    var medal := bronze
    var x := 210
    var y := 160
    if (score <= 10) then
	medal := bronze
    else if (score <= 20) then
	medal := silver
    else if (score <= 30) then
	medal := gold
	y := 155
	x :=208
    else if (score >= 40) then
	medal := platinum
	  y := 155
	x :=208
	end if
	end if
	end if
    end if
    Pic.Draw(medal, x, y, picMerge)
    Font.Draw(intstr(score), 391, 198, hsFont, white)
    Font.Draw(intstr(highScore), 391, 155, hsFont, white)
    if (birdY > 90) then
    birdY := birdY - 3
    end if
    end if
end drawBird

/**Draws the default game screen.*/
procedure drawDefault
  Pic.Draw(background, 0, 0, 0)
  if (state not = 2) then 
  Pic.Draw(footer, 0, 0, 0)
  end if
end drawDefault

/**Draws the moving pipes.*/
procedure drawPipes
   for i : 1 .. pipeLength/**loops through all pipes in the array.*/
	var val := pipes(i)
	if (val >= -50 and val <= 641) then
	    if (val = birdX - 20 and not gameOver) then
	    score := score + 1
	    fork playCoin
	    end if
	    var active :boolean := isActivePipe(i)
	    Pic.Draw(downPipe, val, downHeights(i), picMerge)
	    Pic.Draw(upPipe, val, upHeights(i), picMerge)
	end if 
	if (not gameOver) then
	 pipes(i) := pipes(i) - 1
	 end if
   end for
     Pic.Draw(footer, 0, 0, 0)
end drawPipes

/**Draws the game state.*/
procedure drawState
    drawDefault
    if (state = 0) then/**menu*/
	Pic.Draw(title, 180, 230, picMerge)
	Pic.Draw(playButton, 253, 100, picMerge)
     else if (state = 1) then/*get ready*/
	Pic.Draw(tap, 260, 140, picMerge)
	Pic.Draw(getReady, 200, 300, picMerge)
	Pic.Draw(standard, 170, 200, picMerge)
     else if (state = 2) then/*game*/
	drawPipes()
	drawBird()
	delay(pipeSpeed)
	end if
     end if
    end if
end drawState

drawState

/**Captures the mpse events*/
procedure captureMouse
mousewhere (mouseX, mouseY, button) 
    if (button not = 0 and not gameOver) then
    if (state = 0) then 
	if (mouseX >= 277 and mouseY >= 119 and mouseX <= 341 and mouseY <= 148) then
	    state:= 1
	    button := 0
	    return
	end if
    else if (state = 1) then/*222, 158, 380, 255*/
	if (mouseX >= 222 and mouseY >= 158 and mouseX <= 380 and mouseY <= 255) then
	    state := 2    
	    return
	end if
	end if
    end if
    end if
end captureMouse

var pressed : boolean := false

/**Captures key events*/
procedure captureKeys
 Input.KeyDown (chars)
  keyCount := keyCount + 1
 if (gameOver and chars(KEY_ENTER)) then
    for i : 1 .. pipeLength
    pipes(i) := 0
    upHeights(i) := 0
    downHeights(i) := 0
    end for
    score := 0
    birdY := 306
    velocity := 0
    gameOver := false
    createPipes()
    pipeCount := 600
    pressed := false
    birdState := 2
    return
 end if
  if (state = 2 and not gameOver and not pressed and chars(' ') and velocity > 1) then
    velocity := velocity - 8.5
    pressed := true
    fork flapSound;
   else if (not chars(' ') and pressed) then
   pressed := false
   end if
  end if
end captureKeys

procedure debug
Font.Draw ("Mouse X: " +  intstr(mouseX) + ", Mouse Y: " + intstr(mouseY), 0, 70, font, blue)
Font.Draw ("Button: " + intstr(button), 0, 52, font, blue)
Font.Draw("State: " + intstr(state), 0, 35, font, blue)
Font.Draw("Bird y: " + intstr(birdY), 0, 20, font, blue)
Font.Draw("Velocity: " + intstr(round(velocity)), 0, 5, font, blue)
Font.Draw("Created by: Adam rodrigues and Jona Sahota", 360, 5, font, black)
if state >=2 then
Font.Draw(intstr(score),301,371,scoreFont, white)
end if
end debug


View.Set("offscreenonly") 

loop
debug
View.Update
cls
captureMouse
captureKeys
drawState
end loop
