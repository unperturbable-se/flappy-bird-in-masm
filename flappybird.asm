INCLUDE Irvine32.inc
.data
windowwidth equ 125
windowheight equ 100
platformdelay equ 0
platformWidth equ 5
holeheight    equ 20
birdposx      equ windowwidth/2
birdposy      equ windowheight/2

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
lea esi,airplane
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
    cmp dh,birdposy+8
    jne outerloop

ret
addbird endp
;--------------------------------------
main proc
call displayBackground
outerloop:
    call randomizehole
    mov dl,windowwidth-platformWidth-1
    call addplatform
    ;call addHole
    mov dl,windowwidth-platformWidth-1
    loop1:
          call moveplatform
          call addbird
          mov eax,platformdelay
          call delay
          cmp dl,0
          jge loop1
    call removeplatform
    jmp outerLoop
exit
main endp
;----------------------------------------
end main