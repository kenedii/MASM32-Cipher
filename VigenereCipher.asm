.data
startingl DW 97       ; Where lowercase 'a' starts on ASCII table
startingu DW 65       ; Where uppercase 'A' starts on ASCII table
shiftbuf  DW 26       ; Alphabet length

.data?
phrase DB 256 dup(?)
key DB 256 dup(?)
encodedPhrase DB 256 dup(?)

.code

vigenereEncode PROC
    ; Input: ESI -> phrase, EDI -> encodedPhrase, EDX -> key
    mov esi, OFFSET phrase
    mov edi, OFFSET encodedPhrase
    mov edx, OFFSET key
    call toLower  ; Convert key to lowercase

    xor ebx, ebx  ; EBX will be the index for the key

EncodeLoop:
    mov al, [esi]           ; Load character from phrase
    cmp al, 0               ; Check for null terminator
    je done                 ; If null terminator, jump to done

    ; Check if al is a letter
    cmp al, 'a'             
    jl check_uppercase      
    cmp al, 'z'             
    jg non_letter           

    ; Lowercase letter handling
    call getShiftValue      ; Calculate shift based on key
    call shift_lower        ; Shift the character
    jmp store_and_next

check_uppercase:
    cmp al, 'A'             
    jl non_letter           
    cmp al, 'Z'             
    jg non_letter           

    ; Uppercase letter handling
    call getShiftValue      ; Calculate shift based on key
    call shift_upper        ; Shift the character

store_and_next:
    mov [edi], al           ; Store the shifted character
    inc edi                 ; Move to the next position in the destination buffer
    inc esi                 ; Move to the next character in the input phrase
    inc ebx                 ; Move to the next character in the key
    movzx ecx, byte ptr [key + ebx]  ; Load key character
    test ecx, ecx           ; Check if end of key
    jnz EncodeLoop          ; If not end, continue
    xor ebx, ebx            ; Reset key index if end of key

    jmp EncodeLoop

non_letter:
    mov [edi], al           ; Copy non-letter character as it is
    inc edi                 ; Move to the next position in the destination buffer
    inc esi                 ; Move to the next character in the input phrase
    jmp EncodeLoop

done:
    ret
vigenereEncode ENDP

getShiftValue PROC
    ; Input: AL -> current character from phrase, EBX -> key index
    ; Output: ECX -> shift value
    movzx ecx, byte ptr [key + ebx]  ; Load key character
    sub ecx, 'a'                     ; Calculate shift value (key - 'a')
    ret
getShiftValue ENDP

shift_lower PROC
    ; Input: AL -> current character from phrase, ECX -> shift value
    sub al, 'a'  ; Normalize character to 0-25
    add al, cl   ; Apply the shift
    movzx ecx, shiftbuf
    xor edx, edx
    div ecx      ; Ensure the shift is within 0-25 range (mod 26)
    add al, 'a'  ; Convert back to ASCII
    ret
shift_lower ENDP

shift_upper PROC
    ; Input: AL -> current character from phrase, ECX -> shift value
    sub al, 'A'  ; Normalize character to 0-25
    add al, cl   ; Apply the shift
    movzx ecx, shiftbuf
    xor edx, edx
    div ecx      ; Ensure the shift is within 0-25 range (mod 26)
    add al, 'A'  ; Convert back to ASCII
    ret
shift_upper ENDP

toLower PROC
    ; Convert key to lowercase
    mov esi, OFFSET key
    mov edi, esi

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
