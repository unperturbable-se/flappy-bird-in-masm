INCLUDE Irvine32.inc
.data
windowwidth equ 50
windowheight equ 50
platformSpeed equ 10
platformWidth equ 4
holeheight    equ windowheight/10
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
movePlatform proc uses eax ;takes dl as input, 
;adds speed number of columns, removes speed number of columns(future addition)
mov  eax,green+(black*16)
call SetTextColor
    mov dh,0
    addcolumn:
         call gotoxy
         mov al, 219
         call writechar
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
addplatform proc uses edx;parameter dl(x coordinate)
mov  eax,green+(black*16)
call SetTextColor
push ecx
mov cl,0 
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
addHole proc uses edx ecx ;parameter: dl(x coordinate),bl(y coordinate)
;range-> x(dl to dl+pwidth) y(bl to bl+hheight)
mov dh,bl
mov  eax,yellow+(black*16)
call SetTextColor
mov ecx,platformWidth
    outerloop:
    cmp dl,0
    jle endloop
    push ecx
    mov dh,bl
    mov  ecx,holeheight
         innerloop:
         call gotoxy
         mov al,219
         call writechar
         inc dh
         loop innerLoop
    pop ecx
    inc dl
    cmp dl,windowwidth-1
    jg endloop
    jmp outerloop

endloop:
mov  eax,green+(black*16)
call SetTextColor
ret
addHole endp
;--------------------------------------
randomizehole proc uses eax ;returns bl(windowheight*.25 to windowheight*.75)
mov eax,windowheight
mov ebx,windowheight
shr eax,1 ;0.5
shr ebx,2; 0.25
call randomrange
add eax,ebx ;rand(0 to 0.5)+0.25
mov bl,al
ret
randomizehole endp
;--------------------------------------
main proc
call displayBackground
outerloop:
    call randomizehole
    mov dl,windowwidth-platformWidth-1
    call addplatform
    call addHole
    mov dl,windowwidth-platformWidth-1
    loop1:
          call moveplatform
          call addHole
          cmp dl,0
          jge loop1
    call removeplatform
    jmp outerLoop
exit
main endp
;----------------------------------------
end main