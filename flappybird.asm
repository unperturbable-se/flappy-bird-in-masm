; FlappyBird.asm  -- cleaned / fixed version based on your draft
INCLUDE Irvine32.inc
.data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Configuration (constants)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
windowwidth   equ 80
windowheight  equ 25        ; reduced to typical console height for stability
platformdelay equ 10
platformWidth equ 2
holeheight    equ 6         ; smaller hole to fit 25 rows cleanly
birdposx      equ 10        ; x position of bird (left area)
jumpheight    equ 4
continueGame  byte 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
time         dword 0
score        dword 0
birdposy     byte windowheight/2
maxbirdposy  byte windowheight/2+4

; character sprites (8x8 bitmaps). Use esi to point to them and 1 = draw
birdSprite BYTE\
      0,0,1,1,0,0,0,0
BYTE  0,1,1,1,1,0,0,0
BYTE  1,1,1,1,1,1,0,0
BYTE  1,1,1,1,1,1,1,0
BYTE  1,1,1,1,1,1,0,0
BYTE  1,1,0,1,1,0,0,0
BYTE  0,1,0,0,1,0,0,0
BYTE  0,0,0,0,0,0,0,0

airplane BYTE\
        0,0,0,1,1,0,0,0
BYTE    0,0,1,1,1,1,0,0
BYTE    0,1,1,1,1,1,1,0
BYTE    0,0,0,1,1,1,0,1
BYTE    0,0,1,1,1,1,0,1
BYTE    0,1,1,1,1,1,1,0
BYTE    0,0,0,1,1,1,0,0
BYTE    0,0,0,0,1,0,0,0

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.code

;--------------------------------------
; displayBackground - draws a filled background once
;--------------------------------------
displayBackground proc
    call Clrscr
    mov eax, yellow + (black * 16)
    call SetTextColor

    mov dh, 0
bg_outer:
    mov dl, 0
bg_inner:
    call Gotoxy        ; expects DL = column, DH = row
    mov al, 219
    call WriteChar
    inc dl
    cmp dl, windowwidth
    jl short bg_inner
    inc dh
    cmp dh, windowheight
    jl short bg_outer
    ret
displayBackground endp

;--------------------------------------
; addplatform - draws a vertical platform column at X=dl.
;   bl = holeTop, bh = holeBottom (inclusive range of hole).
;--------------------------------------
addplatform proc uses ecx edx
    mov eax, green + (black * 16)
    call SetTextColor

    mov ecx, 0          ; column count
addp_outer:
    mov dh, 0           ; row y
addp_inner:
    cmp dh, bl
    jnge short addp_draw
    cmp dh, bh
    jnle short addp_draw
    jmp short addp_skip
addp_draw:
    call Gotoxy
    mov al, 219
    call WriteChar
addp_skip:
    inc dh
    cmp dh, windowheight
    jl short addp_inner
    inc dl
    inc ecx
    cmp ecx, platformWidth
    jl short addp_outer
    ret
addplatform endp

;--------------------------------------
; removeplatform - overwrite platform area with background color (yellow)
; parameter: DL = x column to clear (removes platformWidth+1 columns)
;--------------------------------------
removeplatform proc uses ecx edx
    mov eax, yellow + (black * 16)
    call SetTextColor

    mov ecx, 0
rem_outer:
    mov dh, 0
rem_inner:
    call Gotoxy
    mov al, 219
    call WriteChar
    inc dh
    cmp dh, windowheight
    jl short rem_inner
    inc dl
    inc ecx
    cmp ecx, platformWidth + 1
    jl short rem_outer
    ret
removeplatform endp

;--------------------------------------
; moveplatform - shifts an existing platform column one step left visually.
;   Input: DL = x column where platform currently is; BL,BH = hole range.
;   This will draw column at DL and attempt to clear a column at DL+platformWidth+1.
;--------------------------------------
;--------------------------------------
; movePlatform
; Input:
;   DL = x position of the platform column
;   BL = hole top
;   BH = hole bottom
;--------------------------------------
movePlatform proc uses eax ebx ecx edx

    ; Draw green column at DL
    mov eax, green + (black * 16)
    call SetTextColor

    mov dh, 0            ; row = 0
mp_drawColumn:
    mov dl, dl           ; ensure DL is current X position

    ; skip drawing hole area
    cmp dh, bl
    jb  mp_doDraw
    cmp dh, bh
    ja  mp_doDraw
    jmp mp_skipDraw

mp_doDraw:
    call Gotoxy
    mov al, 219
    call WriteChar

mp_skipDraw:
    inc dh
    cmp dh, windowheight
    jl mp_drawColumn


    ;-----------------------------------
    ; erase column to the right (DL+platformWidth+1)
    ;-----------------------------------
    mov eax, yellow + (black * 16)
    call SetTextColor

    mov dl, dl           ; reload DL
    add dl, platformWidth
    inc dl               ; DL = DL + platformWidth + 1

    cmp dl, windowwidth
    jge mp_endErase

    mov dh, 0
mp_erase:
    call Gotoxy
    mov al, 219
    call WriteChar
    inc dh
    cmp dh, windowheight
    jl mp_erase

mp_endErase:
    ret

movePlatform endp

;--------------------------------------
; addbird - draw bird at (birdposx,birdposy) using sprite pointed by ESI
; 8x8 sprite, 1 = draw, 0 = skip
;--------------------------------------
addbird proc uses eax ebx ecx edx edi
    mov eax, blue + (black * 16)
    call SetTextColor

    ; ESI must point to the sprite to draw (set by caller)
    xor ecx, ecx           ; row index = 0
    mov dh, birdposy       ; starting row

ab_outer:
    mov dl, birdposx       ; starting column
    mov edi, ecx
    shl edi, 3             ; edi = row * 8
    xor ebx, ebx           ; column index = 0

ab_inner:
    ; compute final address = esi + edi + ebx
    mov eax, edi
    add eax, ebx
    add eax, esi
    mov al, byte ptr [eax] ; load sprite byte
    cmp al, 1
    jne ab_skip
    call Gotoxy
    mov al, 219
    call WriteChar
ab_skip:
    inc ebx
    inc dl
    cmp ebx, 8
    jl short ab_inner
    inc dh
    inc ecx
    cmp ecx, 8
    jl short ab_outer
    ret
addbird endp

;--------------------------------------
; removebird - overwrite bird area with background (yellow)
;--------------------------------------
removebird proc uses eax ebx ecx edx
    mov eax, yellow + (black * 16)
    call SetTextColor

    xor ecx, ecx               ; row index = 0
    mov dh, birdposy
rb_outer:
    mov dl, birdposx
    xor ebx, ebx               ; column index = 0
rb_inner:
    call Gotoxy
    mov al, 219                ; same block char used for background fill
    call WriteChar
    inc ebx
    inc dl
    cmp ebx, 8
    jl short rb_inner
    inc dh
    inc ecx
    cmp ecx, 8
    jl short rb_outer
    ret
removebird endp


;--------------------------------------
; getkey - non-blocking key read
;   - space or 'w' will make bird jump
;   - 'a' / 'd' change sprite
;--------------------------------------
;--------------------------------------
; getkey - non-blocking key read
;--------------------------------------
getkey proc uses eax ebx ecx esi
    call ReadKey
    jz gk_return

    cmp al, 'a'
    je gk_airplane
    cmp al, 'A'
    je gk_airplane
    cmp al, 'd'
    je gk_bird
    cmp al, 'D'
    je gk_bird
    cmp al, 'w'
    je gk_up
    cmp al, 'W'
    je gk_up
    cmp al, 'q'
    je gk_quit
    jmp gk_return

gk_airplane:
    lea esi, airplane
    ; draw using new sprite: remove old and draw new
    call removebird
    call addbird
    jmp gk_return

gk_bird:
    lea esi, birdSprite
    call removebird
    call addbird
    jmp gk_return

gk_up:
    call removebird

    ; load birdposy into AL (byte) and compare with jumpheight
    mov al, birdposy
    cmp al, jumpheight
    jb gk_small  ; if al < jumpheight, we will clamp to 0

    ; normal jump
    sub al, jumpheight
    jmp gk_do_set

gk_small:
    mov al, 0

gk_do_set:
    ; save new birdposy and update maxbirdposy (bird height is 4 rows here)
    mov byte ptr birdposy, al
    mov bl, al
    add bl, 4
    mov byte ptr maxbirdposy, bl

    call addbird
    jmp gk_return

gk_quit:
    mov byte ptr continueGame, 0
    jmp gk_return

gk_return:
    ret
getkey endp

;--------------------------------------
; falldown - simple gravity: fall every other tick
;--------------------------------------
falldown proc uses eax
    mov eax, time
    and eax, 1
    cmp eax, 1
    jne fd_ret
    call removebird
    inc byte ptr birdposy
    inc byte ptr maxbirdposy
    call addbird
fd_ret:
    ret
falldown endp

;--------------------------------------
; checkCollision - check bounds and simplest collision with current pipe column
;   Input expected: DL = current pipe X, BL = holeTop, BH = holeBottom
;--------------------------------------
checkCollision proc uses eax ebx
    ; check out of bounds
    movzx eax, maxbirdposy
    cmp eax, windowheight
    jae col_true

    movzx eax, birdposy
    cmp eax, 0
    jb col_true

    ; if pipe X != bird X, no collision
    cmp dl, birdposx
    jne col_false

    ; if entire bird is below hole top -> collision
    movzx eax, birdposy
    movzx ebx, bh
    cmp eax, ebx
    jge col_true

    ; if entire bird is above hole bottom -> collision
    movzx eax, maxbirdposy
    movzx ebx, bl
    cmp eax, ebx
    jle col_true

col_false:
    ret

col_true:
    mov byte ptr continueGame, 0
    ret
checkCollision endp

;--------------------------------------
; showScore - draw score at top-right
;--------------------------------------
showScore proc uses eax
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 0
    mov dl, windowwidth - 10
    call Gotoxy
    mov eax, score
    call WriteDec
    ret
showScore endp

;--------------------------------------
; simple deterministic hole generator (no RandomRange reliance)
;   returns BL = holeTop, BH = holeBottom
;   we vary the hole based on time variable
;--------------------------------------
randomizehole proc uses eax ebx ecx edx
    mov eax, time
    ; create pseudo-random-ish offset in range [2 .. windowheight-holeheight-2]
    mov ebx, windowheight
    sub ebx, holeheight
    sub ebx, 4
    ; avoid zero division
    cmp ebx, 1
    jle rh_small

    ; reduce eax
    xor edx, edx
    mov ecx, ebx
    div ecx        ; EAX = time/ecx ; use remainder? use edx as remainder
    mov eax, edx
    add eax, 2
    jmp rh_done

rh_small:
    mov eax, 2

rh_done:
    mov bl, al
    mov bh, bl
    add bh, holeheight
    ret
randomizehole endp

;--------------------------------------
; game - main gameplay loop
;--------------------------------------
game proc
    mov continueGame, 1
    lea esi, airplane   ; default sprite
    call displayBackground
    call addbird

main_outer:
    call randomizehole
    ; start platform at rightmost columns
    mov dl, windowwidth - 2
    ; draw the incoming platform columns
    push ebx
    push edx
    call addplatform
    pop edx
    pop ebx

    ; move the pipe from right to left
    mov dl, windowwidth - 2
pipe_move_loop:
    ; draw current pipe column (we draw via addplatform using DL and BL/BH)
    push ebx
    push edx
    ; BL/BH are already set by randomizehole
    call addplatform
    pop edx
    pop ebx

    ; process one frame
    call getkey
    call showScore
    call falldown

    ; check collision with current pipe DL
    push edx
    push ebx
    call checkCollision
    pop ebx
    pop edx

    cmp continueGame, 0
    je game_end

    ; delay to slow game
    mov eax, platformdelay
    call Delay
    inc time

    ; clear the column at the right edge of the platform move
    mov eax, yellow + (black * 16)
    call SetTextColor
    ; use removeplatform to clear the column at DL + platformWidth + 1
    mov al, dl
    ; decrement DL to simulate left movement
    dec dl
    cmp dl, 0
    jge short pipe_move_loop

    ; finished moving this pipe off-screen: remove and increase score
    call removeplatform
    inc score
    jmp main_outer

game_end:
    ret
game endp

;--------------------------------------
; gameoverscreen - draw game over text (centered-ish)
;--------------------------------------
gameoverscreen proc
    lea esi, Gameovertext
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 1
gos_outer:
    mov dl, 10
gos_inner:
    call Gotoxy
    mov al, [esi]
    call WriteChar
    inc esi
    inc dl
    cmp dl, 40
    jl short gos_inner
    inc dh
    cmp dh, 10
    jl short gos_outer
    ret
gameoverscreen endp

;--------------------------------------
; main - program entry
;--------------------------------------
main proc
    call Clrscr
    mov continueGame, 1
    call game

    ; game ended
    call Clrscr
    call gameoverscreen

    ; wait for user input before exit
    call ReadKey
    exit
main endp

end main
