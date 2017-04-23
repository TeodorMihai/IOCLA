%include "io.inc"

extern puts

section .data
      myString: db 'Baza incorecta',0
 
      %include "/home/teo/Politehnica/an2sem1/IOCLA/iocla-tema1-resurse/inputs/input1.inc"

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging

    push ebp
    mov ebp, esp
    sub esp, 128 ; ca sa retin in ordine inversa cifrele
    
    xor eax, eax
    xor ecx, ecx
    xor edx, edx
    xor ebx, ebx ; cate cifre va avea reprezntarea
   
    mov eax,[numar]
    mov ecx,[baza]
    ; in caz de baza gresita
    cmp ecx, 0
    jle bazagresita
    
    cmp ecx, 16
    jg bazagresita
    
    ;pun cifrele pe stiva
continua:
    cmp eax,0
    je exit
    
    inc ebx ; retin cate cifre am
    xor edx, edx
    div ecx
    push edx
    jmp continua
    
exit:

reia:
    cmp ebx, 0 ;afisez cifrele 2 cazuri daca este cifra sau caracter
    je iesire
    dec ebx
   
    pop edx
    cmp edx, 10
    jge printchar
    
    cmp edx, 10
    jl printnumber
    
printchar:
    ;trasnform in ascii corespunzator
    sub edx, 10
    add edx, 'A'
    PRINT_CHAR edx
    jmp reia

printnumber:
    PRINT_UDEC 4, edx
    jmp reia
bazagresita:

    lea eax, [myString]
    push eax
    call puts
    pop eax
iesire:
    leave
    ret