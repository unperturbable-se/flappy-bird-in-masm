INCLUDE Irvine32.inc
.data
windowwidth      equ 70
windowheight     equ 70
platformdelay    equ 10
platformWidth    equ 4
holeheight       equ 15
birdposx         equ windowwidth/2
birdposy         byte windowheight/2+8
maxbirdposy      byte windowheight/2+16
time             dword 0
score            dword 0
highScore        dword 0
jumpheight       equ 7
continueGame     byte 1
backgroundColour dword blue+(black*16)
platformColour   dword green+(black*16)
birdColour       dword yellow+(black*16)

;velocity      equ 1
;acceleration  equ 0

birdSprite BYTE\
     0,0,1,1,0,0,0,0
BYTE 0,1,1,1,1,0,0,0
BYTE 1,1,1,1,1,1,0,0
BYTE 1,1,1,1,1,1,1,0
BYTE 1,1,1,1,1,1,0,0
BYTE 1,1,0,1,1,0,0,0
BYTE 0,1,0,0,1,0,0,0
BYTE 0,0,0,0,0,0,0,0 

airplane BYTE\
     0,0,0,1,1,0,0,0
BYTE 0,0,1,1,1,1,0,0
BYTE 0,1,1,1,1,1,1,0
BYTE 0,0,0,1,1,1,0,1
BYTE 0,0,1,1,1,1,0,1
BYTE 0,1,1,1,1,1,1,0
BYTE 0,0,0,1,1,1,0,0
BYTE 0,0,0,0,1,0,0,0

Gameovertext BYTE\
     "  ____   ____  ___ ___    ___ "   
BYTE " /    | /    ||   |   |  /  _]"   
BYTE "|   __||  o  || _   _ | /  [_ "   
BYTE "|  |  ||     ||  \_/  ||    _]"   
BYTE "|  |_ ||  _  ||   |   ||   [_ "   
BYTE "|     ||  |  ||   |   ||     |"   
BYTE "|___,_||__|__||___|___||_____|"   
BYTE "                              "   
BYTE "  ___   __ __    ___  ____    "   
BYTE " /   \ |  |  |  /  _]|    \   "   
BYTE "|     ||  |  | /  [_ |  D  )  "   
BYTE "|  O  ||  |  ||    _]|    /   "   
BYTE "|     ||  :  ||   [_ |    \   "   
BYTE "|     | \   / |     ||  .  \  "   
BYTE " \___/   \_/  |_____||__|\_|  "   
BYTE "                              "   
BYTE "                              "   
BYTE "                              "   
BYTE " _____  _____  _____  _____   "   
BYTE "|     ||     ||     ||     |  "   
BYTE "|_____||_____||_____||_____|  "   
BYTE "                              "   
                                  
ScoreText byte "Current Score:",0
HighScoreText byte "High Score:" ,0  

startPrompt1 byte "Flappy Bird",0
startPrompt2 byte "--------------",0
startPrompt3 byte "1.Start Game",0
startPrompt4 byte "2.Instructions",0
startPrompt5 byte "3.Exit Game",0
startPrompt6 byte "--------------",0
istr1 byte "How To Play",0
istr2 byte "1.Press W to jump",0
istr3 byte "2.Press A or D to choose between birds",0
istr4 byte "3.Press 1,2,3 or 4 to choose themes",0
istr5 byte "Good luck!",0
istr6 byte "-------------------------------",0

endstr1 byte "Options:",0
endstr2 byte "1.Exit to main menu",0
endstr3 byte "2.Leave Game",0
endstr4 byte "------------------",0

filename byte "highscore.txt",0
filehandle dword ?
fileBuffer byte 100 dup(0)

comment1 byte "Hey! your rocking     ",0
comment2 byte "Good Job!             ",0
comment3 byte "Well Done!            ",0
comment4 byte "Yeah! lessgo          ",0
comment5 byte "Good                  ",0
comment6 byte "nice                  ",0
comment7 byte "perfect!              ",0
comment8 byte "yayyyy! you can do it.",0

.code
;--------------------------------------
    displayBackground proc ;runs only once
    call clrscr 
    mov  eax,backgroundColour
    call SetTextColor
    mov dh,0
    OuterLoop:
        mov dl,0
        innerLoop:
            call gotoxy
            mov al,219
            call writechar
            inc dl
            cmp dl,windowwidth
            jnz innerloop
        inc dh
        cmp dh,windowheight
        jnz OuterLoop
    ret
    displayBackground endp
;--------------------------------------
movePlatform proc uses eax ;takes dl as input, takes bh,bl as input(hole height is between bl,bh)
;adds speed number of columns, removes speed number of columns(future addition)
mov  eax,platformColour
call SetTextColor
    mov dh,0
    addcolumn:
         cmp dh,bl
         jnge print
         cmp dh,bh
         jnle print
         jmp dontprint
         print:
         call gotoxy
         mov al, 219
         call writechar
         dontprint:
         inc dh
         cmp dh,windowheight
         jnz addcolumn

mov  eax,backgroundColour
call SetTextColor  
    mov dh,0
    add dl,platformWidth+1
    cmp dl,windowwidth
    jge end1
    removecolumn:
         call gotoxy
         mov al, 219
         call writechar
         inc dh
         cmp dh,windowheight
         jnz removecolumn
    end1:
         sub dl,platformWidth+1
         dec dl
ret
movePlatform endp
;--------------------------------------
addplatform proc uses edx;parameter dl(x coordinate), bl-bh is y-range of hole
mov  eax,platformColour
call SetTextColor
push ecx
mov cl,0 
outerLoop:
    mov dh,0
    innerLoop:
         cmp dh,bl
         jnge print
         cmp dh,bh
         jnle print
         jmp dontprint
         print:
         call gotoxy
         mov al, 219
         call writechar
         dontprint:
         inc dh
         cmp dh,windowheight
         jnz innerLoop 
    inc dl
    inc cl
    cmp cl,platformWidth
    jnz outerLoop
pop ecx
ret
addplatform endp
;--------------------------------------
removeplatform proc ;parameter dl(x coordinate)
mov  eax,backgroundColour
call SetTextColor
mov dl,0 
outerLoop:
    mov dh,0
    innerLoop:
         call gotoxy
         mov al, 219
         call writechar
         inc dh
         cmp dh,windowheight
         jnz innerLoop 
    inc dl
    cmp dl,platformWidth+1
    jnz outerLoop
ret
removeplatform endp
;--------------------------------------
randomizehole proc uses eax ;returns bl(windowheight*.25 to windowheight*.75),bh(bl+holehight)
mov eax,windowheight
mov ebx,windowheight
shr eax,1 ;0.5
shr ebx,2; 0.25
call randomrange
add eax,ebx ;rand(0 to 0.5)+0.25
mov bl,al
mov bh,bl
add bh,holeheight
ret
randomizehole endp
;--------------------------------------
addbird proc uses edx ecx
mov  eax,birdColour
call SetTextColor
mov ecx,0 ;index
mov dh,birdposy
outerloop:
     mov dl,birdposx
     innerloop:
          cmp byte ptr [esi+ecx],1
          jne endloop
          call gotoxy
          mov al,219
          call writechar
          endloop:
          inc ecx
          inc dl
          cmp dl,birdposx+8
          jne innerloop
    inc dh
    cmp dh,maxbirdposy
    jne outerloop
ret
addbird endp
;--------------------------------------
removebird proc uses edx ecx
mov  eax,backgroundColour
call SetTextColor
mov ecx,0 ;index
mov dh,birdposy
outerloop:
     mov dl,birdposx
     innerloop:
          call gotoxy
          mov al,219
          call writechar
          inc dl
          cmp dl,birdposx+8
          jne innerloop
    inc dh
    cmp dh,maxbirdposy
    jne outerloop
ret
removebird endp
;--------------------------------------
getkey proc uses edx ebx eax
call readkey
jz return

cmp al,'a'
jz airplane_
cmp al,'A'
jz airplane_
cmp al, 'd'
jz bird_
cmp al, 'D'
jz bird_
jmp checkmovement
airplane_: 
lea esi,airplane
jmp changeCharacter
bird_:
lea esi,birdSprite
jmp changeCharacter
changeCharacter:
call removebird
jmp return
;----------------------------------------------
checkmovement:
cmp al,'w'
jz up
cmp al,'W'
jz up
jmp checkNums
up:
     call removebird
     sub birdposy,jumpheight
     sub maxbirdposy,jumpheight

return: ret
;----------------------------------------------
checkNums:
cmp al,'1'
jz theme1
cmp al,'2'
jz theme2
cmp al,'3'
jz theme3
cmp al,'4'
jz theme4
jmp return

theme1:
       mov backgroundColour,blue+(black*16)
       mov birdColour,white+(black*16)
       mov platformColour,green+(black*16)
       jmp changetheme
theme2:
       mov backgroundColour,black+(black*16)
       mov birdColour,white+(black*16)
       mov platformColour,green+(black*16)
       jmp changetheme
theme3:
       mov backgroundColour,white+(black*16)
       mov birdColour,green+(black*16)
       mov platformColour,cyan+(black*16)
       jmp changetheme
theme4:
       mov backgroundColour,red+(black*16)
       mov birdColour,green+(black*16)
       mov platformColour,brown+(black*16)
changetheme:
       call removebird
       call addbird
       ret
getkey endp
;--------------------------------------
falldown proc uses eax ;velocity=1/4*time
mov eax,time
and eax,00000001h
cmp eax,00000001h
jnz return
call removebird
inc birdposy
inc maxbirdposy
return:ret
falldown endp
;--------------------------------------
checkCollision proc
cmp maxbirdposy,windowheight
jz collided
cmp birdposy,0
jz collided
cmp maxbirdposy,bh
jge check
cmp birdposy,bl
jle check
ret
check:
      cmp dl,birdposx
      je collided
ret
collided:mov continueGame,0
checkCollision endp
;--------------------------------------
showScore proc uses edx eax
mov  eax,white+(black*16)
call SetTextColor
mov dh,0
mov dl,windowwidth+20
call gotoxy
lea edx,ScoreText
mov eax,score
call writestring
call writedec

mov dh,2
mov dl,windowwidth+20
call gotoxy
lea edx,HighScoreText
mov eax,highScore
call writestring
call writedec
ret
showScore endp
;--------------------------------------
addcommentary proc uses eax edx
mov  eax,cyan+(white*16)
call SetTextColor
mov dh,4
mov dl,windowwidth+20
call gotoxy
mov eax,time
shl al,5
shr al,5
cmp al,0
jz c1
cmp al,1
jz c2
cmp al,2
jz c3
cmp al,3
jz c4
cmp al,4
jz c5
cmp al,5
jz c6
cmp al,6
jz c7
cmp al,7
jz c8
c1: lea edx,comment1
jmp print
c2: lea edx,comment2
jmp print
c3: lea edx,comment3
jmp print
c4: lea edx,comment4
jmp print
c5: lea edx,comment5
jmp print
c6: lea edx,comment6
jmp print
c7: lea edx,comment7
jmp print
c8: lea edx,comment8
print: call writestring
ret
addcommentary endp
;--------------------------------------
game proc
mov birdposy,windowheight/2
mov maxbirdposy,windowheight/2+8
mov score,0
lea esi,airplane ;set character
call displayBackground
call addbird
outerloop:
    call randomizehole
    call showScore
    call addcommentary
    mov dl,windowwidth-platformWidth-1
    call addplatform
    mov dl,windowwidth-platformWidth-1
    loop1:
          call moveplatform
          call getkey
          mov eax,platformdelay
          call delay
          inc time
          call falldown
          call addbird
          call checkCollision
          cmp continueGame,0
          jz return
          cmp dl,0
          jge loop1
    call removeplatform
    inc score
    jmp outerLoop

return:ret
game endp
;----------------------------------------
gameoverscreen proc
lea esi,Gameovertext
mov  eax,black+(white*16)
call SetTextColor
call clrscr
mov dh,0
    outerloop:
        mov dl,0
        innerloop:
             call gotoxy
             mov al,[esi]
             call writechar
             inc esi
             inc dl
             cmp dl,30
             jnz innerLoop
        inc dh
        cmp dh,22
        jnz outerLoop
        call readchar
ret
gameoverscreen endp
;----------------------------------------

startScreen proc
mov  eax,black+(white*16)
call SetTextColor
call clrscr
start:
     lea edx,startPrompt1
     call writestring
     call crlf
     lea edx,startPrompt2
     call writestring
     call crlf
     lea edx,startPrompt3
     call writestring
     call crlf
     lea edx,startPrompt4
     call writestring
     call crlf
     lea edx,startPrompt5
     call writestring
     call crlf
     lea edx,startPrompt6
     call writestring
     call crlf
     call readchar
     cmp al,'1'
     jz startGame
     cmp al,'2'
     jz instructions
     cmp al,'3'
     jz endGame
     call clrscr
     jmp start
startGame:
     ret
instructions:  
     call clrscr
     call crlf 
     lea edx,istr1
     call writestring
     call crlf
     lea edx,istr2
     call writestring
     call crlf
     lea edx,istr3
     call writestring
     call crlf
     lea edx,istr4
     call writestring
     call crlf
     lea edx,istr5
     call writestring
     call crlf
     lea edx,istr6
     call writestring
     call crlf
     call readchar
     call clrscr
     jmp start
endgame:
     call clrscr
     exit
startScreen endp

;----------------------------------------
endscreen proc
mov  eax,black+(white*16)
call SetTextColor
call clrscr
again:
lea edx,endstr1
call writestring
call crlf
lea edx,endstr2
call writestring
call crlf
lea edx,endstr3
call writestring
call crlf
lea edx,endstr4
call writestring
call crlf
call readchar
cmp al,'1'
jz restart
cmp al,'2'
jz  quitgame
call clrscr
jmp again
quitgame:exit
restart:ret
endscreen endp
;----------------------------------------
inttostr proc
    lea esi,[filebuffer]
    mov eax,highscore
    mov ecx,0
storedigits:
    cmp eax,0
    jz createstring
    mov edx,0
    mov ebx,10
    div ebx
    add dl,'0'
    push edx
    inc ecx
    jmp storedigits
createstring:
    cmp ecx,0
    jz  return
    pop edx
    mov [esi],dl
    inc esi
    dec ecx
    jmp createstring
return:
    mov byte ptr [esi],0
    ret
inttostr endp
;----------------------------------------
setHighScore proc
mov eax,score
cmp eax,highScore
jge newHighScore
ret
newHighScore: 
mov highScore,eax
call inttostr
lea edx,filename
call createoutputfile
mov filehandle,eax
lea edx,fileBuffer
call strlength
mov ecx,eax
mov eax,filehandle
call writetofile
mov eax,filehandle
call closefile
ret
setHighScore endp
;----------------------------------------
getfromfile proc
mov edx,offset filename
call openinputfile
mov filehandle,eax
lea edx,fileBuffer
mov ecx,100
call readFromFile 
call closefile
lea edx,fileBuffer
call strlength
mov ecx,eax
call parsedecimal32
mov highscore,eax
ret
getfromfile endp
;----------------------------------------
main proc
call getfromfile
start:
      call clrscr
      call startScreen
      call setHighScore
      mov continueGame,1
      call game
      call clrscr
      call gameoverscreen
      call clrscr
      call EndScreen
jmp start
exit
main endp
;----------------------------------------
end main