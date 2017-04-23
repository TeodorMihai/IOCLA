%include "io.inc"
extern _printf

section .data
    print_format_u db "%u", 13, 10, 0
    print_format_c db "%c", 0
     print_format_cs db "%c", 13, 10, 0
section .text

global convert_to_native
global do_operation
global print_number



; TODO dissasemble the main.o file. Be sure not to overwrite registers used
; by main.o that he does not save himself.
; If you see your program going nuts consider looking in the main.o disassembly
; for the causes mentioned earlier.

; functia convert primeste un parametru: o cifra in hexa sub forma unui char
; si returneaza echivalentul ei in baza 16 ex: B -> 11

convert_from_char:
        push ebp
        mov ebp, esp
        
        xor al, al
        mov al, byte[ebp + 8]
        
        
        cmp al, '9'
        jle cifra_zecimala 
        add al, 10
        sub al, 'A' 
        jmp termina
cifra_zecimala:    
        sub al, '0'
termina:
        leave 
        ret
        
        
        
; functie de convertire de la int la char pt 15 --> F

convert_from_int:

        push ebp,
        mov ebp, esp
        
        xor al, al
        mov al, byte[ebp + 8]
        shr al, 4
        
        cmp al, 9
        jg transforma_litera
        add al, '0'
            
        jmp iesire_conversie
transforma_litera:
        sub al, 10
        add al, 'A'
        
iesire_conversie:
        leave
        ret
        
; function to write

convert_to_native:
        push ebp
        mov ebp, esp
     
        push dword[ebp + 16]        ; a_str
        push dword[ebp + 8]         ; a
        call convert_to_native_for_one_number
        add esp, 8
        
        push dword[ebp + 20]        ; b_str
        push dword[ebp + 12]        ; b
        call convert_to_native_for_one_number
        add esp, 8
        
        leave 
        ret
            
convert_to_native_for_one_number:
	push ebp
        mov ebp, esp
        xor eax, eax
        xor edx, edx
        mov ebx, dword[ebp + 8]    ; adresata de start a primului numar dat
                                   ; ca argument in linia de comanda
                                   ;in edx voi retine lungimea sirului
next_char_in_a:
        mov al, byte[ebx]
        cmp al, 0
        je exit_next_char_in_a
     
        inc edx
        inc ebx
        jmp next_char_in_a
exit_next_char_in_a:

        ; acum am in edx lungimea sirului
        ; voi parcurge cu edx adrsele stringului meu si cu ecx adresele 
        ; numeraului pe care vreau sa-l construiesc
        
        ; punem semnul :
        xor eax, eax
        mov ebx, dword[ebp + 8]
        mov ecx, dword[ebp + 12]    
        
        mov al, byte[ebx]
      
        cmp al, '-'                ;daca semnul este cu minus
        je pune_minus
        mov dword[ecx], 0x00000000 ;else pune 0
        jmp nu_pune                ; aka continua
pune_minus:
        mov dword[ecx], 0xFFFFFFFF
        inc ebx                    ; daca este minus trecem la urmatorul element
        dec edx                    ; scadem lungimea sirului
nu_pune:
        ; punem lungimea:
        mov eax, edx               ; retinem lungimea strignului in eax, edx se va modifica
       
        inc edx
        shr edx, 1                 ; lungimea efectiva = (lungimea stringului + 1)/2
       
        add ecx, 4                 ; urmatorii 4 bytes, pentru lungime
        mov dword[ecx], edx 
        add ecx, 4
        
        mov edx, eax               ; pun in edx din nou lungimea efectiva a stringului
        
        ; parcurg sirul invers :
next_element_invers:
        cmp edx, 1
        jle  iesire_parcurgere_inversa
       
        lea esi, [ebx + edx - 2]
        push dword[esi]
        call convert_from_char
        add esp, 4
       
        mov ah, al                  ; am obtinut numarul convertit in al, il retin in ah
       
        lea esi, [ebx + edx - 1]    ; iau adresa ebx + edx - 1
        push dword[esi]              ; dereferentiez, iau elementul propiu zis
        call convert_from_char
        add esp, 4
        ; acum am in ah numarul convertit de a caracter
       
        shl ah, 4
        add ah, al
        
        mov byte[ecx], ah             ; punem octetul in sir, finally
        sub edx, 2
        inc ecx
        jmp next_element_invers
iesire_parcurgere_inversa: 
        cmp edx, 1
        je adauga_prima_cifra
        dec ecx                       ; daca nu adaug nimic ma intorc la ultima zona de memorie udne am pus ceva
        jmp nu_adauga_prima_cifra
adauga_prima_cifra:
        push dword[ebx]
        call convert_from_char
        add esp, 4
        mov byte[ecx], al
nu_adauga_prima_cifra:        
        leave                          ; reface pointerul esp unde era imediat dupa apelarea functiei 
	ret        

                                       ; reface esp unde era inainte de apelrea functiei
;convert to c2 function
convert_c2:
        push ebp
        mov ebp, esp
        
        mov eax, dword[ebp + 12]
        mov edx, dword[ebp + 8]
        xor ebx, ebx
   
        
        ; le inversam:
for:
        cmp ebx, eax
        jg iesire_for
        mov cl, 0xFF
        sub cl, byte[edx]
        mov byte[edx], cl
        add edx, 1 
        inc ebx
        jmp for
iesire_for:

                ; adunam 1:
        mov edx, dword[ebp + 8]
        xor ebx, ebx
        clc
        mov ecx, eax                  
        add byte[edx], 1              ; posibil sa declanseze carry
        inc edx                       ; imposibil de declansat carry ? no worries
                                      ; mai adaug 1, lungimea mea e eax 
for_carry:
        dec ecx
        jz iesire_for_carry
        adc byte[edx], 0
        
        inc edx
        jmp for_carry
iesire_for_carry:    

         
        leave
        ret
        
        
; addition function       
do_addition:
        push ebp
        mov ebp, esp
        
        
        mov edx, dword[ebp + 8]
        mov eax, dword[edx + 4]    ; lungimea pimului numar
        mov edx, dword[ebp + 12]
        mov ebx, dword[edx + 4]    ; lungimea celui de-al doilea numar
   
        cmp eax, ebx
        jle al_doilea
        jmp terminat_max_len        
al_doilea:
        mov eax, ebx
terminat_max_len:

        inc eax
        ;inainte sa fac orice compar cele doua numere in modul si pun rezultatul pe stiva
        mov esi, dword[ebp + 8]
        mov ebx, dword[ebp + 12]
        
        
        add esi, 8
        add ebx, 8
        xor edi, edi
        
        dec eax
        dec eax
        
        add esi, eax
        add ebx, eax
        
        
        
for_comparare_modul:
        cmp edi, eax
        jg sunt_egale_numerele
                                                                   ; adresa celor 2 cifre din primul nr
        mov cl, byte[esi]              ; cele 2 cifre din primul nr
        
                                      ; adrsa celor 2 cifre din al doilea nr, in ordnea semnificativitatii
        mov ch, byte[ebx]
        inc edi
        
        dec esi
        dec ebx
        
        cmp ch, cl
        je for_comparare_modul               ; dca sunt egale comparar urmatoarele 2 cifre
        cmp cl, ch
        ja primul_mai_mare
        ; al doilea mai mare:
        push 2                                ; al doilea e mai mare , bag 2
        jmp gata_cu_compararea        
primul_mai_mare:
        push 1                                ; 1 -> primul mai mare
        jmp gata_cu_compararea

sunt_egale_numerele:
        push 3
gata_cu_compararea:
       
        add eax, 2
       
        ; acum in eax am lungimea maxima dintre cei doi
        ; verifica fiecare numar daca e nagativ,
        ; daca e negativ ii fac c2 pe lungimea eax
        mov edx, dword[ebp + 8]
        cmp byte[edx], 0xFF                       
        je do_c2
        jmp do_nothing
do_c2:    
        push eax
        add edx, 8
        push edx
        call convert_c2
        add esp, 8
do_nothing:

        mov edx, dword[ebp + 12]
        cmp byte[edx], 0xFF                       
        je do_c2_second
        jmp do_nothing_second
do_c2_second:    
        push eax
        add edx, 8
        push edx
        call convert_c2
        add esp, 8
do_nothing_second:
         
        
        ; acum fiecare numar in c2 daca este negativ
        ; trebuie doar sa le adunam efectiv. cu carry and stuff
       
        mov edx, dword[ebp + 8]           ;  primul, unde si adunam
        mov ebx, dword[ebp + 12]          ; al doilea
        
        add edx, 8                                  ; in eax avem lungimea maxima
        add ebx, 8
        
       ; inc eax
        mov edi, eax                       ; retin o copei a lungimii celui mai amre nr + 1
        clc                                ; clean carry                          
for_adunare:
        dec eax
        jz iesire_adunare
        mov cl, byte[ebx]
        adc byte[edx], cl
        
        inc edx
        inc ebx
        
        jmp for_adunare    
iesire_adunare:

        ; ok acum trebuie sa mai setam semnul si lenght in primul numar
        ; ca sa facem asta trebuie sa vedem daca numarul rezultat e pozitiv sau negativ
        ; daca e nagetiv il vom trece din nou prin c2 ca sa obtinem forma lui nromala ( pt ca daca e negativ
        ; e reprezentat in C2)
        
        mov edx, [ebp + 8]
        mov cl, byte[edx]                     ; semul primului numar, inca nu a fost distrus
        mov ebx, [ebp + 12]
        mov ch, byte[ebx]                     ; semnul celui de-al doilea numar
        
        xor ebx, ebx
        pop ebx
        
        
        cmp cl, 0
        jne terminare_ambele_pozitive
        cmp ch, 0
        jne terminare_ambele_pozitive
        ; ambele pozitive, nimic de facut
      
terminare_ambele_pozitive:
        
        cmp cl, 0
        jne terminare_primul_pozitiv_al_doilea_negativ
        cmp ch, 0
        je terminare_primul_pozitiv_al_doilea_negativ
        ;primul pozitiv, al doilea negativ
                                     ; ebx ne zice acum care e mai mare 1, primul 2, al doilea
      
        
        
        cmp ebx, 2
        je fa_c2_pentru_rezultat
terminare_primul_pozitiv_al_doilea_negativ:


        cmp cl, 0
        je terminare_primul_negativ_al_doilea_pozitiv
        cmp ch, 0
        jne terminare_primul_negativ_al_doilea_pozitiv
        ;primul negativ, al doilea pozitiv
       ; ebx ne zice acum care e mai mare 1, primul 2, al doilea
     
       
        cmp ebx, 1
        je fa_c2_pentru_rezultat
        
        
terminare_primul_negativ_al_doilea_pozitiv:

        cmp cl, 0
        je terminare_ambele_negative
        cmp ch, 0
        je terminare_ambele_negative
        ; ambele sunt negativ:
        ;setez semnul primului nr(rezultatul ca fiind -) si fac c2
        
fa_c2_pentru_rezultat:
        mov dword[edx], 0xFFFFFFFF
        add edx, 8
        push edi                    ; edi nu trebuie sa se modifice!!
        push edx
        call convert_c2
        add esp, 8
        
terminare_ambele_negative:
        ; acum mai trebuie doar sa setez lungimea
        mov edx, [ebp + 8]
        add edx, 8
        
        xor ebx, ebx
        
        add edx, edi
        dec edx
        
for_lungime:
        
        
        cmp byte[edx], 0
        jne terminare_for_lungime1
        jmp continua_masurare
terminare_for_lungime1:        
        cmp byte[edx], 0xFF
        jne terminare_for_lungime
        
continua_masurare:
        inc ebx
        dec edx
        
        jmp for_lungime
terminare_for_lungime:

        ; acum in edi am noua lungime, o pun unde trebuie
     
        sub edi, ebx
        mov edx, dword[ebp + 8]
        mov dword[edx + 4], edi
         
        ; al, ah semnul primului respectiv celui de-al doilea nr
        leave 
        ret


;shiftare stanga
shiftare_st:

        push ebp
        mov ebp, esp
        
        
        xor edx, edx
        
        mov edi, dword[ebp + 12]        ; adresa cu cat trebuie sa shiftez
        add edi, 8
        mov dl, byte[edi]
        
        mov ebx, edx                        ; retin o copie
        shr dl, 2                         ; cate zerouri trebuie aduagate la final, 
                                          ;impartim la 4, o cifra de-a noastra are 4 biti
        
        ;adauga zeroruile
        ; mai intai modific lungimea cuvantului
        ; verific daca am numar impar de cifre mai intai aka 0 pe ultimul octet in partea dreapta
        
        mov esi, dword[ebp + 8]              ; adresa primului nr
        add esi, 4
        
        mov eax, dword[esi]                 ; lungimea
        
        
        add esi, 4
        add esi, eax
        dec esi 
        
        xor eax, eax
        mov al ,byte[esi]
        
        shr al, 4
        cmp al, 0                            ; daca avem nr impar de cifre aka nu sunt toate ocupate
        je impar
        jmp done
impar:    
        dec dl                               ; practic trebuie sa facem loc cu 1 mai putin pentru zerouri
done:
        inc dl
        shr dl, 1                            ; spatiu adaugat = cate zer bagam - 1 (daca e impar) + 1 totul pe 2
        
        mov esi, dword[ebp + 8]             ; adresa primului nr
        add esi, 4
        add dword[esi], edx                ; am adaugat efectiv, acum avem lungimea buna trebuie doar sa shiftam
        
        mov edi, dword[ebp + 12]
        add edi, 8
        mov edx, dword[edi]                   ; cu cat trebuie sa shiftam + 1
        inc edx
    
        
        add esi, 4
        ;edx cu cat trebuie sa shiftam, esi - adresa primului nr, cele mai nesemnificative cifre
        
        mov ebx, dword[esi - 4]            ; lungimea noului numar
        xor eax, eax

reia_shiftare:
        dec edx
        
        jz terminare_shiftare
        ;The high-order bit is shifted into the carry flag; the low-order bit is set to 0.

        mov esi, dword[ebp + 8]
        add esi, 8
        mov eax, ebx
        
        clc
        shl byte[esi], 1
        inc esi
       
        
        
urmatorul_byte:
        dec eax
        jz reia_shiftare
        
        mov cl, 0
        adc cl, 0
        
        shl byte[esi], 1
        
        dec cl
        jnz continua_shift
        inc byte[esi]
continua_shift:      
 
        inc esi
        jmp urmatorul_byte
        
terminare_shiftare:

      
        

        leave
        ret
        
        
        
shiftare_dr:

        push ebp
        mov ebp, esp
        
        
        xor ecx, ecx
        
        mov edi, [ebp + 12]           
        add edi, 8
        mov cl, byte[edi]                 ; cu cat trebuie sa shiftez
        
        inc cl
        
reia_shiftare_dr:
        dec cl
        jz terminare_shifatre_dr
        
        mov edi, dword[ebp + 8]
        add edi, 4
        mov ebx, dword[edi]
               
        
        add edi, 4
        add edi, ebx
        dec edi

        ; in ebx am lungimea si in edi am adresa ultimei cifre
        clc
        shr byte[edi], 1
       
        dec edi
       
        
        
urmatorul_byte_dr:
        dec ebx
        jz reia_shiftare_dr
        
        
        mov ch, 0
        adc ch, 0
        
        shr byte[edi], 1
        
        
        ; adun carryul de la shiftarea anterioara la byteul curentS
        dec ch
        jnz continua_shift_dr  
        mov al, 0x81
aduna_0x80:
        dec al
        jz continua_shift_dr
        inc byte[edi]
        jmp aduna_0x80
continua_shift_dr:
     
 
        dec edi
        jmp urmatorul_byte_dr 
terminare_shifatre_dr:

        ; acum trebuie sa mai setez len-ul:
        
        
        mov edi, dword[ebp + 8]
        add edi, 4
        mov ebx, dword[edi]
               
        
        add edi, 4
        add edi, ebx
        dec edi
        
        mov ecx, ebx
        xor eax, eax
        ; in ecx, ebx am lungimea si in edi am adresa ultimei cifre
aflare_lungime:

        cmp byte[edi], 0x00
        jne terminare_aflare_lungime
        
        inc eax
        dec edi
        
        jmp aflare_lungime
terminare_aflare_lungime:

        sub ebx, eax
        mov edi, dword[ebp + 8]
        add edi, 4
        mov dword[edi], ebx
finish:
        ; to do setare lungime
        leave
        ret
        
;original function

do_operation:
	push ebp
        mov ebp, esp
        
      
        xor ecx, ecx
        mov edx, dword[ebp + 16]
        ;inc edx
       
        mov cl, byte[edx]
        cmp cl, '+'
        je adunare
        
        cmp cl, '<'
        je shiftare_stanga    
        
        cmp cl, '>'
        je shiftare_dreapta
        ;inmultire:
        
        
        jmp termina_operatie
adunare:
        
        push dword[ebp + 12]
        push dword[ebp + 8]
        call do_addition
        add esp, 8
        
        jmp termina_operatie
shiftare_stanga:
        push dword[ebp + 12]
        push dword[ebp + 8]
        call shiftare_st
        add esp, 8
        
        jmp termina_operatie
        
        
shiftare_dreapta:
        push dword[ebp + 12]
        push dword[ebp + 8]
        call shiftare_dr
        add esp, 8
        
        jmp termina_operatie
termina_operatie:





        
        leave
	ret
; funcite printeaza numarul inf orma in care a fost dat ca argument, cu - si toate nebuniile
print_number:
        push ebp
        mov ebp, esp
        
        mov edx, dword[ebp + 8]
        cmp byte[edx], 0xFF
        je numar_negativ
        jmp numar_pozitiv
numar_negativ:
        push '-'
        push print_format_c
        call _printf
        add esp, 8
numar_pozitiv:
        
        mov edx, dword[ebp + 8]
        add edx, 4
        mov edi, dword[edx]              ; in edi acum avem lungimea
        
        lea ecx, [edx + 4 + edi - 1]     ; adresa primeleor 2 cifre
        mov ebx, dword[ecx]              ; primele 2 cifre efectiv
        mov esi, ebx
        shr bl, 4
       
        cmp bl, 0
        je nu_pune_prima_cifra
        jmp pune_prima_cifra
nu_pune_prima_cifra:
        dec edi
        
        mov ebx, esi
        shl bl, 4
        xor eax, eax
        push ebx
        call convert_from_int
        add esp, 4
        
        push edi
        
        push eax                             ; afisma al, restul sunt 0
        push print_format_c
        call _printf
        add esp, 8
        
        pop edi
        
pune_prima_cifra:                    
        
        xor esi, esi
        xor eax, eax
reia_afisare:
        cmp edi, 0
        je terminare_afisare
        
        mov edx, dword[ebp + 8]              ; ca sa nu mai trebuiasca sa-l pun pe stiva
        add edx, 8
        lea ecx, [edx + edi - 1]             ; in ecx avem adresa elementului pe care vrem sa-l afisam
        mov esi, dword[ecx]
        
        xor eax, eax
        push esi
        call convert_from_int
        add esp, 4
        
        ; salvez valorile pe stiva
        push edi
        push esi
        
        push eax                             ; afisma al, restul sunt 0
        push print_format_c
        call _printf
        add esp, 8
        
        pop esi
        shl esi, 4
        
        xor eax, eax
        push esi
        call convert_from_int
        add esp, 4
        
        push eax                              ; afisam al
        push print_format_c
        call _printf
        add esp, 8
        
        
        pop edi
        
        dec edi
        jmp reia_afisare
terminare_afisare:
            
        leave
	ret

    