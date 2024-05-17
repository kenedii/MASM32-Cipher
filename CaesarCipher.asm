.data
starting DW 97       ; Where lowercase a starts at on ascii table

apos   DW ?          ; New position for lowercase a
abuf   DW 26         ; How much to add to letters < 97+n

.code

shift_lowercase PROC
    ; Parameters are on the stack: shift is at [esp+4], letter is at [esp+8]
    ; Determine the new position of the letter A
    movzx eax, word ptr [esp+4] ; Load shift into EAX
    movzx ecx, starting         ; Load default A position into ECX
    add eax, ecx                ; eax = 97 + shift
    mov apos, ax                ; Store the result in apos

    ; Compute abuf = 26 - shift
    movzx eax, word ptr [esp+4] ; Load shift into EAX again
    movzx ecx, abuf             ; Load abuf into ECX
    sub ecx, eax                ; ecx = 26 - shift
    mov abuf, cx                ; Store the result in abuf

    ; Get the new position for letter
    movzx eax, byte ptr [esp+8] ; Load letter into EAX
    movzx ecx, apos
    cmp eax, ecx                ; Compare letter with 97 + shift
    jl addition                 ; If letter < 97 + shift, jump to addition
    jmp subtraction             ; Otherwise, jump to subtraction

addition:
    movzx ecx, abuf
    add eax, ecx                ; Add abuf to letter (using CL part of ECX)
    jmp go_back

subtraction:
    sub al, byte ptr [esp+4]    ; Subtract shift from letter
    jmp go_back

go_back:
    movzx eax, al               ; Zero extend AL into EAX to get the result
    ret 8                       ; Clean up the stack and return
shift_lowercase ENDP


