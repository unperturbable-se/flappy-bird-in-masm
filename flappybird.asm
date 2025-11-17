INCLUDE Irvine32.inc
.data
A1 byte 1
B1 byte 0
C1 byte 3
D1 byte 3
.code
main proc
mov eax,0
mov al,A1
mul B1
sub al,C1
add al,D1
call writeint
exit
main endp
end main