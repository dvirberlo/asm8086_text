.MODEL small
.STACK 100h
.DATA
;logo:
logo db '                                    \```````****-- 0 ',13,10
     db '                                     \     +``    &  ',13,10
     db '                                     .\+ `      &    ',13,10
     db '                                  %*   \      &      ',13,10
     db '                                #       \ _ /        ',13,10
     db '                               #                     ',13,10
     db '  _____        _      ____ _,/ /                     ',13,10
     db ' |  __ \      (_)    |  _   .-+                      ',13,10
     db ' | |  | |_   ___ _ __| |_) |                         ',13,10
     db ' | |  | \ \ / / | `__|  _ <                          ',13,10
     db ' | |__| |\ V /| | |  | |_) |                         ',13,10
     db ' |_____/  \_/ |_|_|  |____/                          ',13,10,'$'

exitMsg db 13,10,'hit any key to exit$'

; --------------- vars: ---------------

descrMsg   db 'Inputs string(max 200).',13,10
           db '(1.) Output all in lowercase except the first letter of each sentence',13,10
           db '(2.) Output the sentences in order(short->long).',13,10
           db '(3.) Output the number of sentences and (4.) the number of words',13,10,'$'
iMsg       db 'Enter a string(max-length:200). to end press enter:',13,10,'$'
repeatMsg  db 13,10,'Repeat? (y/n)$'
invalidMsg db 'Input invalid.',13,10,'$'

itxtLN db 13,10
itxt   db 200 dup(0)
       db 13,10,'$'
order  db 200 dup(0)

senMsg    db 'sentences: '
sen100    db 0
sen10     db 0
sen1      db 0
          db 13,10,'$'
wordsMsg  db 'words: '
words100  db 0 
words10   db 0
words1    db 0
          db 13,10,'$'

sens      db 0
words     db 0
len       db 0
point     db 0
idot      db 1
diff      db 0
count     db 0
saves     db 0

counter dw 0
.CODE
;DS must be here. else- JMP MAIN wouldn't work.
mov AX,@data
mov DS,AX
    
; ------------------------------------------------------------ ;
main: ; main routine                                           ;
; ------------------------------------------------------------ ;
    call begin
    call input
    call outputP
    call sort
    call outputOrder
    ;new line:
    mov AH, 02h
    mov DL, 13
    int 21h
    mov DL, 10
    int 21h
    
    call outputS
    call outputW
    call repeat
    jmp exit


; ------------------------------------------------------------ ;
begin: ; logo, decription, diff and zeroing                ;
; ------------------------------------------------------------ ;

    ;output logo:
    mov AH, 09h
    lea DX, logo
    int 21h
    ;output description of project:
    mov AH, 09h
    lea DX, descrMsg
    int 21h

    ;set diff
    mov diff, 'a'
    sub diff, 'A'
    
    ;zero
    mov sens, 0
    mov words, 0
    mov len, 0
    mov point, 0
    mov idot, 1 
    mov count, 0
    mov saves, 0
    mov counter, 0
    
    ;zero all itxt
    mov AX, 0
zero:
    add BX, AX    
    lea BX, itxt
    mov [BX], 0
    inc AX
    cmp AX, 200
    je retu0
    jmp zero
    
retu0:
    ret

; ------------------------------------------------------------ ;
input: ; input the string, char by char and process it.        ;
; ------------------------------------------------------------ ;
    ;iMsg
    mov AH, 09h
    lea DX, iMsg
    int 21h
    
    mov count, 0 ;counter
    mov idot, 1   
char: 
    mov AH, 01h
    int 21h
    
    ;enter
    cmp AL, 13
    je enter
    
    inc len
    ;computer array index at BX
    lea BX, itxt
    mov CL, count
    mov CH, 0
    add BX, CX
    
    ;space
    cmp AL, ' '
    je space
    ;dot
    cmp AL, '.'
    je dot    
    ;lowercase letters
    cmp AL, 'a'
    jb t1
    cmp AL, 'z'
    jbe low    
t1: ;uppercase letters
    cmp AL, 'A'
    jb save
    cmp AL, 'Z'
    jbe up

space:
    inc words
    jmp save    
dot:mov idot, 1
    call saveLen
    inc sens
    jmp save
low: ;if last char wasn't dot- save as it is. else- save uppercase
    cmp idot, 0
    je saveL
    sub AL, diff
    jmp saveL     
up: ;if last char was dot- save as it is. else- save as it is
    cmp idot, 1
    je saveL
    add AL, diff
    jmp saveL
          

saveL:
    mov idot, 0
save:
    mov [BX], AL
    
    ;check max length
    inc count 
    cmp count, 200
    jb char 
en1:ret

enter:
    call saveLen
    ret


; ------------------------------------------------------------ ;
outputP: ; output the string(uppercase first letters)          ;
; ------------------------------------------------------------ ;
    mov AH, 09h
    lea DX, itxtLn
    int 21h
    ret

; ------------------------------------------------------------ ;
saveLen: ; save start point and length at order as array       ;
         ; AL should be return as it is                        ;
; ------------------------------------------------------------ ;
    mov CL, AL
    mov DX, BX
    
    inc saves
    lea BX, order
    mov AL, sens
    mov AH, 0
    add BX, AX
    add BX, AX
    mov AL, point
    mov [BX], AL
    inc BX
    mov AL, len
    mov [BX], AL
    mov AH, point
    add AH, AL
    mov point, AH
    mov len, 0
    
    mov BX, DX
    mov AL, CL
    ret
; ------------------------------------------------------------ ;
sort: ; sort the lengths array                                 ;
; ------------------------------------------------------------ ;
    mov BX, 0
    mov CX, 0
Rche:
    inc CH
    cmp CH, saves
    je endD 
round:
    lea BX, order
    inc BX
    mov CL, 0
comp:
    mov AL, [BX]
    add BX, 2
    mov AH, [BX]
    ;if longer or equal- continue, else- replace beween them(point, lenght) 
    cmp AL, AH
    jae con
    mov [BX], AL
    sub BX, 2
    mov [BX], AH
    
    sub BX, 1
    mov DL, [BX]
    add BX, 2
    mov DH, [BX]
    mov [BX], DL
    sub BX, 2
    mov [BX], DH
    add BX, 3    
con:
    inc CL
    cmp CL, saves
    je Rche
    
    jmp comp
endD:              
    ret
; ------------------------------------------------------------ ;
outputOrder: ; output the string sorted by length              ;
; ------------------------------------------------------------ ;
    mov AX, 0
    mov BX, 0
    mov CX, 0
    mov DX, 0
    mov counter, 0
    
sen: ;ouput sentence:
    ;get starting point
    lea BX, order
    add BX, counter
    add BX, counter
    inc counter
    mov AL, [BX]
    mov AH, 0
    ;get length
    inc BX
    mov CL, [BX]
    mov CH, 0
    
    ;if length is 0- go out
    cmp CL, 0
    je retu1
    
    lea BX, itxt
    add BX, AX
cha: ;output from starting point to length    
    mov AH, 02h
    mov DL, [BX]
    int 21h
    
    inc BX
    dec CL
    cmp CL, 0
    je sen
    
    jmp cha
retu1:
         
    ret

; ------------------------------------------------------------ ;
outputS: ; binaty->ascii, output sentences count               ;
; ------------------------------------------------------------ ;
    inc sens
    mov AX, 0
    mov AL, sens
    dec AL
    mov BL, 100
    div BL
    add AL, '0'
    mov sen100, AL
    mov AL, AH
    mov AH, 0
    mov BL, 10
    div BL
    add AL, '0'
    add AH, '0'
    mov sen10, AL
    mov sen1, AH
    
    mov AH, 09h
    lea DX, senMsg
    int 21h
    ret

; ------------------------------------------------------------ ;
outputW: ; binaty->ascii, output words count                   ;
; ------------------------------------------------------------ ;
    inc words
    mov AX, 0
    mov AL, words
    mov BL, 100
    div BL
    add AL, '0'
    mov words100, AL
    mov AL, AH
    mov AH, 0
    mov BL, 10
    div BL
    add AL, '0'
    add AH, '0'
    mov words10, AL
    mov words1, AH
    
    mov AH, 09h
    lea DX, wordsMsg
    int 21h
    ret

; ------------------------------------------------------------ ;
repeat: ;ask repeat                                            ;
; ------------------------------------------------------------ ;
    mov AH, 09h
    lea DX, repeatMsg
    int 21h
    
    mov AH, 01h
    int 21h
    
    
    cmp AL, 'y'
    je main
    
    cmp AL, 'n'
    je exit
    
    jmp repeat


                
;exitMsg, key than exit:
exit:
    mov AH, 09h
    lea DX, exitMsg
    int 21h
    
    mov AH, 01h 
    int 21h   
    mov AH, 4Ch
    int 21h
END