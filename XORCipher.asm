.data


.data? ;uninitialized data

.code

xorcipher PROC
; input string -> eax
; key -> edx

 xor eax, edx

 ret
xorcipher ENDP