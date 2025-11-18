INCLUDE Irvine32.inc
.data
windowwidth equ 100
windowheight equ 100
platformSpeed equ 10
platformWidth equ 4
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
addplatform proc ;parameter dl(x coordinate)
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
main proc
call displayBackground
outerloop:
    mov dl,windowwidth-platformWidth
    call addplatform
    mov dl,windowwidth-platformWidth-1
    loop1:
          call moveplatform
          cmp dl,0
          jge loop1
    call removeplatform
    jmp outerLoop
exit
main endp
;----------------------------------------
end main