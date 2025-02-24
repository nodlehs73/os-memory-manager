.data
    operations: .space 256
    used: .space 256
    a: .space 1048576
    n: .long 1048576
    columns: .long 1024
    rows: .long 1024
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
    afisareIdFisier: .asciz "%ld: "
    afisareInterval: .asciz "%ld: (%ld, %ld)\n"
    afisareIntervalGet: .asciz "\n"
    printNumber: .asciz "%ld\n"
    printNumberNoEndl: .asciz "%ld"
    wantForDelete: .long 0
    printDeleteFirstPart: .asciz "%ld: "
    printDeleteSecondPart: .asciz "(%ld, %ld)\n"
    new_line: .asciz "\n"
    notEnoughMemory: .asciz "%ld: ((0, 0), (0, 0))\n"
    index_row: .long -1
    saved_index_row_get: .long -1
    print2dCord: .asciz "((%ld, %ld), (%ld, %ld))\n"
    save: .long 0
    saved_to: .long 0
    modulo_to: .long -1
    modulo_from: .long -1
    i: .long 0
    j: .long 0
    comingFromDefragmentation: .long 0
    debug: .asciz "%ALEX\n"
    save_for_defrag_function: .long 0
    saved_index_for_add_from_defrag: .long 0
    arrive: .asciz "arrived here"
    path: .asciz "/home/alex/proiect_asc/folder_test/file1.txtsadkjfsjflsdjfsdlkjfdskfjdskjfkdjfdksjfdkfjdfkjdkjfdkfjdkfjdkfjdkfjdjfdfkdjfkdjfdkfjdkfjdkjfldjfksjafksdjflksajfksadhfdsjkafhjksdhfjsdajfdjsahfkjsdhfshfjakshfjksafhjksdhfjkdahfsahfjkahfjksdhfjkshfsjdkhafksahfkjsdahfsjkadhfadskjhfasdkjfhksajfhajkfhdajkfhajhfkjahfjkasdhfkjadshfjksdahfdajfhjkdahfkjashfjksdhfdshfjkafhasjfdhajksfhasjkdfhaskjfhdajksfhajsfhajkfhadskjfhadskfjhakfhakahahf"
    formatScanfString: .asciz "%s"
    file_path: .space 1000
    buffer: .space 10000
    comingFromConcrete: .long 0
    bytesRead: .long 0
    index_buffer: .long 0
    descriptor: .long 0
    dimensiuneFisierConcrete: .long 0
    afisareDescriptorDimensiune: .asciz "%ld\n%ld\n"
.text
.global main

/*
    
*/
main:
    pushl $QUERIES 
    pushl $readNumber
    call scanf # Citim cate query-uri avem
    
    add $8, %esp # Dam doua pop-uri
    
manage_queries:
    mov $0, saved_index_for_add_from_defrag 
    mov $-1, index_row # reinitializam index_row
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

    cmp $5, %edx
    je concrete_function

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
        mov comingFromConcrete, %eax
        cmp $1, %eax
        je done_add_file_concrete

        mov comingFromDefragmentation, %eax
        cmp $1, %eax
        je skip_compare_defragmentation_function

        mov $0, saved_index_for_add_from_defrag 

        mov numarAdaugari, %eax # Punem numarAdaugari in eax

        cmp $0, %eax # Verificam daca numarAdaugari este 0
        je manage_queries # Daca nu mai avem fisiere de adaugat ne intoarcem la citirea query-urilor
        decl numarAdaugari
    
        jmp add_fisier_function # Apelam functia de adaugare unui singur fisier

        jmp loop_add_function # Ne intoarcem sa mai adaugam un fisier

add_fisier_function: 
    
    pushl $dimensiuneFisier
    pushl $idFisier
    pushl $doubleReadNumber

    call scanf # Citim id-ul si dimensiunea fisierulu
    add $12, %esp # Dam pop de 3 ori

    mov $0, %edx

    add $7, dimensiuneFisier # Adaugam pentru rotunjire in sus
    mov dimensiuneFisier, %eax # Mutam pentru impartire
    
    shr $3, %eax # Impartim cu 8 ca sa avem numarul de block uri

    mov %eax, blocks # cate block uri ne trebuie

    skip_here_coming_from_defragmentation:
    
    mov $-1, index_row
    mov $0, free_blocks # cate block uri avem libere intr-un streak
    mov saved_index_for_add_from_defrag, %ebx # folosim ebx ca index

    mov idFisier, %eax
    movb $1, used(, %eax, 1)

    for_loop_add: # Functie pentru verifcare de goluri
        # Sa ai grija ca poate nu e loc ???
        cmp n, %ebx
        je not_enough_memory

        call restart_new_line

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

not_enough_memory:

    add $8, %esp
    pushl idFisier
    pushl $notEnoughMemory
    call printf

    add $8, %esp
    jmp loop_add_function
restart_new_line:
    mov $0, %edx
    mov %ebx, %eax
    mov columns, %ecx

    div %ecx

    cmp $0, %edx
    jne skip_if_remainder_is_not_zero
    
    inc index_row
    mov $0, free_blocks

    skip_if_remainder_is_not_zero:

    ret 

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
    
    mov %ebx, saved_index_for_add_from_defrag
    inc saved_index_for_add_from_defrag
    
    sub free_blocks, %ebx # ebx is the index
    inc %ebx

    movl %ebx, from

    call get_column

    pushl idFisier
    pushl $afisareIdFisier
    call printf

    add $8, %esp

    pushl modulo_to

    mov $0, %edx
    mov %ebx, %eax

    mov columns, %ecx
    div %ecx

    mov %eax, index_row
    pushl index_row

    pushl modulo_from

    pushl index_row
    pushl $print2dCord
    call printf

    add $20, %esp

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


get_column:

    mov $0, %edx
    mov from, %eax

    mov columns, %ecx

    div %ecx

    mov %edx, modulo_from

    mov $0, %edx
    mov to, %eax

    div %ecx

    mov %edx, modulo_to

    ret 
# DO NOT TOUCH THIS IS ADD
# <---------------------------------------------------------------------------------------------------->
get_column_getFunction:
    mov %ecx, save

    mov $0, %edx
    mov from, %eax

    mov columns, %ecx

    div %ecx

    mov %edx, modulo_from

    mov $0, %edx
    mov to, %eax

    div %ecx

    mov %edx, modulo_to


    mov save, %ecx
    ret 

increase_index_row_get:
    mov $0, %edx
    mov %ecx, %eax

    mov %ecx, save

    mov columns, %ecx

    div %ecx
    
    cmp $0, %edx
    jne skip_if_remainder_is_zero_get

    inc index_row
    skip_if_remainder_is_zero_get:

    mov save, %ecx

    ret

citire_fisier_get: # Aici se citeste care fisier vrem sa il cautam
    pushl $idFisier
    call readNumber_function

    add $4, %esp



get_function:
    mov $-1, index_row
    mov $0, %ecx
    mov $-1, from
    mov $-1, to

    get_function_for_loop:
        cmp n, %ecx
        je for_is_done # Comparam daca ajungem la sfarsit

        call increase_index_row_get

        mov $0, %eax
        movb a(%ecx, 1), %al # Punem in eax ce fisier se afla la pozitia ecx

        cmp idFisier, %eax # Daca gasim fisierul sarim sa dam update la interval 
        je update_interval

        done_update_from:
        inc %ecx
        jmp get_function_for_loop
    
    update_interval:
        mov index_row, %edx
        mov %edx, saved_index_row_get

        mov %ecx, to # Dam update la ultimul capat
        mov %ecx, saved_to # Dam update la ultimul capat (folosit pentru 2D)
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
        mov $0, index_row
        mov $0, saved_index_row_get

    printInterval: # Printam intervalul
        call get_column_getFunction
        pushl modulo_to
        pushl saved_index_row_get

        pushl modulo_from
        
        pushl saved_index_row_get
        pushl $print2dCord

        call printf

        add $20, %esp
        
        pushl $0
        call fflush

        add $4, %esp

    
    mov saved_to, %ebx
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
    mov idFisier, %eax

    movb $0, used(, %eax, 1)

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

# <---------------------------------------------------------------> this is defragmentation
defragmentation_function:
    mov $1, comingFromDefragmentation
    mov $0, %ebx

    pushl %ebx
    call get_operations
    popl %ebx
    
    for_loop_defragmentation_function:
        cmp $256, %ebx
        je done_for_loop_defragmentation_function

        mov $0, %eax
        movb operations(%ebx, 1), %al

        mov %ebx, save_for_defrag_function

        cmp $0, %eax
        je skip_compare_defragmentation_function

        # I SHOULD JUMP TO ADD FUNCTION
        mov %eax, idFisier

        mov $0, blocks

        call get_blocks_value
        
        
    
        jmp skip_here_coming_from_defragmentation

        skip_compare_defragmentation_function:
        
        mov save_for_defrag_function, %ebx
        inc %ebx
        jmp for_loop_defragmentation_function


    done_for_loop_defragmentation_function:
    mov $0, comingFromDefragmentation
    jmp manage_queries    

get_blocks_value:
    mov $0, %edx
    for_get_blocks_value:
        cmp n, %edx
        je done_for_get_blocks_value
        
        mov $0, %eax
        movb a(%edx, 1), %al

        cmp idFisier, %eax
        jne skip_increase
        
        inc blocks
        movb $0, a(%edx, 1)
        skip_increase:
        inc %edx
        jmp for_get_blocks_value

    done_for_get_blocks_value:
    ret 
# <-----------------------------------------------------> this is defragmentation

print_memory:

    mov $0, %ebx
    print_loop:
        cmp n, %ebx
        je done_printing_memory

        mov %ebx, %eax
        mov $0, %edx
        
        mov columns, %ecx
        div %ecx
        
        cmp $0, %edx
        je print_new_line
        done_printing_new_line:

        mov $0, %eax
        movb a(%ebx, 1), %al

        pushl %eax
        pushl $printNumberNoEndl
        call printf
        
        pushl $0
        call fflush        

        add $12, %esp

        inc %ebx
        jmp print_loop

    print_new_line:
        push $new_line
        call printf

        add $4, %esp
        jmp done_printing_new_line
    done_printing_memory:
    ret 

# <---------------------------------------------------------------> THIS IS CONCRETE
concrete_function:
    mov $0, index_buffer 

    pushl $path
    pushl $formatScanfString


    call scanf 
    add $8, %esp 

    mov $1, comingFromConcrete

    mov $5, %eax 
    mov $path, %ebx 
    mov $0, %ecx
    mov $0, %edx

    int $0x80  


    mov %eax, %ebp 

    mov $141, %eax 
    mov %ebp, %ebx 
    mov $buffer, %ecx 
    mov $1024, %edx 


    int $0x80 

    mov %eax, bytesRead 

    mov $0, %ebx 

    for_loop_paths: 

        mov bytesRead, %eax 
        cmp %eax, index_buffer 
        

        je done_for_loop_buffer 
        
        mov $0, %edx
        
        mov index_buffer, %eax 

        add $8, %eax 
        movw buffer(, %eax, 1), %dx  


        add $2, %eax 

        mov $0, %ebx
        movb buffer(, %eax, 1), %bl

        

        cmp $'.', %bl 
        je skip_non_txt 

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx

        call concatenate_strings 
        call get_file_size_and_add_file 

        popl %edx
        popl %ecx
        popl %ebx
        popl %eax

        skip_non_txt:

        add %edx, index_buffer
        jmp for_loop_paths 

    done_for_loop_buffer:

    mov $0, comingFromConcrete
    jmp manage_queries

concatenate_strings:

    mov $0, %ecx
    for_loop_add_first_string: 

        mov $0, %edx
        movb path (, %ecx, 1), %dl 

        cmp $0, %edx 
        je done_for_loop_add_first_string

        mov $0, %edx 
        movb path(, %ecx, 1), %dl 
        movb %dl, file_path(, %ecx, 1) 

        inc %ecx # crestem indexul

        jmp for_loop_add_first_string
    done_for_loop_add_first_string:
    
    movb $'/', file_path(, %ecx, 1) 
    inc %ecx 

    for_loop_add_second_string: 
        mov $0, %edx 
        movb buffer(, %eax, 1), %dl 
        
        cmp $0, %edx 
        je done_for_loop_add_second_string 
        
        movb %dl, file_path(, %ecx, 1) 

        inc %eax 
        inc %ecx 

        jmp for_loop_add_second_string
    
    done_for_loop_add_second_string:

    movb $0, file_path(, %ecx, 1) 
    

    ret 

get_file_size_and_add_file:
    mov $5, %eax 
    mov $file_path, %ebx 
    mov $0, %ecx
    mov $0, %edx

    int $0x80 
    
    mov %eax, descriptor 

    mov $0, %edx

    mov $255, %ecx
    div %ecx

    add $1, %edx 

    mov %edx, idFisier 

    mov $19, %eax 
    mov descriptor, %ebx 
    mov $0, %ecx
    mov $2, %edx

    int $0x80 

  

    mov $0, %edx
    mov $1024, %ecx 

    div %ecx 
    
    mov %eax, dimensiuneFisierConcrete

    add $7, %eax
    mov $0, %edx
    mov $8, %ecx

    div %ecx 

    mov %eax, blocks 

    pushl dimensiuneFisierConcrete
    pushl idFisier
    pushl $afisareDescriptorDimensiune
    call printf

    add $12, %esp 

    mov $0, %ecx
    mov idFisier, %edx
    movb used (, %edx, 1), %cl 

    movb $1, used (, %edx, 1)

    cmp $1, %ecx 
    je file_exists

    jmp skip_here_coming_from_defragmentation


    done_add_file_concrete:
    ret

file_exists: 
    
    pushl idFisier
    pushl $notEnoughMemory
    call printf
    add $8, %esp

    jmp done_add_file_concrete

# AICI SE TERMINA CONCRETE UL

exit_program:
    pushl $0
    call fflush
    mov $1, %eax
    mov $0, %ebx
    int $0x80

# <-----------------------------------------------------------------> THESE ARE FUNCTIONS FOR OPERATIONS
add_to_operations:
    # NU UITA SA RESTAUREZI EBX
    mov $0, %ebx

    for_loop_add_to_operations:
        cmp $256, %ebx
        je done_for_loop_add_to_operations

        mov $0, %eax
        movb operations(%ebx, 1), %al

        cmp $0, %eax
        je add_file_to_operations
        inc %ebx
        jmp for_loop_add_to_operations

    add_file_to_operations:
        movl 4(%esp), %eax
        movb %al, operations(%ebx, 1)

    done_for_loop_add_to_operations:
    ret 

remove_from_operations:
    # NU UITA SA RESTAUREZI EBX
    mov $0, %ebx

    for_loop_remove_from_opeations:
        cmp $256, %ebx
        je done_for_loop_remove_from_operations

        mov $0, %eax
        movb operations(%ebx, 1), %al

        cmp idFisier, %eax
        je remove_file_from_operations

        inc %ebx
        jmp for_loop_remove_from_opeations

    remove_file_from_operations:
        movb $0, operations(%ebx, 1)
    done_for_loop_remove_from_operations:
    ret

defragmentation_on_operations:
    mov $0, %ecx
    mov $0, %ebx

    for_loop_defragmentation_on_operations:
        cmp $256, %ebx
        je done_for_loop_defragmentation_on_operations

        mov $0, %eax
        movb operations(%ebx, 1), %al

        cmp $0, %eax
        jne swap_elements_from_operations

        done_swapping_elements_from_operations:
        inc %ebx
        jmp for_loop_defragmentation_on_operations

    
    swap_elements_from_operations:
        mov $0, %eax
        movb operations(%ecx, 1), %al

        mov $0, %edx
        movb operations(%ebx, 1), %dl

        movb %al, operations(%ebx, 1)
        movb %dl, operations (%ecx, 1)

        inc %ecx
        jmp done_swapping_elements_from_operations

    done_for_loop_defragmentation_on_operations:
    ret 

get_operations:
    mov $0, %ebx
    mov $0, %ecx

    for_delete_operations:
        cmp $256, %ebx
        je done_for_delete_operations
        
        movb $0, operations(%ebx, 1)
        inc %ebx
        jmp for_delete_operations
    done_for_delete_operations:

    mov n, %ebx
    dec %ebx
    for_put_first:
        cmp $-1, %ebx
        je done_for_put_first

        mov $0, %eax
        movb a(%ebx, 1), %al
        movb %al, operations

        dec %ebx
        jmp for_put_first
    done_for_put_first:

    mov $0, %ebx
    mov $0, %ecx

    for_get_operations:
        cmp n, %ebx
        je done_for_get_operations
        
        mov $0, %eax
        movb a(%ebx, 1), %al

        cmp $0, %eax
        je go_to_increase

        mov $0, %edx
        movb operations(%ecx, 1), %dl

        cmp %edx, %eax
        je go_to_increase        

        inc %ecx
        movb %al, operations(%ecx, 1)
        go_to_increase:

        inc %ebx
        jmp for_get_operations
    done_for_get_operations:
    ret 

delete_matrix:
    mov $0, %ebx
    
    for_loop_delete_matrix:
        cmp n, %ebx
        je done_for_loop_delete_matrix

        movb $0, a(%ebx, 1)
    
        inc %ebx
        jmp for_loop_delete_matrix
    
    done_for_loop_delete_matrix:
    ret

print_operations:
    mov $0, %ebx
    
    for_print_operations:
        cmp $5, %ebx
        je done_for_print_operations


        movb operations(%ebx, 1), %al
        pushl %eax
        pushl $printNumber
        call printf

        add $8, %esp

        inc %ebx
        jmp for_print_operations

    done_for_print_operations:
    ret