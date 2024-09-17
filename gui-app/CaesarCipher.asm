.data
c_startingl DW 97       ; Where lowercase 'a' starts on ASCII table

c_startingu DW 65       ; Where uppercase 'A' starts on ASCII table

c_abuf      DW 26       ; How much to add to letters < 97+n


c_lbuffer DB 1 dup(?)   ; Buffer to store letter in for shifting

.data?                ; Uninitialized data
c_aposu     DW ?        ; New position for uppercase 'A'
c_aposl     DW ?        ; New position for lowercase 'a'
c_shiftValue DD ?       ; Memory buffer to store the shift value


PUBLIC encodedPhrase
encodedPhrase DB 256 dup(?) ; Memory buffer to store encoded phrase

.code

caesarEncode PROC 
    ; The encoded phrase will be stored in the encodedPhrase public memory buffer.
    ; Move offset phrase -> eax
    ; Move the shift value (< 26) -> edx
    ; The result is stored in encodedPhrase public

    ;Initialize data buffers in case they have been reset
    mov encodedPhrase, 0
    mov c_startingl, 97
    mov c_startingu, 65
    mov c_abuf, 26
    
    mov esi, eax                  ; Store the phrase address in esi
    mov [c_shiftValue], edx         ; Store shift value in shiftValue buffer

    ; The values computed below are local variables that depend on the value of 'shift' ;
    ; Compute abuf = 26 - shift  (How much to add to letters < 'a'+n)
    mov ecx, [c_shiftValue]         ; Load shift value into ECX
    movzx edx, c_abuf               ; Load abuf into EDX
    sub edx, ecx                  ; Compute 26 - shift
    mov c_abuf, dx                  ; Store the result in abuf

    ; Determine the new position of the letter 'a' -> aposl
    mov eax, [c_shiftValue]         ; Load shift value into EAX
    movzx ecx, c_startingl          ; Load default 'a' position into ECX
    add eax, ecx                  ; Calculate new position: eax = 97 + shift
    mov c_aposl, ax                 ; Store the result in aposl

    ; Determine the new position of the letter 'A' -> aposu
    mov eax, [c_shiftValue]         ; Load shift value into EAX
    movzx ecx, c_startingu          ; Load default 'A' position into ECX
    add eax, ecx                  ; Calculate new position: eax = 65 + shift
    mov c_aposu, ax                 ; Store the result in aposu

    ; Iterate through characters
    mov edi, offset encodedPhrase ; Start index for destination buffer

encode_loop:
    mov al, [esi]                 ; Load character from source buffer
    mov [c_lbuffer], al             ; Store character in lbuffer
    cmp al, 0                     ; Check for null terminator
    je done                       ; If null terminator, jump to done

    cmp al, 'a'                   ; Check if lowercase letter
    jl check_uppercase            ; If less than 'a', check uppercase
    cmp al, 'z'                   ; Check if greater than 'z'
    jg non_letter                 ; If greater than 'z', it's not a letter
    call shift_lower              ; Call shift_lower procedure
    mov al, [c_lbuffer]             ; Load encoded character from lbuffer
    mov [edi], al                 ; Store encoded character
    inc edi                       ; Move to next position in destination buffer
    jmp next_character            ; Jump to process next character

check_uppercase:
    cmp al, 'A'                   ; Check if uppercase letter
    jl non_letter                 ; If less than 'A', it's not a letter
    cmp al, 'Z'                   ; Check if greater than 'Z'
    jg non_letter                 ; If greater than 'Z', it's not a letter
    call shift_upper              ; Call shift_upper procedure
    mov al, [c_lbuffer]             ; Load encoded character from lbuffer
    mov [edi], al                 ; Store encoded character
    inc edi                       ; Move to next position in destination buffer
    jmp next_character            ; Jump to process next character

non_letter:
    mov [edi], al                 ; Copy non-letter character as it is
    inc edi                       ; Move to next position in destination buffer

next_character:
    inc esi                       ; Move to next character in source buffer
    jmp encode_loop               ; Loop to process next character

done:
    mov byte ptr [edi], 0         ; Append null terminator to encodedPhrase
    ret

caesarEncode ENDP

shift_lower PROC 
    ; Operate on the letter stored in lbuffer
    movzx eax, byte ptr [c_lbuffer] ; Load letter from lbuffer into EAX
    movzx ecx, c_aposl              ; Load new position of 'a' into ECX
    cmp eax, ecx                  ; Compare letter with 97 + shift
    jl addition_lower             ; If letter < 97 + shift, jump to addition
    jmp subtraction_lower         ; Otherwise, jump to subtraction

addition_lower:
    movzx ecx, c_abuf               ; Load abuf into ECX
    add eax, ecx                  ; Add abuf to letter (using CX part of ECX)
    jmp go_back_lower

subtraction_lower:
    mov ecx, [c_shiftValue]         ; Load the caesar shift value into ecx
    sub eax, ecx                  ; Subtract shift from letter
    jmp go_back_lower

go_back_lower:
    mov [c_lbuffer], al             ; Store the result back in lbuffer
    ret                           ; Clean up the stack and return
shift_lower ENDP

shift_upper PROC 
    ; Operate on the letter stored in lbuffer
    movzx eax, byte ptr [c_lbuffer] ; Load letter from lbuffer into EAX
    movzx ecx, c_aposu              ; Load new position of 'A' into ECX
    cmp eax, ecx                  ; Compare letter with 65 + shift
    jl addition_upper             ; If letter < 65 + shift, jump to addition
    jmp subtraction_upper         ; Otherwise, jump to subtraction

addition_upper:
    movzx ecx, c_abuf               ; Load abuf into ECX
    add eax, ecx                  ; Add abuf to letter (using CX part of ECX)
    jmp go_back_upper

subtraction_upper:
    mov ecx, [c_shiftValue]         ; Load the caesar shift value into ecx
    sub eax, ecx                  ; Subtract shift from letter
    jmp go_back_upper

go_back_upper:
    mov [c_lbuffer], al             ; Store the result back in lbuffer
    ret                           ; Clean up the stack and return
shift_upper ENDP

caesarDecode PROC ; Decode the encoded text if you know the original shift value.
 ; Move offset encodedPhrase -> eax
 ; Move originalShiftValue -> ecx
 ; The result is stored in encodedPhrase public

 ; Determine how much to shift to undo the original shift (26-originalShiftValue)
 mov edx, 26
 sub edx, ecx
 call caesarEncode
 
 ret
caesarDecode ENDP

