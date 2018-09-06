
// Project: Space Crab 
// Created: 2018-04-17

//ADAPTED FROM:
// Project: LadderWizardWally 
// Created: 2015-11-22

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Space Crab" )
SetWindowSize( 620, 1100, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

//Screen dimension variables
global w = 620
global h = 1100

// set display properties
SetVirtualResolution(w, h) // doesn't have to match the window
SetOrientationAllowed(1, 1, 0, 0) // allow both portrait and landscape on mobile devices
SetSyncRate( 60, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts

//SetWindowSize(1242, 2208, 0)	//iPhone
SetWindowSize(2048, 2732, 0)	//iPad

SetSortDepth(1)

global mainFont = 2
LoadImage(mainFont, "mainFont.png")

global nMeteor = 11
LoadImage(nMeteor, "Asteroid32.png")
global gMeteor = 12
LoadImage(gMeteor, "goldM.png")
global rMeteor = 13
LoadImage(rMeteor, "rotateM.png")
global fMeteor = 14
LoadImage(fMeteor, "fastM.png")
global coinPic = 15
LoadImage(coinPic, "coin.png")

global explodeSound = 1
LoadSound(explodeSound, "explode.wav")
global mainTheme = 2
LoadMusicOGG(mainTheme, "mainTheme.ogg")
global deathTheme = 3
LoadMusicOGG(deathTheme, "deathTheme.ogg")
global coinSound = 4
LoadSound(coinSound, "coin.wav")
global skidSound = 5
LoadSound(skidSound, "skid.wav")

global startMenu = 0
global gameReady = 1
global gamePlay = 0
global gameLost = 0
global pauseMenu = 0

/*
SPRITE INDEX:

1 - Crab

3 - Reset Button
4 - Space Background

8 - Logo

11 - Screen Transition Sprite

15 - Score Coin

22 - New High Score Button

31 - Frame Rate Button

101-110 Normal Metoers
111-120 Rotate Meteors
121-130 Fast Meteors

201-210 Coins
221-230 Fast Meteors Warning

*/

function SaveGame()
	OpenToWrite(1, "crabSave.txt")
	WriteInteger(1, highScore)
	CloseFile(1)
endfunction

function LoadGame()
	OpenToRead(1, "crabSave.txt")
	highScore = ReadInteger(1)
	CloseFile(1)
endfunction

function drawPolar(spriteNum, rNum, theta#, sizeX, sizeY)
	SetSpritePosition(spriteNum, rNum*cos(theta#)+(w/2)-sizeX/2, rNum*sin(theta#)+(h/2)-sizeY/2)
	SetSpriteAngle(spriteNum, theta#+90)
	if spriteNum >= 111 and spriteNum <= 120 then SetSpriteAngle(spriteNum, theta#+45)
endfunction

Function Button(sprite) 
if GetSpriteExists(sprite) = 0 then exitfunction 0	//Added in to make sure bad buttons aren't targeted
returnValue = 0 `reset value for check
If GetPointerX() > GetSpriteXByOffset( sprite ) - ( GetSpriteWidth( sprite ) / 2 )
 If GetPointerX() < GetSpriteXByOffset( sprite ) + ( GetSpriteWidth( sprite ) / 2 )
   If GetPointerY() > GetSpriteYByOffset( sprite ) - ( GetSpriteHeight( sprite ) / 2 )
    If GetPointerY() < GetSpriteYByOffset( sprite ) + ( GetSpriteHeight( sprite ) / 2 )
      If GetPointerState() = 1
        returnValue = 1
      Endif
     Endif
   Endif
  Endif
Endif
EndFunction returnValue


function MeteorSpawn(mType)
	if mType = 1
		for i = 1 to 10
			if nMet[i, 1] = 0
				CreateSprite(100+i, nMeteor)
				if gameTime > 500 and Random(1,4) = 4 then SetSpriteImage(100+i, gMeteor)
				SetSpriteSize(100+i, 55+Random(0,10), 85+Random(0,10))
				//SetSpriteShape(100+i, 1)
				SetSpriteDepth(100+i, 1)
				nMet[i, 1] = 1
				nMet[i, 2] = 1000
				nMet[i, 3] = Random(0, 359)
				sNum = 100+i
				i = 10
			endif
			
		next i
	endif
	if mType = 2
		for i = 1 to 10
			if rMet[i, 1] = 0
				CreateSprite(110+i, rMeteor)
				SetSpriteSize(110+i, 65+Random(0,10), 95+Random(0,10))
				//SetSpriteShape(110+i, 1)
				SetSpriteDepth(110+i, 1)
				rMet[i, 1] = 1
				rMet[i, 2] = 1200
				rMet[i, 3] = Random(0, 359)
				sNum = 110+i
				i = 10
			endif
			
		next i
	endif
	if mType = 3
		for i = 1 to 10
			if fMet[i, 1] = 0
				CreateSprite(120+i, fMeteor)
				SetSpriteSize(120+i, 70+Random(0,10), 100+Random(0,10))
				//SetSpriteShape(120+i, 1)
				SetSpriteDepth(120+i, 1)
				fMet[i, 1] = 1
				fMet[i, 2] = 10000
				fMet[i, 3] = Random(0, 359)
				
				CreateSprite(220+i, 0)
				SetSpriteColor(220+i, 230, 40, 0, 0)
				SetSpriteSize(220+i, 1, 6000)
				sNum = 120+i
				i = 10
			endif
			
		next i
	endif
	
	AddSpriteAnimationFrame(sNum, LoadImage("meteorgraystraight1.png"))
	AddSpriteAnimationFrame(sNum, LoadImage("meteorgraystraight2.png"))
	AddSpriteAnimationFrame(sNum, LoadImage("meteorgraystraight3.png"))
	AddSpriteAnimationFrame(sNum, LoadImage("meteorgraystraight4.png"))
	if sNum > 120 then SetSpriteColor(sNum, 230, 40, 0, 255)
	if sNum > 110 and sNum < 120 then SetSpriteColor(sNum, 180, 20, 240, 255)
	if sNum > 100 and sNum < 110 then SetSpriteColor(sNum, 230, 100, 0, 255)
	if GetSpriteImageID(sNum) = gMeteor then SetSpriteColor(sNum, 195, 200, 0, 254)
		
	PlaySprite(sNum, 10, 1, 1, 4)
endfunction

function MeteorUpdate()
	for i = 1 to 10
		if nMet[i,1]	//Normal Meteor Update
			//sNum = 100+i
			inc nMet[i,2], -4	//Radius
			if nMet[i,3] <= 30 or nMet[i,3] >= 330 or (nMet[i,3] <= 210 and nMet[i,3] >= 150) then inc nMet[i,2], 1
			DrawPolar(100+i, nMet[i,2], nMet[i,3], GetSpriteWidth(100+i), GetSpriteHeight(100+i))
			
			if nMet[i,2] < planetRadius+20 then MeteorExplode(100+i, 1)
				
		endif
		if rMet[i,1]	//Rotate Meteor Update
			inc rMet[i,2], -2	//Radius
			inc rMet[i,3], 2	//Theta
			if rMet[i,3] > 360 then inc rMet[i,3], -360
			DrawPolar(110+i, rMet[i,2], rMet[i,3], GetSpriteWidth(110+i), GetSpriteHeight(110+i))
			
			if rMet[i,2] < planetRadius+20 then	MeteorExplode(110+i, 2)
		endif
		if fMet[i,1]	//Fast Meteor Update
			inc fMet[i,2], -20	//Radius
			DrawPolar(120+i, fMet[i,2], fMet[i,3], GetSpriteWidth(120+i), GetSpriteHeight(120+i))
			
			SetSpriteSize(220+i, GetSpriteWidth(120+i)*(10000.0-fMet[i,2])/10000.0, 6000)
			SetSpriteColorAlpha(220+i, 150*(10000.0-fMet[i,2])/10000.0)
			DrawPolar(220+i, 3000, fMet[i,3], GetSpriteWidth(220+i), GetSpriteHeight(220+i))
			
			if fMet[i,2] < planetRadius+20 then	MeteorExplode(120+i, 3)
		endif
		
	next i

endfunction


CreateParticles ( 1, -100, -100 )
CreateParticles ( 2, -100, -100 )
CreateParticles ( 3, -100, -100 )

function MeteorExplode(sNum, mType)
	
	

	SetParticlesPosition (mType, GetSpriteX(sNum)+GetSpriteWidth(sNum)/2, GetSpriteY(sNum)+GetSpriteHeight(sNum)/2)
	
	PlaySound(explodeSound, 100, 0)
	
    ResetParticleCount (mType)
    SetParticlesFrequency (mType, 250 )
    SetParticlesLife (mType, 3.0 )
    SetParticlesSize (mType, 30 )
    SetParticlesStartZone (mType, -10, 0, 10, 0 )
    //SetParticlesImage ( 1, 1 )
    SetParticlesDirection (mType, 10, 10 )
    SetParticlesAngle (mType, 360 )
    SetParticlesVelocityRange (mType, 0.8, 2.5 )
    SetParticlesMax (mType, 100 )
    if mType = 1
		AddParticlesColorKeyFrame (mType, 0.0, 0, 0, 0, 0 )
		AddParticlesColorKeyFrame (mType, 0.5, 255, 255, 0, 255 )
		AddParticlesColorKeyFrame (mType, 2.8, 255, 0, 0, 0 )
		//if GetSpriteImageID(sNum) = gMeteor	//Gold Explosion
		//	AddParticlesColorKeyFrame (mType, 0.0, 0, 0, 0, 0 )
		//	AddParticlesColorKeyFrame (mType, 0.5, 255, 255, 0, 255 )
		//	AddParticlesColorKeyFrame (mType, 2.8, 205, 255, 0, 0 )
		//endif
	elseif mType = 2
		AddParticlesColorKeyFrame (mType, 0.0, 0, 0, 0, 0 )
		AddParticlesColorKeyFrame (mType, 0.5, 139, 0, 139, 255 )
		AddParticlesColorKeyFrame (mType, 2.8, 30, 50, 180, 0 )
	elseif mType = 3
		AddParticlesColorKeyFrame (mType, 0.0, 0, 0, 0, 0 )
		AddParticlesColorKeyFrame (mType, 0.5, 255, 255, 0, 255 )
		AddParticlesColorKeyFrame (mType, 2.8, 255, 0, 0, 0 )
	endif


    AddParticlesForce (mType, 2.0, 2.8, 25, -25 )
  
    
    screenShakeAdd = 0
	if mType = 1
		nMet[sNum-100, 1] = 0
		if GetSpriteColorAlpha(sNum) = 254 and gameLost = 0
			//For creating the coin
			for i = 1 to 10
				if GetSpriteExists(200+i) = 0
					CreateSprite(200+i, coinPic)
					SetSpriteSize(200+i, 25, 25)
					SetSpriteDepth(200+i, 1)
					coins[i, 2] = 140
					coins[i, 3] = nMet[sNum-100, 3]
					drawPolar(200+i, coins[i, 2], coins[i, 3], GetSpriteWidth(200+i), GetSpriteHeight(200+i))
					AddSpriteAnimationFrame(200+i, LoadImage("coin1.png"))
					AddSpriteAnimationFrame(200+i, LoadImage("coin2.png"))
					AddSpriteAnimationFrame(200+i, LoadImage("coin3.png"))
					AddSpriteAnimationFrame(200+i, LoadImage("coin4.png"))
					AddSpriteAnimationFrame(200+i, LoadImage("coin5.png"))
					AddSpriteAnimationFrame(200+i, LoadImage("coin6.png"))
					AddSpriteAnimationFrame(200+i, LoadImage("coin7.png"))
					PlaySprite(200+i, 10, 1, 1, 7)
					i = 10
				endif
			next i
		endif
		screenShakeAdd = 6
		screenShakeTheta = nMet[sNum-100, 3]
	endif
	if mType = 2
		rMet[sNum-110, 1] = 0
		screenShakeAdd = 10
		screenShakeTheta = rMet[sNum-110, 3]
	endif
	if mType = 3
		fMet[sNum-120, 1] = 0
		DeleteSprite(sNum+100)
		screenShakeAdd = 15
		screenShakeTheta = fMet[sNum-120, 3]
	endif
	DeleteSprite(sNum)
	if gameLost = 0 then inc score, 1
	SetTextString(3, "Score: " + Str(score))
	
	if screenShake = 0
		inc screenShake, screenShakeAdd		
	else
		screenShake = Sqrt(screenShake^2+screenShakeAdd^2)
	endif
	if gameLost = 1 then screenShake = 0
endfunction

function LoseGame(deathType)
	for i = 1 to 40	//Death animation
		if deathType = 1
			if i = 1 
				PlaySprite(1, 10, 0, 17, 17)
				inc crabTheta#, -8
				crabR = 116
				drawPolar(1, crabR, crabTheta#, GetSpriteWidth(1), GetSpriteHeight(1))
			endif
		elseif deathType = 2
			if i = 1 then PlaySprite(1, 10, 0, 18, 18)
			inc crabR, 4
			inc crabTheta#, 1.4
			drawPolar(1, crabR, crabTheta#, GetSpriteWidth(1), GetSpriteHeight(1))
			SetSpriteAngle(1, GetSpriteAngle(1)+i*9.3)
			if i > 20 then SetSpriteColorAlpha(1, 255*(40-(i-20)))
		else
				if i = 1 
				PlaySprite(1, 10, 0, 19, 19)
				//inc crabTheta#, -12
				crabR = 102
				drawPolar(1, crabR, crabTheta#, GetSpriteWidth(1), GetSpriteHeight(1))
			endif
		endif
		Sync()
	next i
	
	
	SetSpriteColorAlpha(1, 0)
	CreateText(1, "LOSER    XD")
	SetTextSize(1, 100)
	SetTextPosition(1, 70, 150)
	SetTextDepth(1, 1)
	SetTextFontImage(1, mainFont)
	FixTextToScreen(1, 1)
endfunction

function PrepareGame()
	//ScreenTransitionStart()
	for i = 1 to 10
		for j = 1 to 3
			nMet[i,j] = 0
			rMet[i,j] = 0
			fMet[i,j] = 0
		next j
	next i
	gameTime = 0
	crabTheta# = 270
	planetRotateSpeed# = 0
	score = 0
	SetTextString(3, "Score: " + Str(score))
	DeleteText(1)
	SetSpriteColorAlpha(1, 255)
	DeleteText(7)	
	if GetSpriteExists(22) then DeleteSprite(22)
	if GetSpriteExists(15) then DeleteSprite(15)
	crabR = 132
	crabTheta# = 270
	drawPolar(1, crabR, crabTheta#, GetSpriteWidth(1), GetSpriteHeight(1))
	SetTextColorAlpha(3, 0)
	PlaySprite(1, 10, 0, 1, 1)
	
	introTimer = 60
	SetTextColorAlpha(3, 255)
	SetTextPosition(3, 20, 50)
	PlaySprite (1, 10, 0, 1, 8)
	DeleteSprite(8)
	gameReady = 0
	gamePlay = 1
	//SetSpriteAngle(51, 0)
	//ScreenTransitionEnd()
	if GetMusicPlayingOGG(deathTheme) then StopMusicOGG(deathTheme)
	PlayMusicOGG(mainTheme, 1)
endfunction

CreateSprite(4, LoadImage("spacecrabbackground.png"))
SetSpriteSize(4, h*4/3.0, h*4/3.0)
SetSpritePosition(4, -GetSpriteHeight(4)/4, -GetSpriteHeight(4)/4)
FixSpriteToScreen(4, 1)

//Crab initialization
CreateSprite(1, LoadImage("correctstart1.png"))
SetSpriteDepth(1, 1)
SetSpriteSize(1, 64, 44)
global crabR as Float
crabR = 132
global crabTheta# = 270
global crabLevel = 2
crabVeloMax# = 1.28 //*GetFrameTime()/.0166
crabVelo# = 1.28
crabRev = 0	//This is for the velocity reversing countdown, is NOT boolean
crabDirection = -1 //This is the boolean lol (1 or -1)
drawPolar(1, crabR, crabTheta#, GetSpriteWidth(1), GetSpriteHeight(1))

//Crab animation
AddSpriteAnimationFrame(1, LoadImage("correctstart1.png"))
AddSpriteAnimationFrame(1, LoadImage("correctstart2.png"))
AddSpriteAnimationFrame(1, LoadImage("correctstart3.png"))
AddSpriteAnimationFrame(1, LoadImage("correctstart4.png"))
AddSpriteAnimationFrame(1, LoadImage("correctstart5.png"))
AddSpriteAnimationFrame(1, LoadImage("correctstart6.png"))
AddSpriteAnimationFrame(1, LoadImage("correctstart7.png"))
AddSpriteAnimationFrame(1, LoadImage("correctstart8.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk1.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk2.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk3.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk4.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk5.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk6.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk7.png"))
AddSpriteAnimationFrame(1, LoadImage("correctwalk8.png"))
AddSpriteAnimationFrame(1, LoadImage("crabdeath1.png"))	//17 for death 1
AddSpriteAnimationFrame(1, LoadImage("crabx1.png"))	//18 for death 2
AddSpriteAnimationFrame(1, LoadImage("crabthroughtheplanet1.png"))


//SetSpritePosition(10, crabX, crabY)

global crabSpeed as Float

CreateSprite(51, LoadImage("crabplanetfix.png"))
global planetRadius = 122
SetSpriteSize(51, planetRadius*2, planetRadius*2)
SetSpriteDepth(51, 2)
SetSpritePosition(51, w/2-GetSpriteWidth(51)/2, h/2-GetSpriteHeight(51)/2)

//CreateSprite(52, LoadImage("ringTemplate.png"))
//SetSpriteSize(52, 320, 320)
//SetSpriteDepth(52, 1)
//SetSpritePosition(52, w/2-GetSpriteWidth(52)/2, h/2-GetSpriteHeight(52)/2)

//Array [][1] will be one if the thing exists
global nMet as Integer[10, 3]
global rMet as Integer[10, 3]
global fMet as Integer[10, 3]
global coins as Integer[10, 3]
global gameTime = 0

global score = 0
global highScore = 0
CreateText(3, "Score: " + Str(score))
SetTextSize(3, 70)
SetTextPosition(3, 20, 50)
SetTextColorAlpha(3, 0)
SetTextFontImage(3, mainFont)
FixTextToScreen(3, 1)
LoadGame()

global screenShake = 0
global screenShakeTheta = 0

global planetRotateSpeed# = 0

//CreateSprite(31, 0)
//SetSpriteSize(31, 80, 80)
//SetSpritePosition(31, w-80, 0)

CreateText(6, "Tap to go!")
SetTextSize(6, 60)
SetTextPosition(6, 30, h/2)
SetTextDepth(6, 1)
SetTextColorAlpha(6, 0)
SetTextFontImage(6, mainFont)
global startTextFadeout = 0

CreateSprite(8, 0)
SetSpriteSize(8, 526, 361)
SetSpritePosition(8, w/2-GetSpriteWidth(8)/2, -120)
SetSpriteDepth(8, 1)
AddSpriteAnimationFrame(8, LoadImage("crablogo.png"))
AddSpriteAnimationFrame(8, LoadImage("crablogoblank.png"))
PlaySprite(8, 2, 1, 1, 2)





//For the 'main menu'
SetViewOffset(0, -250)

global introTimer = 0

do
	if gameReady = 1
		
		
				
		if GetPointerPressed() or GetRawKeyPressed(32)
			
			introTimer = 60
			startTextFadeout = 90
			gameReady = 0
			gamePlay = 1
			SetTextString(6, "SURVIVE!")
			SetTextColorAlpha(3, 255)
			PlaySprite (1, 10, 0, 1, 8)
			DeleteSprite(8)
			PlayMusicOGG(mainTheme, 1)
		endif

	endif

	if gamePlay = 1
		x# = GetPointerX()
		y# = GetPointerY()


		if GetSpritePlaying(1) = 0 then PlaySprite (1, 10, 1, 9, 16)

		if introTimer <> 0
			inc introTimer, -1
			SetViewOffset(0, GetViewOffsetY()*11/12)
			if introTimer = 0 then SetViewOffset(0, 0)
		endif


		if startTextFadeout <> 0
			inc startTextFadeout, -1
			
			SetTextSize(6, GetTextSize(6)+1)
			if startTextFadeout > 30 then SetTextColorAlpha(6, 255*((startTextFadeout-30)/60.0))
			if startTextFadeout = 0
					DeleteText(6)
			endif
			
		endif

		if GetPointerPressed() or GetRawKeyPressed(32)
			crabRev = 20
			PlaySprite (1, 10, 0, 1, 8)
			if introTimer = 0 then PlaySound(skidSound, 100, 0)
		endif
		
		if crabRev > 0
			inc crabRev, -1
			crabVelo# = crabDirection*crabVeloMax#*(Abs(crabRev-10))/15
		
			if crabRev = 10
				crabDirection = -crabDirection
				if crabDirection = 1
					SetSpriteFlip(1, 0, 0)
				else
					SetSpriteFlip(1, 1, 0)
				endif
				PlaySprite (1, 10, 0, 1, 8)
			endif
			
			if crabRev = 0 then crabVelo# = crabDirection*crabVeloMax#
		endif
		
		
		crabTheta# = crabTheta# + crabVelo# + planetRotateSpeed#
		if crabTheta# > 360 then inc crabTheta#, -360
		if crabTheta# < 0 then inc crabTheta#, 360

		drawPolar(1, crabR, crabTheta#, GetSpriteWidth(1), GetSpriteHeight(1))
		
		if Mod(gameTime, 170) = 100
			MeteorSpawn(1)
		endif
		if Mod(gameTime-500, 200) = 100
			MeteorSpawn(2)
		endif
		if Mod(gameTime-1100, 260) = 100
			MeteorSpawn(3)
		endif
		if (gameTime = 2000) or (gameTime = 2900) or (gameTime = 2000)
			inc planetRotateSpeed#, .12
		endif
		if (gameTime = 3500) or (gameTime = 3800) or (gameTime = 4100) or (gameTime = 4700) or(gameTime = 5200)
			inc planetRotateSpeed#, -.12
		endif
		
		
		if planetRotateSpeed# <> 0 then SetSpriteAngle(51, GetSpriteAngle(51)+planetRotateSpeed#)
		
		if screenShake <> 0
			inc screenShake, -1
			SetViewOffset(Cos(screenShakeTheta)*screenShake, Sin(screenShakeTheta)*screenShake)
		endif
		
		MeteorUpdate()
		
		//Getting Coins
		for i = 1 to 10
			if GetSpriteExists(200+i)
				if GetSpriteCollision(1, 200+i)
					DeleteSprite(200+i)
					PlaySound(coinSound, 100, 0)
					inc score, 3
					SetTextString(3, "Score: " + Str(score))
				endif
				
				
			endif
			
			
			
		next i
		
		
		//Dying
		/*for i = 1 to 30
			sNum = 100+i 
			if GetSpriteExists(sNum)
				if GetSpriteCollision(1, sNum)
					LoseGame()
					//nMet[sNum - 100, 1] = 0
					gamePlay = 0
					gameLost = 1
					
					CreateSprite(3, LoadImage("retrybutton.png"))
					SetSpriteSize(3, 150, 150)
					SetSpritePosition(3, w/2-GetSpriteWidth(3)/2, 780)
					
					if score > highScore then highScore = score
					SaveGame()
					CreateText(7, "High Score: " + Str(highScore))
					SetTextSize(7, 70)
					SetTextPosition(7, 20, 130)
					SetTextFontImage(7, mainFont)
				endif
			endif
			
		next i*/
		
		
		dead = 0	//Will be 1, 2, 3 depending on meteor hit with
		for i = 1 to 10
				//DEFINATELY CHANGE THE 10 THAT IS TOO BIG
				
			if nMet[i, 1] and Abs(nMet[i, 3] - crabTheta#) < 16 and nMet[i,2] < planetRadius+74
				dead = 1
				gameLost = 1
				MeteorExplode(100+i, 1)
			endif
			if rMet[i, 1] and Abs(rMet[i, 3] - crabTheta#) < 16 and rMet[i,2] < planetRadius+74
				dead = 2
				gameLost = 1
				MeteorExplode(110+i, 2)
			endif
			if fMet[i, 1] and Abs(fMet[i, 3] - crabTheta#) < 16 and fMet[i,2] < planetRadius+74
				dead = 3
				gameLost = 1
				MeteorExplode(120+i, 3)
			endif
			
		next i
		
		//Print(crabTheta#)
		
		if dead > 0
			StopMusicOGG(mainTheme)
			LoseGame(dead)
			//nMet[sNum - 100, 1] = 0
			gamePlay = 0
			//gameLost = 1
			
			for i = 1 to 10
				if nMet[i, 1] then MeteorExplode(100+i, 1)
				if rMet[i, 1] then MeteorExplode(110+i, 2)
				if fMet[i, 1] then MeteorExplode(120+i, 3)
			next i
			
			
			CreateSprite(3, LoadImage("retrybutton.png"))
			SetSpriteSize(3, 150, 150)
			SetSpritePosition(3, w/2-GetSpriteWidth(3)/2, 9780)
			SetSpriteDepth(3, 1)
			
			if score > highScore
				highScore = score
				CreateSprite(22, LoadImage("new.png"))
				SetSpriteSize(22, 128, 70)
				SetSpritePosition(22, 4999, 600)
			endif
			
			if score > 20
				CreateSprite(15, LoadImage("coingray1.png"))
				if score < 50  then SetSpriteColor(15, 205, 127, 50, 255)
				if score > 100 then SetSpriteColor(15, 255, 215, 0, 255)
				if score > 200 then SetSpriteColor(15, 255, 215, 255, 255)
				SetSpriteSize(15, 90, 90)
				SetSpritePosition(15, -100, 100)
				
			endif
			SaveGame()
			CreateText(7, "High Score: " + Str(highScore))
			SetTextSize(7, 70)
			SetTextPosition(7, 20, -400)
			SetTextFontImage(7, mainFont)
			PlayMusicOGG(deathTheme, 0)
			
			for i = 1 to 30
				if GetSpriteExists(100+i) then DeleteSprite(100+i)
				if GetSpriteExists(200+i) then DeleteSprite(200+i)
			next i
			
		endif
		

		
		inc gameTime, 1
	endif
	
	if gameLost = 1
		
		
		//Set Each game over sprite/text position in this type of averagey way
		SetTextPosition(3, 40, (GetTextY(3)*11+295)/12)
		SetTextPosition(7, 80, (GetTextY(7)*11+140)/12)
		SetSpritePosition(3, GetSpriteX(3), (GetSpriteY(3)*11+380)/12)
		
		SetViewOffset(0, (GetViewOffsetY()*11-250)/12)
		if GetSpriteExists(22) then SetSpritePosition(22, (GetSpriteX(22)*11+450)/12, (GetSpriteY(22)*11+200)/12)
		if GetSpriteExists(15) then SetSpritePosition(15, (GetSpriteX(15)*11+350)/12, 35)
		
		if (GetSpriteHitTest(3, GetPointerX(), GetPointerY()+GetViewOffsetY()) and GetPointerPressed()) or GetRawKeyPressed(32)
			gameReady = 1
			gameLost = 0
			DeleteSprite(3)
			PrepareGame()
			
			//CreateText(6, "Tap to go!")
			//SetTextSize(6, 60)
			//SetTextPosition(6, 30, h/2)
			//SetTextDepth(6, 1)
			//SetTextFontImage(6, mainFont)
		endif
		
	endif
	
	SetSpritePosition(4, -GetSpriteHeight(4)/4-GetViewOffsetX()/2, -GetSpriteHeight(4)/4-GetViewOffsetY()/2)
	
    //if GetTextExists(7) then Print(GetTextY(7))
    //Print(ScreenFPS())
    //Print(GetSpriteExists(202))
    
    Sync()
loop

