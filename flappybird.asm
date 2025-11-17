INCLUDE Irvine32.inc
.data
window byte 10000 dup(?)
windowwidth equ 200
windowheight equ 50
.code
;--------------------------------------
makeBackground proc
mov eax,0 ;index
mov ecx,windowheight ;for(int i=0;i<100;i++)
OuterLoop:
     push ecx
     mov ecx,windowwidth ;for(int j=0;j<100;j++)
     innerLoop:
          mov byte ptr[esi+eax],'x'
          inc eax
          loop innerLoop
     pop ecx
     loop OuterLoop
ret
makeBackground endp
;--------------------------------------
displayBackground proc
mov eax,0 ;index
mov ecx,windowheight ;for(int i=0;i<100;i++)
OuterLoop:
     push ecx
     mov ecx,windowwidth ;for(int j=0;j<100;j++)
     innerLoop:
          push eax
          mov al,[esi+eax]
          call writechar
          pop eax
          inc eax
          loop innerLoop
     pop ecx
     call crlf
     loop OuterLoop
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
movePlatform endp
;--------------------------------------
addplatform proc ;parameter ebx(x coordinate)
mov eax,0 ;index
mov ecx,windowheight ;for(int i=0;i<100;i++)
OuterLoop:
     push ecx
     mov ecx,windowwidth ;for(int j=0;j<100;j++)
     innerLoop:
          cmp ecx,ebx ;if x is between [ebx,ebx+5]
          jnae donothing
          mov edx,ebx
          add edx,5
          cmp ecx,edx; 
          jnbe donothing
          mov byte ptr [esi+eax],' '
          donothing:
              inc eax
              loop innerLoop
     pop ecx
     loop OuterLoop
ret
addplatform endp
;--------------------------------------
main proc
lea esi,window
call makeBackground
;mov ax,cx
;call movePlatform
mov ebx,30
call addplatform
call displayBackground
;call clrscr
exit
main endp
;----------------------------------------
end main