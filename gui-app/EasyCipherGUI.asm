.386

option casemap:none
include \masm32\include\masm32rt.inc
include CaesarCipher.asm
include VigenereCipher.asm

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.data
MainClass db "Main Builder",0
AppName db "EasyCipher Encode/Decode",0
ComboClass db "combobox",0
ListboxCLass db "listbox",0
EditClass db "edit",0
szText01 db "Combobox01",0
szText011 db "Combobox01",0

szText02 db "Encode",0
szText03 db "Decode",0
szText04 db "Caesar Cipher",0
szText05 db "Vigenere Cipher",0
szText06 db "XOR Cipher",0
szText07 db "Circular R. Shift",0
 
selectCipherText     DB "Select a cipher: ",0
encodeOrDecodeText   DB "Encode/Decode: ",0
encodeTextBoxText    DB "Text to Encode/Decode: ",0
keyBoxText           DB "Key: ",0
shiftValueText       DB "Shift value: ",0
encryptedTextBoxText DB "Encoded/Decoded text: ",0

szStatic      DB          "STATIC", 0
ButtonClass   db          "BUTTON", 0
ClassName     DB          "SimpleWinClass", 0
ErrorMsg      DB          'Initial load failed.',0

wc            WNDCLASSEX  <>
EditClassName db "edit",0


.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hCombobox01 dd ?
hCombobox011 dd ?
hListbox01 dd ?
hEdit01 dd ?
hEdit02 dd ?
hEdit03 dd ?
hTextSubwindow dd ?
buttonSubwindow dd ?
encodedTextSubwindow dd ?
tempBuffer db 256 dup(?)
encodedText db 256 dup(?)

key db 256 dup(?)
phrase db 256 dup(?)


.const
ComboboxID equ 2001
encodeButton equ 400 

; Constants for the text subwindow
cdVCarText  EQU  WS_CHILD + WS_VISIBLE + SS_CENTER
cdTXSize    EQU  300 ; Constant double X-size of the subwindow for the text
cdTYSize    EQU  40           ; Constant double Y-size of the subwindow for the text
cdSubType   EQU  NULL         ; Subwindow type (flat-NULL, 3D-1, etc.)

; Constants for 'Select a cipher' text position
cdTXPos     EQU  2           ; Constant double X-Position subwindow for the text (top left corner)
cdTYPos     EQU  30           ; Constant double Y-Position subwindow for the text (top left corner)

.code
start:
invoke GetModuleHandle, NULL
mov hInstance,eax
invoke GetCommandLine
mov CommandLine,eax
invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
LOCAL msg:MSG
LOCAL hwnd:HWND
mov wc.cbSize,SIZEOF WNDCLASSEX
mov wc.style, CS_HREDRAW or CS_VREDRAW
mov wc.lpfnWndProc, OFFSET WndProc
mov wc.cbClsExtra,NULL
mov wc.cbWndExtra,NULL
push hInstance
pop wc.hInstance
mov wc.hbrBackground,COLOR_BTNFACE+1
mov wc.lpszMenuName,NULL
mov wc.lpszClassName,OFFSET MainClass
invoke LoadIcon,NULL,IDI_APPLICATION
mov wc.hIcon,eax
mov wc.hIconSm,eax
invoke LoadCursor,NULL,IDC_ARROW
mov wc.hCursor,eax
invoke RegisterClassEx, addr wc

;---------------------------
invoke GetSystemMetrics,SM_CXSCREEN
sub eax, 624
shr eax, 1
push eax
invoke GetSystemMetrics,SM_CYSCREEN
sub eax, 415
shr eax,1
pop ebx
;------------------------------------------

INVOKE CreateWindowEx,NULL,ADDR MainClass,ADDR AppName,\
DS_MODALFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_POPUP or WS_CAPTION or WS_SYSMENU,ebx,\
eax,624, 415,NULL,NULL,\
hInst,NULL
mov hwnd,eax
invoke ShowWindow, hwnd,SW_SHOWNORMAL
invoke UpdateWindow, hwnd
.WHILE TRUE
invoke GetMessage, ADDR msg,NULL,0,0
.BREAK .IF (!eax)
invoke TranslateMessage, ADDR msg
invoke DispatchMessage, ADDR msg
.ENDW
mov eax,msg.wParam
ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
.IF uMsg==WM_CREATE

    ; Create the text subwindow for the 'Select a Cipher' text
    INVOKE    CreateWindowEx, cdSubType, ADDR szStatic, ADDR selectCipherText, cdVCarText,\ 
                  -75, 32, cdTXSize, cdTYSize, hWnd,\
                  500, wc.hInstance, NULL
                  
    ; Create the Drop-Down box for Cipher selection
    invoke CreateWindowEx,NULL,addr ComboClass,addr szText011,WS_VISIBLE or WS_CHILD or WS_VSCROLL or CBS_DROPDOWNLIST,150,30,150,150,hWnd,ComboboxID,hInstance,NULL
    mov hCombobox011,eax
    invoke SendMessage,hCombobox011,CB_ADDSTRING,0,ADDR szText04
    invoke SendMessage,hCombobox011,CB_ADDSTRING,0,ADDR szText05
    invoke SendMessage,hCombobox011,CB_ADDSTRING,0,ADDR szText06
    invoke SendMessage,hCombobox011,CB_ADDSTRING,0,ADDR szText07

    ; Create the text subwindow for the 'Encode/Decode' text
    INVOKE    CreateWindowEx, cdSubType, ADDR szStatic, ADDR encodeOrDecodeText, cdVCarText,\ 
                  -75, 72, cdTXSize, cdTYSize, hWnd,\
                  500, wc.hInstance, NULL

    ; Create the Drop-Down box for Encode/Decode selection
    invoke CreateWindowEx,NULL,addr ComboClass,addr szText01,WS_VISIBLE or WS_CHILD or WS_VSCROLL or CBS_DROPDOWNLIST,150,70,150,150,hWnd,ComboboxID,hInstance,NULL
    mov hCombobox01,eax
    ;invoke SendMessage,hCombobox01,CB_SETITEMDATA,0,ADDR szText02
    invoke SendMessage,hCombobox01,CB_ADDSTRING,0,ADDR szText02
    invoke SendMessage,hCombobox01,CB_ADDSTRING,0,ADDR szText03

    ; Create the text subwindow for the 'Text to Encode/Decode' text
    INVOKE    CreateWindowEx, cdSubType, ADDR szStatic, ADDR encodeTextBoxText, cdVCarText,\ 
                  153, 105, cdTXSize, 25, hWnd,\
                  500, wc.hInstance, NULL

    ; Create the text box for the text to Encode/Decode
    invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                       WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                       ES_AUTOHSCROLL,\
                       100,132,400,25,hWnd,8,hInstance,NULL
    mov hEdit01, eax

    ; Create the text box for the key/shift value
    invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                       WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                       ES_AUTOHSCROLL,\
                       100,195,400,25,hWnd,8,hInstance,NULL
    mov hEdit02, eax

    ; Create the text box for the encoded/decoded text
    invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                       WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                       ES_AUTOHSCROLL,\
                       100,295,400,25,hWnd,8,hInstance,NULL
    mov hEdit03, eax



.ELSEIF uMsg == WM_COMMAND
.if wParam == encodeButton ; If the encode button is pressed
            invoke RtlZeroMemory, addr v_encodedPhrase, 256  ; Clear the buffer
            invoke GetWindowText,hEdit01,ADDR phrase,256
            invoke GetWindowText,hEdit02,ADDR key, 256
            ; Handle combobox selection change
            invoke SendMessage, hCombobox011, CB_GETCURSEL, 0, 0
            cmp eax, -1
            je @EndCommand
            invoke SendMessage, hCombobox011, CB_GETLBTEXT, eax, ADDR tempBuffer
            invoke lstrcmp, ADDR tempBuffer, ADDR szText05       ; Check for Vigenere cipher
            .if eax == 0 ; If drop-down menu is set to 'Vigenere Cipher'
                lea eax, phrase
                lea edx, key
                call vigenereEncode
                invoke SetWindowText,hEdit03,addr v_encodedPhrase
                jmp @DoneHandling
            .endif
            invoke lstrcmp, ADDR tempBuffer, ADDR szText04       ; Check for Caesar cipher
            .if eax == 0 ; If drop-down menu is set to 'Caesar Cipher'
                invoke SetWindowText,hEdit03, 0
                invoke atodw, addr key
                mov edx, eax
                lea eax, phrase
                call caesarEncode
                invoke SetWindowText,hEdit03,addr encodedPhrase
            .endif
        .endif
    .if wParam == encodeButton+1 ; If the decode button is pressed
            invoke GetWindowText,hEdit01,ADDR phrase,256
            invoke GetWindowText,hEdit02,ADDR key, 256
            ; Handle combobox selection change
            invoke SendMessage, hCombobox011, CB_GETCURSEL, 0, 0
            cmp eax, -1
            je @EndCommand
            invoke SendMessage, hCombobox011, CB_GETLBTEXT, eax, ADDR tempBuffer
            invoke lstrcmp, ADDR tempBuffer, ADDR szText05       ; Check for Vigenere cipher
            .if eax == 0 ; If drop-down menu is set to 'Vigenere Cipher'
                lea eax, phrase
                lea edx, key
                call vigenereDecode
                invoke SetWindowText,hEdit03,addr v_encodedPhrase
            .endif
            invoke lstrcmp, ADDR tempBuffer, ADDR szText04       ; Check for Caesar cipher
            .if eax == 0 ; If drop-down menu is set to 'Caesar Cipher'
                invoke atodw, addr key
                mov ecx, eax
                lea eax, phrase
                call caesarDecode
                invoke SetWindowText,hEdit03,addr encodedPhrase
            .endif
        .endif
        mov eax, wParam
        shr eax, 16     ; Shift right 16 bits to extract the high word of wParam

        cmp eax, CBN_SELCHANGE
        jne @NoSelectionChange

        ; Handle combobox selection change
        invoke SendMessage, hCombobox011, CB_GETCURSEL, 0, 0
        cmp eax, -1
        je @EndCommand

        ; Check the selected item
        invoke SendMessage, hCombobox011, CB_GETLBTEXT, eax, ADDR tempBuffer

        ; Handle combobox selection change for Encode/Decode box
        invoke SendMessage, hCombobox01, CB_GETCURSEL, 0, 0
        cmp eax, -1
        je @EndCommand
        invoke SendMessage, hCombobox01, CB_GETLBTEXT, eax, ADDR tempBuffer

        ; If a button exists, destroy it before creating a new one
        .IF buttonSubwindow
            invoke DestroyWindow, buttonSubwindow
            mov buttonSubwindow, 0
        .ENDIF

        invoke lstrcmp, ADDR tempBuffer, ADDR szText02   ; Check for Encode
        .IF eax == 0
            invoke    CreateWindowEx,WS_EX_LEFT,       ; Create 'encode' button
                          ADDR ButtonClass,
                          ADDR szText02,               ; Button text: Encode
                          WS_CHILD or WS_VISIBLE,      ; or BS_ICON,
                          270,225,60,60,
                          hWnd,400,
                          wc.hInstance,NULL
            mov buttonSubwindow, eax
        .ENDIF

        invoke lstrcmp, ADDR tempBuffer, ADDR szText03   ; Check for Decode
        .IF eax == 0
            invoke    CreateWindowEx,WS_EX_LEFT,      ; create 'decode' button
                          ADDR ButtonClass,
                          ADDR szText03,               ; Button text: Decode
                          WS_CHILD or WS_VISIBLE,      ; or BS_ICON,
                          270,225,60,60,
                          hWnd,401,
                          wc.hInstance,NULL
            mov buttonSubwindow, eax
        .ENDIF

    @EndCommand:
        jmp @DoneHandling

@NoSelectionChange:
    ; Handle other commands or control notifications here
    invoke DefWindowProc, hWnd, uMsg, wParam, lParam

@DoneHandling:




.ELSEIF uMsg==WM_DESTROY
    invoke PostQuitMessage,NULL
.ELSE
    invoke DefWindowProc,hWnd,uMsg,wParam,lParam
    ret
.ENDIF

xor eax,eax
ret
WndProc endp

end start