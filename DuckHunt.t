% David Lafleur
% duck hunt
% Version finale
% 2019-10-12

const pi : real := 3.141592653
const background : int := Pic.FileNew ("duckhuntbackground.bmp")
var DuckImg : int := Pic.FileNew ("greenduckShot.bmp")
const titleScreen : int := Pic.FileNew ("dhunttitle.bmp")
const maxX : int := 1024 %grandeur de la fenetre
const maxY : int := 960
const bottom : int := 200 %definit ou que le canard bondit en bas de l'ecran
var points : int := 0 %nombre de points
var RoundNum : int := 1 %round number
var DispPosxHS : int %utilise pour high score
var numDispHS : int %utilise pour high score
var finished : string := "notFinished" %raison que le jeu est fini
var DuckDisp : array 1 .. 10 of int := init (0, 0, 0, 0, 0, 0, 0, 0, 0, 0) %0 pour blanc, 1 pour noir, 2 pour rouge
var DucksShot : int := 0 %nombre de canards tues
var DuckNum : int := 1 %quel canard de 1-10 que le jouer est entrain de essayer de tuer
var yPos : int := 210 %position x du duck
var xPos : int := 0   %position y du duck
var xSpeed : int := 0 %vitesse x du duck
var ySpeed : int := 0 %vitesse y du duck
var frames : int := 0 %garde un compte de la longueur que le jeu fonctionne
var MouseX : int %position x de la souris
var MouseY : int %position y de la souris
var MouseB : int %position de la souris 0 = rien 1 = left mouse button
var PrevMouse : int := 0 %position de la souris le frame avant
var PrevTimeElapsed : int %utilise pour le timer du canard
var random : int %variable temporaire pour son utilisation dans randint
var Shots : int := 3 %nombre de 3 a 0, indique le montant de shots qui reste
var DuckColor : int %couleur 1:green 2:blue
var DuckSpeed : int := 15 %vitesse de l'oiseau
var DuckAngle : int %angle p.ex. 45deg
var DuckDirection : int %direction soit 1:L 2:UL 3:U 4:UR 5:R
var AnimFrames : int := 0 %utilise pour le flap des ailes
var TopScore : int := 0 %le high score du joueur
const Perfect : int := Pic.FileNew ("perfect.bmp") %image qui dit parfait
const GameOverImg : int := Pic.FileNew ("pause.bmp") %image pour le game over
const Instructions : int := Pic.FileNew ("instructions.bmp") %image des instructions
const FlyAwayImg : int := Pic.FileNew ("fly away.bmp") %image pour le fly away
var dogwalk : array 1 .. 4 of string := init ("dogwalk1.bmp", "dogwalk2.bmp", "dogwalk3.bmp", "dogwalk4.bmp")
var dogImage : int %dog image
var duckFallDirection : int := 0 %pour eviter de creer trop de id de images 0=gauche 1=droite
var imageList : array 1 .. 2, 1 .. 5, 1 .. 3 of string := init %array pour les images
    ("greenduckL1.bmp", "greenduckL2.bmp", "greenduckL3.bmp",
    "greenduckUL1.bmp", "greenduckUL2.bmp", "greenduckUL3.bmp",
    "greenduckU1.bmp", "greenduckU2.bmp", "greenduckU3.bmp",
    "greenduckUR1.bmp", "greenduckUR2.bmp", "greenduckUR3.bmp",
    "greenduckR1.bmp", "greenduckR2.bmp", "greenduckR3.bmp",
    "blueduckL1.bmp", "blueduckL2.bmp", "blueduckL3.bmp",
    "blueduckUL1.bmp", "blueduckUL2.bmp", "blueduckUL3.bmp",
    "blueduckU1.bmp", "blueduckU2.bmp", "blueduckU3.bmp",
    "blueduckUR1.bmp", "blueduckUR2.bmp", "blueduckUR3.bmp",
    "blueduckR1.bmp", "blueduckR2.bmp", "blueduckR3.bmp")

%ajuste l'ecran
setscreen ("graphics:" + intstr (maxX) + ";" + intstr (maxY) + ",nobuttonbar,offscreenonly")

% musique

process RoundClearMusic
    Music.PlayFile ("RoundClear.mp3")
end RoundClearMusic

process fallSFX
    Music.PlayFile ("DeadDuckFalls.wav")
end fallSFX

process RoundIntroMusic
    Music.PlayFile ("RoundIntro.mp3")
end RoundIntroMusic

process flap
    Music.PlayFile ("flap flap.wav")
end flap

process GunShot
    Music.PlayFile ("Gunshot.mp3")
end GunShot

process TitleMusic
    Music.PlayFile ("TitleScreen.mp3")
end TitleMusic

process DogLaugh
    Music.PlayFile ("Laugh.wav")
end DogLaugh

procedure UpdateShots
    Draw.FillBox (186 - (32 * (3 - Shots)), 96, 186, 128, black)
end UpdateShots

procedure MinPassLevel %pas implement
end MinPassLevel

procedure DuckDisplay %dessine les canards
    for i : 1 .. 10
	if i = DuckNum and finished = "notFinished" then
	    case frames mod 16 of
		label 1, 2, 3, 4, 5, 6, 7, 8 :
		    Draw.FillBox (380 + ((i - 1) * 32), 96, 380 + (i * 32), 128, 16) %noir
		label :
		    Draw.FillBox (380 + ((i - 1) * 32), 96, 380 + (i * 32), 128, 31) %blanc
	    end case
	else
	    if DuckDisp (i) = 0 then %blanc
		Draw.FillBox (380 + ((i - 1) * 32), 96, 380 + (i * 32), 128, 31)
	    elsif DuckDisp (i) = 1 then %noir
		Draw.FillBox (380 + ((i - 1) * 32), 96, 380 + (i * 32), 128, 16)
	    elsif DuckDisp (i) = 2 then %rouge
		Draw.FillBox (380 + ((i - 1) * 32), 96, 380 + (i * 32), 128, 12)
	    end if
	end if
    end for
end DuckDisplay

procedure VertDisp (input : string) %imprime la ronde
    var DispPosX : int := 156
    var numDisp : int
    for i : 1 .. length (input)
	numDisp := Pic.FileNew ("vert" + input (i) + ".bmp")
	Pic.Draw (numDisp, DispPosX, 160, picMerge)
	DispPosX += 32
	Pic.Free (numDisp)
    end for
end VertDisp

procedure BlancDisp (input : string) %imprime le score
    var scorestr := input
    var DispPosX : int := 768 %utilise lors du prodecure BlancDisp
    var numDisp : int %image du chiffre que BlancDisp
    loop
	exit when length (scorestr) = 6
	scorestr := "0" + scorestr
    end loop
    for i : 1 .. 6
	numDisp := Pic.FileNew ("blanc" + scorestr (i) + ".bmp")
	Pic.Draw (numDisp, DispPosX, 96, picMerge)
	DispPosX += 32
	Pic.Free (numDisp)
    end for
end BlancDisp

procedure DrawFG
    DuckDisplay
    Pic.Draw (background, 0, 0, picMerge)
    BlancDisp (intstr (points))
    VertDisp (intstr (RoundNum))
    UpdateShots
    MinPassLevel
end DrawFG
 
procedure draw %dessine tout
    cls
    if finished = "notFinished" or finished = "killed" then
	Draw.FillBox (0, 0, maxX, maxY, 53) %blue
    elsif finished = "time" or finished = "missed" then
	Draw.FillBox (0, 0, maxX, maxY, 60) %pink
    end if
    DuckDisplay
    %enleve commentaire pour montrer le hitbox
    %Draw.FillBox (xPos,yPos,xPos+136,yPos+136,red) %hit box
    Pic.Draw (DuckImg, xPos, yPos, picMerge)
    Pic.Draw (background, 0, 0, picMerge)
    BlancDisp (intstr (points))
    VertDisp (intstr (RoundNum))
    UpdateShots
    MinPassLevel
    View.Update
end draw


procedure DuckOrder % met les canards en ordre
    var count : int := 0
    loop
	for i : 2 .. 10
	    if DuckDisp (i - 1) = 0 and DuckDisp (i) = 2 then
		DuckDisp (i) := 0
		DuckDisp (i - 1) := 2
		count += 1
	    end if
	end for
	if count = 0 then
	    exit
	end if
	Draw.FillBox(0,0,maxX,maxY,53)
	DrawFG
	View.Update
	Music.PlayFile("CountingHits.wav")
	count := 0
    end loop
end DuckOrder

procedure dogAnimation %fait l'animation du chien
    var Ybottom : int := 152
    var animFrame : int := 1
    fork RoundIntroMusic
    for i : 1 .. 600 by 2
	cls
	if i mod 15 = 0 then
	    animFrame += 1
	end if
	if animFrame = 5 then
	    animFrame := 1
	end if
	Draw.FillBox (0, 0, maxX, maxY, 53) %blue
	DrawFG
	dogImage := Pic.FileNew (dogwalk (animFrame))
	Pic.Draw (dogImage, i - 100, Ybottom, picMerge)
	Pic.Free (dogImage)
	View.Update
	delay (2)
    end for
    for i : 1 .. 5
	cls
	if i mod 2 = 0 then
	    dogImage := Pic.FileNew ("dogwalk4.bmp")
	else
	    dogImage := Pic.FileNew ("dogsniff.bmp")
	end if
	Draw.FillBox (0, 0, maxX, maxY, 53) %blue
	DrawFG
	Pic.Draw (dogImage, 500, Ybottom, picMerge)
	Pic.Free (dogImage)
	delay (100)
	View.Update
    end for
    cls
    Draw.FillBox (0, 0, maxX, maxY, 53) %blue
    DrawFG
    dogImage := Pic.FileNew ("dogjump1.bmp")
    Pic.Draw (dogImage, 500, Ybottom, picMerge)
    View.Update
    Music.PlayFile ("Bark.wav")
    delay (5)
    Music.PlayFile ("Bark.wav")
    Pic.Free (dogImage)
    for i : 1 .. 200 by 2
	var DogY : int := 0
	cls
	DogY := (- ((i - 1) * (i - 200)) div 40) + Ybottom
	Draw.FillBox (0, 0, maxX, maxY, 53) %blue
	if i <= 100 then
	    DrawFG
	    dogImage := Pic.FileNew ("dogjump2.bmp")
	    Pic.Draw (dogImage, i + 500, DogY, picMerge)
	else
	    dogImage := Pic.FileNew ("dogjump3.bmp")
	    Pic.Draw (dogImage, i + 500, DogY, picMerge)
	    DrawFG
	end if
	Pic.Free (dogImage)
	View.Update
	%delay (1)
    end for
end dogAnimation

function GetXspeed (angle, speed : int) : int %transforme coord polaire a cartesien x
    result round (speed * cos ((angle / 180) * pi))
end GetXspeed

function GetYspeed (angle, speed : int) : int %transforme coord polaire a cartesien y
    result round (speed * sin ((angle / 180) * pi))
end GetYspeed

%Main loop
/*
 Les angles sont comme ceci

 .                       90 deg
 .                  ###########
 .              #####         #### @@@@@@ (contre le sens de l'horloge)
 .            ###                 @
 .           ##                  @  ##
 .          ##                  @    ##
 .         ##                         ##
 .         #                           #
 .180 deg  #             O8888888888888888888 0 deg/360 deg
 .         #                           #
 .         ##                         ##
 .          ##                       ##
 .           ##                     ##
 .            ###                 ###
 .              #####         #####
 .                  ###########
 .                      270 deg

 */

loop %loop chaque game over
    fork TitleMusic
    loop
	cls
	mousewhere (MouseX, MouseY, MouseB)
	Pic.Draw (titleScreen, 0, 0, picCopy)
	DispPosxHS := 608
	for i : 1 .. length (intstr (TopScore))
	    numDispHS := Pic.FileNew ("vert" + intstr (TopScore) (i) + ".bmp")
	    Pic.Draw (numDispHS, DispPosxHS, 192, picMerge)
	    DispPosxHS += 32
	    Pic.Free (numDispHS)
	end for
	if Time.Elapsed mod 30000 >= 29990 then %joue la musique chaque 30 secondes
	    fork TitleMusic
	end if
	if MouseX >= 226 and MouseY >= 370 and MouseX <= 540 and MouseY <= 410 then %commencer
	    Draw.FillBox (190, 315, 224, 345, black) %couvrir instruction
	    Draw.FillBox (190, 225, 224, 295, black) %couvrir sortie
	elsif MouseX >= 226 and MouseY >= 310 and MouseX <= 610 and MouseY <= 350 then %instructions
	    Draw.FillBox (190, 370, 224, 400, black) %couvir commencer
	    Draw.FillBox (190, 225, 224, 295, black) %couvrir sortie
	elsif MouseX >= 225 and MouseY >= 225 and MouseX <= 420 and MouseY <= 295 then %sortie
	    Draw.FillBox (190, 370, 224, 400, black) %couvir commencer
	    Draw.FillBox (190, 315, 224, 345, black) %couvrir instruction
	else
	    Draw.FillBox (190, 370, 224, 400, black) %couvir commencer
	    Draw.FillBox (190, 225, 224, 295, black) %couvrir sortie
	    Draw.FillBox (190, 315, 224, 345, black) %couvrir instruction
	end if
	if MouseB = 1 and MouseX >= 225 and MouseY >= 225 and MouseX <= 420 and MouseY <= 295 then
	    finished := "finitout"
	    exit
	end if
	View.Update
	mousewhere (MouseX, MouseY, MouseB)
	if MouseB = 1 and MouseX >= 226 and MouseY >= 310 and MouseX <= 610 and MouseY <= 350 then
	    fork GunShot
	    loop
		cls
		mousewhere (MouseX, MouseY, MouseB)
		Pic.Draw (Instructions, 0, 0, picCopy)
		View.Update
		exit when MouseB = 1 and MouseX >= 575 and MouseY >= 36 and MouseX <= 960 and MouseY <= 190
	    end loop
	    fork GunShot
	end if
	exit when MouseB = 1 and MouseX >= 226 and MouseY >= 370 and MouseX <= 540 and MouseY <= 410
    end loop
    if finished = "finitout" then
	Music.PlayFile("Gunshot.mp3")
	exit
    end if
    dogAnimation
    loop %loop chaque round
	%setup state
	loop %loops pour chaque canard
	    PrevTimeElapsed := Time.Elapsed
	    fork flap %fait le son flap
	    yPos := bottom
	    randint (DuckColor, 1, 2) %1: vert ou 2: bleu (rouge existe mais ca me tente pas de editer 24 photos individuellement encore)
	    randint (xPos, 250, 850)
	    randint (random, 1, 3)
	    if random = 1 then %angle 20 deg (bas)
		randint (random, 1, 2)
		if random = 1 then %vers la gauche
		    DuckAngle := 160
		else %vers la droite
		    DuckAngle := 20
		end if
	    elsif random = 2 then %angle 45 (medium)
		randint (random, 1, 2)
		if random = 1 then %vers la gauche
		    DuckAngle := 135
		else %vers la droite
		    DuckAngle := 45
		end if
	    elsif random = 3 then %angle 60 (haut)
		randint (random, 1, 2)
		if random = 1 then %vers la gauche
		    DuckAngle := 120
		else %vers la droite
		    DuckAngle := 60
		end if
	    end if
	    loop % ce code est execute a chaque frame
		mousewhere (MouseX, MouseY, MouseB) % definit la souris
		%definit la direction (refer to directionChart.png)
		DuckAngle := DuckAngle mod 360
		if DuckAngle >= 65 and DuckAngle <= 115 then % en haut
		    DuckDirection := 3
		elsif (DuckAngle >= 25 and DuckAngle <= 65) or (DuckAngle >= 270 and DuckAngle <= 335) then %en haut a la droite et en bas a la droite
		    DuckDirection := 4
		elsif (DuckAngle >= 335 and DuckAngle <= 360) or (DuckAngle >= 0 and DuckAngle <= 25) then % droite
		    DuckDirection := 5
		elsif (DuckAngle >= 115 and DuckAngle <= 155) or (DuckAngle >= 205 and DuckAngle <= 270) then % en haut a la gauche et en bas a la gauche
		    DuckDirection := 2
		elsif DuckAngle >= 155 and DuckAngle <= 205 then % gauche
		    DuckDirection := 1
		else
		    assert 1 = 2
		end if
		%animation change a chaque 3 frames
		if AnimFrames = 10 then
		    AnimFrames := 1
		end if
		if AnimFrames >= 1 and AnimFrames <= 3 then
		    Pic.Free (DuckImg)
		    DuckImg := Pic.FileNew (imageList (DuckColor, DuckDirection, 1)) %ajoute une photo en memoire
		elsif AnimFrames >= 4 and AnimFrames <= 6 then
		    Pic.Free (DuckImg)
		    DuckImg := Pic.FileNew (imageList (DuckColor, DuckDirection, 2))
		elsif AnimFrames >= 7 and AnimFrames <= 9 then
		    Pic.Free (DuckImg)
		    DuckImg := Pic.FileNew (imageList (DuckColor, DuckDirection, 3))
		end if
		%verification de collision
		random := 0
		if xPos < 0 then %cote gauche
		    if ySpeed > 0 then %vers le haut
			DuckAngle := 180 - DuckAngle
			randint (random, -1, 0)
		    else %vers le bas, ca glitch le jeu alors jai fait que ca fait juste rebondir
			randint (random, 0, 1)
		    end if
		    DuckAngle += 50 * random
		end if
		if xPos + 136 > maxX then %cote droit
		    if ySpeed > 0 then %vers le haut
			DuckAngle := 180 - DuckAngle
			randint (random, 0, 1)
		    else %vers le bas
			DuckAngle := 540 - DuckAngle
			randint (random, -1, 0)
		    end if
		    DuckAngle += 50 * random
		end if
		if yPos < bottom then %le bas
		    if xSpeed > 0 then %vers la droite
			DuckAngle := 360 - DuckAngle
			randint (random, 0, 1)
		    else %vers la gauche
			DuckAngle := 360 - DuckAngle
			randint (random, -1, 0)
		    end if
		    DuckAngle += 50 * random
		end if
		if yPos + 136 > maxY then %le haut
		    if xSpeed > 0 then %vers la droite
			DuckAngle := 360 - DuckAngle
			randint (random, -1, 0)
		    else %vers la gauche
			DuckAngle := 360 - DuckAngle
			randint (random, 0, 1)
		    end if
		    DuckAngle += 50 * random
		end if
		%fail safe
		DuckAngle := abs (DuckAngle) mod 360
		if xPos > maxX or xPos < -50 or yPos > maxY or yPos < 0 then
		    DuckAngle := 45
		    yPos := 480
		    xPos := 512
		end if
		%timer check
		if Time.Elapsed - PrevTimeElapsed > 4500 then
		    finished := "time"
		    exit
		end if
		%run out of gun check
		if Shots < 1 then
		    finished := "missed"
		    exit
		end if
		%gun shoot
		if MouseB = 1 and PrevMouse = 0 then
		    if MouseX > xPos and MouseX < xPos + 136 and MouseY > yPos and MouseY < yPos + 136 then
			finished := "killed"
			exit
		    else
			Shots -= 1
		    end if
		    fork GunShot
		end if
		xSpeed := GetXspeed (DuckAngle, DuckSpeed)
		ySpeed := GetYspeed (DuckAngle, DuckSpeed)
		xPos += xSpeed
		yPos += ySpeed
		draw
		frames += 1
		AnimFrames += 1
		DuckAngle := abs (DuckAngle) mod 360
		PrevMouse := MouseB
		Time.Delay (5) %1/60 d'une seconde (incluant temps que ca prend pour executer le code)
	    end loop
	    %quand le canard s'est envole ou si il est mort
	    Music.PlayFileStop
	    draw
	    if finished = "missed" or finished = "killed" then %a cause que j'eteint tous les autres sons je le rejoue ici
		fork GunShot
	    end if
	    if finished = "killed" then %si le canard est tue dans le temps
		%changer les variables
		Shots -= 1
		DuckDisp (DuckNum) := 2
		if DuckColor = 1 then
		    points += 500
		elsif DuckColor = 2 then
		    points += 1000
		end if
		DucksShot += 1
		draw
		%do duck falling animation
		if DuckColor = 1 then %si le canard est vert
		    DuckImg := Pic.FileNew ("greenduckShot.bmp")
		elsif DuckColor = 2 then %si le canard est bleu
		    DuckImg := Pic.FileNew ("blueduckShot.bmp")
		end if
		draw
		Pic.Free (DuckImg)
		delay (1000)
		fork fallSFX
		yPos := (yPos div 7) * 7 %fait que la position est un multiple de 5
		loop % fall and alternate left and right
		    cls
		    yPos -= 7
		    Draw.FillBox (0, 0, maxX, maxY, 53) %blue
		    if duckFallDirection = 0 then %gauche
			if DuckColor = 2 then
			    DuckImg := Pic.FileNew ("blueduckFall1.bmp")
			else
			    DuckImg := Pic.FileNew ("greenduckFall1.bmp")
			end if
		    elsif duckFallDirection = 1 then %droite
			if DuckColor = 2 then
			    DuckImg := Pic.FileNew ("blueduckFall2.bmp")
			else
			    DuckImg := Pic.FileNew ("greenduckFall2.bmp")
			end if
		    end if
		    if yPos mod 21 = 0 then
			if duckFallDirection = 0 then %gauche
			    duckFallDirection := 1
			else % droite
			    duckFallDirection := 0
			end if
		    end if
		    Pic.Draw (DuckImg, xPos, yPos, picMerge)
		    Pic.Free (DuckImg)
		    DrawFG
		    exit when yPos <= bottom
		    %draw things
		    View.Update
		end loop
		Music.PlayFileStop
		DuckImg := Pic.FileNew ("blueduckFall1.bmp") % cette image se fera enlevee sur le premier frame
		%stomp sound
		Music.PlayFile ("DeadDuckLands.wav")
		dogImage := Pic.FileNew ("dog1bird.bmp")
		for i : 1 .. 200 by 6 %go up
		    cls
		    Draw.FillBox (0, 0, maxX, maxY, 53)
		    DuckDisplay
		    Pic.Draw (dogImage, 400, i + 130, picMerge)
		    DrawFG
		    delay (2)
		    View.Update
		end for
		Music.PlayFile ("GotADuck.wav")
		for decreasing i : 200 .. 1 by 6 %go down
		    cls
		    Draw.FillBox (0, 0, maxX, maxY, 53)
		    Pic.Draw (dogImage, 400, i + 130, picMerge)
		    DrawFG
		    delay (2)
		    View.Update
		end for
		Pic.Free (dogImage)
	    else %do fly away et animation du chien
		yPos -= yPos mod 3
		for i : yPos .. 960 by 9
		    cls
		    yPos += 9
		    Draw.FillBox (0, 0, maxX, maxY, 60) %pink
		    if yPos mod 6 = 0 then
			AnimFrames += 1
		    end if
		    if AnimFrames > 3 then
			AnimFrames := 1
		    end if
		    DuckImg := Pic.FileNew (imageList (DuckColor, 3, AnimFrames))
		    if DuckColor = 1 then %vert
			Pic.Draw (DuckImg, xPos, yPos, picMerge)
		    elsif DuckColor = 2 then %bleu
			Pic.Draw (DuckImg, xPos, yPos, picMerge)
		    end if
		    Pic.Free (DuckImg)
		    DrawFG
		    Pic.Draw (FlyAwayImg, (maxX div 2) - (Pic.Width (FlyAwayImg) div 2), 600, picMerge)
		    delay (2)
		    View.Update
		end for
		DuckImg := Pic.FileNew ("blueduckFall1.bmp") % cette image se fera enlevee sur le premier frame
		dogImage := Pic.FileNew ("doglaugh1.bmp")
		for i : 1 .. 200 by 6 %go up
		    cls
		    Draw.FillBox (0, 0, maxX, maxY, 53)
		    Pic.Draw (dogImage, 400, i + 130, picMerge)
		    DrawFG
		    delay (2)
		    View.Update
		end for
		fork DogLaugh
		Pic.Free (dogImage)
		for i : 1 .. 15
		    if i mod 2 = 0 then
			dogImage := Pic.FileNew ("doglaugh2.bmp")
		    else
			dogImage := Pic.FileNew ("doglaugh1.bmp")
		    end if
		    Draw.FillBox (0, 0, maxX, maxY, 53)
		    Pic.Draw (dogImage, 400, 330, picMerge)
		    DrawFG
		    Pic.Free (dogImage)
		    View.Update
		    delay (100)
		end for
		dogImage := Pic.FileNew ("doglaugh1.bmp")
		for decreasing i : 200 .. 1 by 6 %go down
		    cls
		    Draw.FillBox (0, 0, maxX, maxY, 53)
		    Pic.Draw (dogImage, 400, i + 130, picMerge)
		    DrawFG
		    delay (2)
		    View.Update
		end for
		Pic.Free (dogImage)
	    end if
	    exit
	end loop
	%reset variables other than duck
	delay (500)
	%do dog animation and round
	Shots := 3
	finished := "notFinished"
	DuckNum += 1
	if DuckNum > 10 then %si la ronde est terminee
	    DuckOrder % met les canards en ordre
	    if DucksShot < 6 then %game over
		Pic.Draw (GameOverImg, (maxX div 2) - (Pic.Width (GameOverImg) div 2), 600, picMerge)
		View.Update
		Music.PlayFile ("Failed.mp3")
		Music.PlayFile ("GameOver.mp3")
		RoundNum := 1
		DuckSpeed := 15
		DuckNum := 1
		if TopScore < points then %definit le high score
		    TopScore := points
		end if
		points := 0
		for i : 1 .. 10
		    DuckDisp (i) := 0
		end for
		exit
	    else
		fork RoundClearMusic
		for i : 1 .. 10
		    if i mod 2 = 0 then
			cls
			Draw.FillBox (0, 0, maxX, maxY, 53) %blue
			for j : 1 .. 10
			    if DuckDisp (j) = 0 then %blanc
				Draw.FillBox (380 + ((j - 1) * 32), 96, 380 + (j * 32), 128, 31)
			    elsif DuckDisp (j) = 1 then %noir
				Draw.FillBox (380 + ((j - 1) * 32), 96, 380 + (j * 32), 128, 16)
			    elsif DuckDisp (j) = 2 then %rouge
				Draw.FillBox (380 + ((j - 1) * 32), 96, 380 + (j * 32), 128, 12)
			    end if
			end for
			Pic.Draw (background, 0, 0, picMerge)
			BlancDisp (intstr (points))
			VertDisp (intstr (RoundNum))
			UpdateShots
			MinPassLevel
			View.Update
		    else
			cls
			Draw.FillBox (0, 0, maxX, maxY, 53) %blue
			for j : 1 .. 10
			    Draw.FillBox (380 + ((j - 1) * 32), 96, 380 + (j * 32), 128, 16)
			end for
			Pic.Draw (background, 0, 0, picMerge)
			BlancDisp (intstr (points))
			VertDisp (intstr (RoundNum))
			UpdateShots
			MinPassLevel
			View.Update
		    end if
		    delay (380)
		end for
		if DucksShot = 10 then
		    points += 10000
		    draw
		    Pic.Draw (Perfect, (maxX div 2) - (Pic.Width (Perfect) div 2), 600, picMerge)
		    View.Update
		    Music.PlayFile ("Perfect.mp3")
		end if
		for i : 1 .. 10
		    DuckDisp (i) := 0
		end for
		DuckNum := 1
		RoundNum += 1
		DuckSpeed += 1
		DucksShot := 0
		finished := "animation"
		dogAnimation %fait l'animation du chien
		finished := "notFinished"
		if RoundNum > 11 and DuckNum = 1 then
		    DuckSpeed += 2
		end if
	    end if
	end if
    end loop
end loop
