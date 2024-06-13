include \masm32\include\masm32rt.inc
include CaesarCipher.asm

.data
shift1 DW 13          ; Amount to shift alphabet by. Letters >= 97+n you subtract this number from
letter1 DB "e",0     
phrase DB "tnlfrk",0
phraseE db 256 dup(?)

.code

start:

    mov eax, offset phrase
    movzx ecx, shift1              ; Push the number to shift alphabet by
    call caesarDecode              ; Call the caesar_cipher procedure
    invoke StdOut, offset encodedPhrase
    invoke ExitProcess, 0

end start