%include "io.inc"

section .data
    
    incorrect_base_message db "Baza incorecta", 0
    converted_number times 64 dw 0
    %include "input.inc"

section .text

    extern puts

global CMAIN

CMAIN:

    push ebp
    mov ebp, esp
    
    ;golim registrele
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    
    ;datele initiale
    
    ;salvam numarul in EAX
    mov eax, dword[numar]
    
    ;salvam baza in ebx
    mov ebx, [baza]
    
    
    ;daca baza este <2 sau >16, scriem un mesaj de eroare
    cmp ebx, 2
    jl incorrect_base
    cmp ebx, 16
    jg incorrect_base
    
 
    mov ecx, 0 ; indexul curent in cadrul numarului
    
   
    
    
determine_size:
    
    cmp ax, 0 ;daca ax este 0, numarul este un word
    je word_conversion
    
    cmp ah, 0;daca ah este 0, numarul este un byte
    je byte_conversion
    
    
    
double_conversion:

    cmp eax, 0 
    je word_conversion
    div ebx ; impartim la ebx, catul este in eax, restul in edx
    
    cmp edx, 10
    jge is_hex_character_dw 
    
    ; adaugam restului 48 daca este cifra, sau 55 daca
    ; este caracter (A,B,C,D,E,F), pentru a-l face egal cu codul ascii al literei
    ; pe care vrem sa o adaugam in string-ul rezultat
    
    add edx, 0x30 
    jmp move_to_dw
    
is_hex_character_dw:
    add edx, 0x57;
    
move_to_dw:
    mov dword[converted_number + ecx], edx 
    
    
    xor edx, edx
    inc ecx
    cmp eax, 0
    jg double_conversion
    je word_conversion
    
word_conversion:

    cmp dx, 0
    je byte_conversion
    
    div bx ; impartim la bx catul se afla in ax, restul in dx(edx)
    
    cmp edx, 10
    jge is_hex_character_w
    
    add edx, 0x30 
    jmp move_to_w
    
is_hex_character_w:
    add edx, 0x57;
    
move_to_w:
    mov word[converted_number + ecx], dx 
    
    
    xor edx, edx
    inc ecx
    cmp eax, 0
    jg word_conversion
    je byte_conversion
    
byte_conversion: ; pe 8 biti

    cmp al, 0
    je reverse_number
    
    div bl;  
    mov dl, ah 
    
    cmp edx, 10
    jge is_hex_character_b
    
    add dl, 0x30 
    jmp move_to_b
    
is_hex_character_b:
    add dl, 0x57;

move_to_b:
    mov byte[converted_number + ecx], dl
    
    
    xor edx, edx
    xor ah, ah
    inc ecx
    cmp al, 0; daca catul este 0, algoritmul se incheie
    jg byte_conversion
    

;/**************************************END OF CONVERSION ALGORITHM************************************/

reverse_number:
    
    ;golim registrele
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
   
    mov ebx, converted_number ; pozitia in string
    mov ecx, 0 ; lungimea curenta

find_length:

    mov al, [ebx] ; scoatem cate un char din string
    cmp al, 0 ; este \0?
    je reverse_string ; daca da, am aflat lungimea

    inc ebx ; daca nu, avansam in string
    inc ecx ; crestem lungimea
    jmp find_length

reverse_string: ; ecx = strlen

    ;daca stringul are 0 sau 1 caracter, este egal cu inversul sau
    cmp ecx, 2 
    jb print_result 

    mov ebx, converted_number ; ebx este pointerul la inceputul stringului
    lea edx, [ebx+ecx-1] ; edx este pointerul la sfarsitul stringului
    shr ecx, 1 ; ecx = len/2
    

modify_pointers:

    mov al, [ebx]
    xchg al, [edx]
    mov [ebx], al ; [ebx] si [edx] interschimbate
    inc ebx ; avansam head pointerul
    dec edx ; avansam tail pointerul
    loop modify_pointers ; scadem ecx, repetam daca ecx != 0

print_result:

    ;printam rezultatul
    
    push converted_number
    call puts
    jmp end_program

incorrect_base:
    push incorrect_base_message
    call printf    
    
    
end_program:

    leave
    ret
