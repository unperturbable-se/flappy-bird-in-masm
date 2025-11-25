INCLUDE Irvine32.inc
.data
windowwidth equ 80
windowheight equ 50
platformdelay equ 10
platformWidth equ 2
holeheight    equ 15
birdposx      equ windowwidth/2
birdposy      byte windowheight/2
maxbirdposy   byte windowheight/2+8
time          dword 0
score         dword 0
jumpheight    equ 7
continueGame  byte 1


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

.code
;--------------------------------------
    displayBackground proc ;runs only once
    call clrscr 
    mov  eax,yellow+(black*16)
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
mov  eax,green+(black*16)
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

mov  eax,yellow+(black*16)
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
mov  eax,green+(black*16)
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
mov  eax,yellow+(black*16)
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
mov  eax,blue+(black*16)
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
mov  eax,yellow+(black*16)
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
jmp return
up:
     call removebird
     sub birdposy,jumpheight
     sub maxbirdposy,jumpheight

return: ret
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
mov eax,score
call writestring
call writedec
ret
showScore endp
;--------------------------------------
game proc
lea esi,airplane ;set character
call displayBackground
call addbird
outerloop:
    call randomizehole
    call showScore
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
mov  eax,white+(black*16)
call SetTextColor
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
ret
gameoverscreen endp
;----------------------------------------
main proc
mov continueGame,1
call game
call clrscr
call gameoverscreen
call readchar

exit
main endp
;----------------------------------------
end main