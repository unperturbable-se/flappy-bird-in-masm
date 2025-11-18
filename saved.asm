birdSprite BYTE \
    0,1,0,0,0,0,1,0, \
    0,1,1,0,0,1,1,0, \
    0,1,0,0,0,0,1,0, \
    0,0,1,1,1,1,0,0, \
    0,0,1,1,1,1,0,0, \
    0,1,0,0,0,0,1,0, \
    0,1,1,0,0,1,1,0, \
    0,1,0,0,0,0,1,0
;--------------------------------------
addbird proc uses edx ecx
mov  eax,blue+(black*16)
call SetTextColor
lea esi,birdSprite
mov ecx,0 ;index
mov dh,birdposy
outerloop:
     mov dl,birdposx
     innerloop:
          cmp byte ptr [esi+ecx],1
          jne endloop
          gotoxy
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