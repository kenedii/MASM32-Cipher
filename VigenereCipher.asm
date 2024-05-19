.data
startingl DW 97       ; Where lowercase 'a' starts on ASCII table

startingu DW 65       ; Where uppercase 'A' starts on ASCII table

shiftbuf  DW 26       ; How much to add to letters < 97+n

.data?
phrase DB 256 dup(?)
key DB 256 dup(?)

.code

vigenereEncode PROC
; Move phrase to encode -> eax
; Move the key -> edx
 lea esi, edx
 lea esi, ecx
 call toLower  ; convert key to lowercase and move to ecx
 mov [key], ecx
 
 mov esi, eax
 mov edi, encodedPhrase



EncodeLoop:
    cmp al, 0                     ; Check for null terminator
    je done                       ; If null terminator, jump to done

    cmp al, 'a'                   ; Check if lowercase letter
    jl check_uppercase            ; If less than 'a', check uppercase
    cmp al, 'z'                   ; Check if greater than 'z'
    jg non_letter                 ; If greater than 'z', it's not a letter
    call shift_lower              ; Call shift_lower procedure

non_letter:
    mov [edi], al                 ; Copy non-letter character as it is
    inc edi                       ; Move to next position in destination buffer
    jmp EncodeLoop

check_uppercase:
    cmp al, 'A'                   ; Check if uppercase letter
    jl non_letter                 ; If less than 'A', it's not a letter
    cmp al, 'Z'                   ; Check if greater than 'Z'
    jg non_letter                 ; If greater than 'Z', it's not a letter
    call shift_upper              ; Call shift_upper procedure
    mov al, [lbuffer]             ; Load encoded character from lbuffer
    mov [edi], al                 ; Store encoded character
    inc edi                       ; Move to next position in destination buffer
    jmp encodeLoop            ; Jump to process next character

done:
 ret

vigenereEncode ENDP

shift_lower PROC 
    ; Operate on the letter stored in lbuffer
    movzx eax, byte ptr [lbuffer] ; Load letter from lbuffer into EAX
    movzx ecx, aposl              ; Load new position of 'a' into ECX
    cmp eax, ecx                  ; Compare letter with 97 + shift
    jl addition_lower             ; If letter < 97 + shift, jump to addition
    jmp subtraction_lower         ; Otherwise, jump to subtraction

addition_lower:
    movzx ecx, abuf               ; Load abuf into ECX
    add eax, ecx                  ; Add abuf to letter (using CX part of ECX)
    jmp go_back_lower

subtraction_lower:
    mov ecx, [shiftValue]         ; Load the caesar shift value into ecx
    sub eax, ecx                  ; Subtract shift from letter
    jmp go_back_lower

go_back_lower:
    mov [lbuffer], al             ; Store the result back in lbuffer
    ret                           ; Clean up the stack and return
shift_lower ENDP

shift_upper PROC 
    ; Operate on the letter stored in lbuffer
    movzx eax, byte ptr [lbuffer] ; Load letter from lbuffer into EAX
    movzx ecx, aposu              ; Load new position of 'A' into ECX
    cmp eax, ecx                  ; Compare letter with 65 + shift
    jl addition_upper             ; If letter < 65 + shift, jump to addition
    jmp subtraction_upper         ; Otherwise, jump to subtraction

addition_upper:
    movzx ecx, abuf               ; Load abuf into ECX
    add eax, ecx                  ; Add abuf to letter (using CX part of ECX)
    jmp go_back_upper

subtraction_upper:
    mov ecx, [shiftValue]         ; Load the caesar shift value into ecx
    sub eax, ecx                  ; Subtract shift from letter
    jmp go_back_upper

go_back_upper:
    mov [lbuffer], al             ; Store the result back in lbuffer
    ret                           ; Clean up the stack and return
shift_upper ENDP

determineSHIFT PROC
; place char -> eax
; returns shift -> eax

 sub eax, 97  ; Subtract char-a to determine how many values to shift by
 ret
determineSHIFT ENDP

toLower PROC               ; Convert an input string buffer to lowercase
    mov ecx, bufferSize    ; Set the maximum loop count
    movzx eax, byte ptr [esi]  ; Load the first character of the input string
    test al, al            ; Check if it's the null terminator
    jz endLoop             ; If it's the end of the string, exit the loop

loopStart:
    cmp al, 'A'            ; Compare the character with 'A'
    jl notUpperCase        ; If less than 'A', it's not uppercase
    cmp al, 'Z'            ; Compare the character with 'Z'
    jg notUpperCase        ; If greater than 'Z', it's not uppercase

    ; Convert uppercase to lowercase by adding 32 to the ASCII value
    add al, 32

notUpperCase:
    mov [edi], al          ; Store the character in the output string
    inc esi                ; Move to the next character in the input string
    inc edi                ; Move to the next character in the output string
    movzx eax, byte ptr [esi]  ; Load the next character of the input string
    test al, al            ; Check if it's the null terminator
    jz endLoop             ; If it's the end of the string, exit the loop
    loop loopStart

endLoop:
    ret
toLower ENDP
