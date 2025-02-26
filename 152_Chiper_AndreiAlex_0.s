.data
    a: .space 1024
    n: .long 1024
    QUERIES: .long -1
    readNumber: .asciz "%ld"
    doubleReadNumber: .asciz "%ld%ld"
    tipOperatie: .long -1
    numarAdaugari: .long -1
    idFisier: .long 0
    dimensiuneFisier: .long -1
    blocks: .long -1
    free_blocks: .long 0
    startInterval: .long 0
    sfarsitInterval: .long 0
    from: .long -1
    to: .long -1
    afisareInterval: .asciz "%ld: (%ld, %ld)\n"
    afisareIntervalGet: .asciz "(%ld, %ld)\n"
    printNumber: .asciz "debug %ld\n"
    wantForDelete: .long 0
    printDeleteFirstPart: .asciz "%ld: "
    printDeleteSecondPart: .asciz "(%ld, %ld)\n"
    notEnoughMemory: .asciz "%ld: (0, 0)\n"
.text
.global main

main:
    pushl $QUERIES 
    pushl $readNumber
    call scanf # Citim cate query-uri avem
    
    add $8, %esp # Dam doua pop-uri
    
manage_queries:
    mov $0, wantForDelete 
    mov QUERIES, %eax # Punem variabila queries in %eax pentru comparare
    cmp $0, %eax # Verificam daca QUERIES este egal cu 0
    je exit_program # Daca este egal cu 0 terminam programul
    decl QUERIES # Scadem 1 QUERIES

    pushl $tipOperatie # Punem adresa tipOperatie in stiva ca sa il avem cand vrem sa-l accesam in functie
    call readNumber_function # Apelam functia de citit
    add $4, %esp # Stergem adresa lui tipOperatie de pe stiva


    





    movl tipOperatie, %edx
    cmp $1, %edx
    je add_function # SARIM la operatia de add

    cmp $2, %edx
    je citire_fisier_get # Sarim la operatie de get

    cmp $3, %edx
    je delete_function
    
    cmp $4, %edx
    je defragmentation_function
    jmp manage_queries # Repetam cat timp QUERIES este mai mare decat 0



readNumber_function: # Citim o valoare in ultima adresa de pe stiva
    pushl 4(%esp) # Punem adresa lui tipOperatie iara pe stiva ca sa apelam scanf
    pushl $readNumber # Formatul de citire
    call scanf # Citim

    add $8, %esp # Dam pop de doua ori ca sa scoatem chestiile de la citire


    ret # Iesim

# DO NOT TOUCH THIS IS ADD
# <--------------------------------------------------------------------------------------->
add_function: 
    
    
    pushl $numarAdaugari # Citim cate fisiere trebuie adaugate
    call readNumber_function # Apelam functia de citit a numerelor

    add $4, %esp # Facem un pop


    loop_add_function: # Loop-ul pentru a adauga fisierele
        mov numarAdaugari, %eax # Punem numarAdaugari in eax
        cmp $0, %eax # Verificam daca numarAdaugari este 0
        je manage_queries # Daca nu mai avem fisiere de adaugat ne intoarcem la citirea query-urilor
        decl numarAdaugari
    
        call add_fisier_function # Apelam functia de adaugare unui singur fisier

        jmp loop_add_function # Ne intoarcem sa mai adaugam un fisier

add_fisier_function: 

    pushl $dimensiuneFisier
    pushl $idFisier
    pushl $doubleReadNumber
    call scanf # Citim id-ul si dimensiunea fisierului
    add $12, %esp # Dam pop de 3 ori
    

    mov $0, %edx

    add $7, dimensiuneFisier # Adaugam pentru rotunjire in sus
    mov dimensiuneFisier, %eax # Mutam pentru impartire

    shr $3, %eax # Impartim cu 8 ca sa avem numarul de block uri

    mov %eax, blocks # cate block uri ne trebuie
    mov $0, free_blocks # cate block uri avem libere intr-un streak
    
    mov $0, %ebx # folosim ebx ca index

    for_loop_add: # Functie pentru verifcare de goluri
        # Sa ai grija ca poate nu e loc ???
        cmp n, %ebx
        je not_enough_memory
        mov $0, %eax
        movb a(%ebx,1), %al # Mutam a[%ebx] in ultimul byte din %eax

        pushl %eax 
        call check_and_modify # functie care verifica daca este zero si da update la free_blocks

        addl $4, %esp # Dam un pop

        movl free_blocks, %eax
        cmp blocks, %eax
        je modify_range_add # Daca am gasit loc liber sarim sa modificam locul liber

        inc %ebx
        jmp for_loop_add

check_and_modify:
    movl 4(%esp), %edx # Accesam elementul din vector

    cmp $0, %edx
    je increase_free_blocks # Daca este liber sarim peste 

     
    movl $-1, free_blocks

    increase_free_blocks:
        inc free_blocks
    
    ret 

modify_range_add:
    mov %ebx, to

    sub free_blocks, %ebx # ebx is the index
    inc %ebx

    movl %ebx, from

    pushl to
    pushl from
    pushl idFisier
    pushl $afisareInterval
    call printf # Afisam intervalul
    add $16, %esp # 4 pop uri
    
   
    pushl $0
    call fflush
    add $4, %esp

    modify_range_loop:
        mov from, %ecx
        cmp to, %ecx
        jg loop_add_function

        movl idFisier, %eax
        movb %al, a(%ecx,1) # Punem id ul in a[%ecx]

        inc from
        jmp modify_range_loop

    
# DO NOT TOUCH THIS IS ADD
# <---------------------------------------------------------------------------------------------------->

citire_fisier_get: # Aici se citeste care fisier vrem sa il cautam
    pushl $idFisier
    call readNumber_function

    add $4, %esp

get_function:
    
    mov $0, %ecx
    mov $-1, from
    mov $-1, to

    get_function_for_loop:
        cmp n, %ecx
        je for_is_done # Comparam daca ajungem la sfarsit

        mov $0, %eax
        movb a(%ecx, 1), %al # Punem in eax ce fisier se afla la pozitia ecx

        cmp idFisier, %eax # Daca gasim fisierul sarim sa dam update la interval 
        je update_interval

        done_update_from:
        inc %ecx
        jmp get_function_for_loop
    
    update_interval:
       
        mov %ecx, to # Dam update la ultimul capat
        cmp $-1, from # Daca este prima instanta pe care o gasim sarim sa updatam inceput
        je update_from
        jmp done_update_from # ne intoarcem inapoi la for
    update_from:
     
        mov %ecx, from # Aici se updateaza inceputul
        jmp done_update_from

    for_is_done:
        cmp $-1, from # Daca nu am gasit fiserul from ramane -1 si atunci vom merge la afisarea lui (0, 0)
        je notFound 
        jmp printInterval # Am gasit intervalul si sarim sa il afisam

    notFound: # nu am gasit nimic si intervalul este (0, 0)
        mov $0, from 
        mov $0, to

    printInterval: # Printam intervalul
        pushl to
        pushl from
        pushl $afisareIntervalGet
        call printf

        add $12, %esp
        
        pushl $0
        call fflush

        add $4, %esp

    
    mov to, %ebx
    inc %ebx # Aici sarim in afara intervalului gasit (folosit la functia delete)
    
    cmp $1, wantForDelete 
    je remove_print_loop # Aici sarim la intervalul remove_print_loop care este folosit in functia remove (adica ne folosim de functia get ca sa aflam intervalele de fisiere ramase dupa functia delete)

    jmp manage_queries # Am terminat functia de get si ne intoarcem la query-uri
        
# THIS IS GET
# <----------------------------------------------------------->


# THIS IS DELETE

# <----------------------------------------------------------------->

delete_function: 
    mov $1, wantForDelete # marcam ca vrem functia delete (schimba putin functia GET)
    pushl $idFisier
    pushl $readNumber
    call scanf

    add $8, %esp

    movl $0, %ebx
    remove_loop: # Aici inlocuim toate elementele egale cu idFisier (fisierul pe care vrem sa-l stergem) cu 0
        cmp n, %ebx
        je done_remove_loop_now_print # Am inlocuit toate elementele si printam intervalele ramase

        mov $0, %eax
        movb a(%ebx, 1), %al

        cmp idFisier, %al
        je remove_file # Sarim sa punem 0 in loc de idFisier
        done_remove_file:
        inc %ebx # crestem index ul
        jmp remove_loop

    remove_file:
        movb $0, a(%ebx, 1) # Inlocuim cu 0-
        jmp done_remove_file
    done_remove_loop_now_print: # AICI POATE REVIN cu defrag (functia printeaza intervalele ramase)
        movl $0, %ebx
        remove_print_loop:
            cmp n, %ebx
            je manage_queries

            mov $0, %eax 
            movb a(%ebx, 1), %al # eax va tine ce avem pe pozitia ebx

            cmp $0, %eax
            jne print_interval # Am gasit un fisier si sarim sa-l printam

            inc %ebx # crestem controlul
            jmp remove_print_loop

        print_interval:
            mov %eax, idFisier
            pushl %eax
            pushl $printDeleteFirstPart
            call printf # Printam descriptorul fisierului
            add $8, %esp 

            jmp get_function


defragmentation_function:
    mov $1, wantForDelete # marcam 1 ca sa ne folosim de afisarea intervalelor din functia get
    mov $0, %ebx # ebx este index-ul curent
    mov $0, %ecx # ecx este index-ul cu care vom schimba

    defragmentation_for_loop:
        cmp n, %ebx
        je done_remove_loop_now_print
        
        mov $0, %eax
        movb a(%ebx, 1), %al

        cmp $0, %eax
        jne swap_elements 
        done_swap:

        inc %ebx
        jmp defragmentation_for_loop

    swap_elements:
        mov $0, %edx
        movb a(%ecx, 1), %dl

        mov $0, %eax
        movb a(%ebx, 1), %al

        movb %al, a(%ecx, 1)
        movb %dl, a(%ebx, 1)

        inc %ecx
        jmp done_swap

exit_program:

    pushl $0 
    call fflush
    add $4, %esp
    
    mov $1, %eax
    mov $0, %ebx

    int $0x80

not_enough_memory:
    pushl idFisier
    pushl $notEnoughMemory
    call printf
    add $4, %esp
    jmp loop_add_function
