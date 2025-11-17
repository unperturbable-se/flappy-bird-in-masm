INCLUDE Irvine32.inc
.data
windowwidth equ 200
windowheight equ 100
platformSpeed equ 10
platformWidth equ 15
.code
;--------------------------------------
    displayBackground proc ;runs only once
    call clrscr 
    mov dh,0
    OuterLoop:
        mov dl,0
        innerLoop:
            call gotoxy
            mov al,'X'
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
movePlatform proc ;K-T%K-->K is width
push ax
mov bx,windowwidth
mov dx,0
div bx
pop ax
sub ax,dx
movzx ebx,ax
ret
movePlatform endp
;--------------------------------------
addplatform proc ;parameter dl(x coordinate)
push ecx
mov cl,0 
outerLoop:
    mov dh,0
    innerLoop:
         call gotoxy
         mov al, '+'
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
push ecx
mov cl,0 
outerLoop:
    mov dh,0
    innerLoop:
         call gotoxy
         mov al, 'X'
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
removeplatform endp
;--------------------------------------
main proc
call displayBackground
mov cl,windowwidth-platformWidth
loop1:
      mov dl,cl
      call addplatform
      mov dl,cl
      call removeplatform
      sub cl,platformSpeed
      cmp cl,0
      jnz loop1
exit
main endp
;----------------------------------------
end main