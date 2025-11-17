INCLUDE Irvine32.inc
.data
window byte 10000 dup(?)
windowwidth equ 200
windowheight equ 50
.code
;--------------------------------------
makeBackground proc
lea esi,window
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
lea esi,window
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
main proc
call makeBackground
call displayBackground
exit
main endp
;----------------------------------------
end main