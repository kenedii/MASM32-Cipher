.data
startingl DW 97       ; Where lowercase 'a' starts on ASCII table
startingu DW 65       ; Where uppercase 'A' starts on ASCII table
abuf  DW 26           ; Alphabet length

lbuffer DB 1 dup(?)   ; Buffer to store letter in for shifting

.data?
phrase DB 256 dup(?)
key DB 256 dup(?)
encodedPhrase DB 256 dup(?)
shiftValue DB ?
aposu     DW ?        ; New position for uppercase 'A'
aposl     DW ?        ; New position for lowercase 'a'

.code

vigenereEncode PROC
    ; Input: EAX -> phrase, EDX -> key

    mov esi, eax                  ; Load phrase into ESI
    mov edi, OFFSET encodedPhrase ; Set destination for encoded phrase
    xor ecx, ecx                  ; Clear ECX (key index)

EncodeLoop:
    mov al, [esi]                 ; Load character from phrase
    cmp al, 0                     ; Check for null terminator
    je done                       ; If null terminator, jump to done

    ; Check if al is a lowercase or uppercase letter
    cmp al, 'a'
    jl check_uppercase
    cmp al, 'z'
    jg non_letter

lowercase_letter_handling:
    ; Lowercase letter handling
    mov [lbuffer], al             ; Store the letter in lbuffer
    call getShiftValue            ; Calculate shift based on key
    call shift_lower              ; Shift the character
    jmp store_and_next

check_uppercase:
    cmp al, 'A'
    jl non_letter
    cmp al, 'Z'
    jg non_letter

uppercase_letter_handling:
    ; Uppercase letter handling
    mov [lbuffer], al             ; Store the letter in lbuffer
    call getShiftValue            ; Calculate shift based on key
    call shift_upper              ; Shift the character
    jmp store_and_next

non_letter:
    ; Non-letter character handling
    mov [edi], al                 ; Copy non-letter character as it is
    inc edi                       ; Move to the next position in the destination buffer
    jmp next_character

store_and_next:
    ; Store the shifted character
    mov al, [lbuffer]             ; Retrieve the shifted character from lbuffer
    mov [edi], al
    inc edi                       ; Move to the next position in the destination buffer
    jmp next_character

next_character:
    ; Move to the next character in the input phrase
    inc esi
    ; Move to the next character in the key
    inc ecx
    ; Load the next character from the key
    movzx ebx, byte ptr [key + ecx]
    ; Check if end of key
    test ebx, ebx
    jnz continue_encoding         ; If not end, continue
    xor ecx, ecx                  ; Reset key index if end of key

continue_encoding:
    jmp EncodeLoop

done:
    mov byte ptr [edi], 0         ; Null-terminate the encoded string
    ret
vigenereEncode ENDP

getShiftValue PROC
    ; Input: ECX -> key index, EDX -> key
    ; Output: shiftValue -> shift value
    movzx eax, byte ptr [edx + ecx] ; Load key character
    sub eax, 'a'                    ; Calculate shift value (key - 'a')
    mov shiftValue, al              ; Store shift value

    mov cx, 26                      ; Load 26 into CX
    sub cx, ax                      ; Subtract shiftValue from 26

    mov abuf, cx                    ; Store the result in abuf
    
    ; Determine the new position of the letter 'a' -> aposl
    movzx eax, shiftValue           ; Load shift value into EAX
    add eax, 97              ; Calculate new position: eax = 97 + shift
    mov aposl, ax                   ; Store the result in aposl

    ; Determine the new position of the letter 'A' -> aposu
    movzx eax, shiftValue           ; Load shift value into EAX
    add eax, 65              ; Calculate new position: eax = 65 + shift
    mov aposu, ax                   ; Store the result in aposu

    ret
getShiftValue ENDP

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
    movzx ecx, shiftValue         ; Load the caesar shift value into ecx
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
    movzx ecx, shiftValue         ; Load the caesar shift value into ecx
    sub eax, ecx                  ; Subtract shift from letter
    jmp go_back_upper

go_back_upper:
    mov [lbuffer], al             ; Store the result back in lbuffer
    ret                           ; Clean up the stack and return
shift_upper ENDP

toLower PROC
    ; Convert key to lowercase
        toLowerLoop:
        mov al, [esi]
        test al, al
        jz toLowerDone

        cmp al, 'A'
        jl not_uppercase
        cmp al, 'Z'
        jg not_uppercase

        add al, 32

    not_uppercase:
        mov [edi], al
        inc esi
        inc edi
        jmp toLowerLoop

    toLowerDone:
        ret
toLower ENDP

StrCopy PROC
    ; Copy string from [esi] to [edi]
    StrCopyLoop:
        mov al, [esi]
        mov [edi], al
        test al, al
        jz StrCopyDone
        inc esi
        inc edi
        jmp StrCopyLoop
    StrCopyDone:
        ret
StrCopy ENDP