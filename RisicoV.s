.data
sp: .word 0x0ffffffc
input: .string "ADD(1)"
tail: .word 0x0
head: .word 0x0
length: .word 0x0
lunghezza_buffer1: .byte 0
buffer1: .zero 100
lunghezza_buffer2: .byte 0
buffer2: .zero 100
free_space: .word 0x0

.text
.main:
    #s0 e s11 sono il head e tail della lista
    la s0 head
    la s11 tail
    la s1 free_space
    addi t0 s1 4
    sw t0 0(s1)
    la sp sp
    la s2 lunghezza_buffer1
    la s3 lunghezza_buffer2
    
    jal find_free_space
    li a0 65
    jal ADD
    jal find_free_space
    li a0 66
    jal ADD
    jal find_free_space
    li a0 67
    jal ADD
    jal find_free_space
    li a0 67
    jal ADD
    jal find_free_space
    li a0 69
    jal ADD
    jal find_free_space
    li a0 69
    jal ADD
    jal find_free_space
    li a0 69
    jal ADD
    jal find_free_space
    li a0 72
    jal ADD
    jal find_free_space
 
    lw a1 0(s0)
    jal PRINT
    
    li a0 65
    jal DEL
    li a0 69
    jal DEL
    jal DEL
    
    jal REV
    
    jal find_free_space
    li a0 76
    jal ADD
    jal find_free_space
    jal ADD
    jal find_free_space
    jal ADD
    jal find_free_space
    jal ADD
    jal find_free_space
    jal ADD
    jal find_free_space
    jal ADD
    jal find_free_space
    
    jal new_line
    lw a1 0(s0)
    jal PRINT
    
    jal DEL
    
    jal find_free_space
    
    jal new_line
    lw a1 0(s0)
    jal PRINT
    
    li a6 110
    li a7 77
    jal compare_chars
    mv a1 a6
    mv a2 a7
    #exit
    li a7 10
    ecall
    
SORT:
    #salvo ra
    lw t0 0(sp)
    sw ra 0(t0)
    addi t0 t0 -4
    sw t0 0(sp)
    #to_array nel buffer 1
    jal to_array
    la a0 buffer1
    li a1 0
    lw a2 lunghezza_buffer1
    addi a2 a2 -1
    jal merge_sort
    jal clear_buffer1
    jal clear_buffer2
    #recupero ra
    lw t0 0(sp)
    addi t0 t0 4
    lw ra 0(t4)
    sw t4 0(sp)
    sort_return:
    jr ra
    
# a6 char1, a7 char2 ritorna: a6 minore, a7 maggiore
compare_chars:
    #salvo ra in t6(non vinene usata da get_category)
    mv t6 ra
    #trovo categoria di a6 e metto risultato in t2
    mv a5, a6
    jal get_category
    mv t1, a5
    #trovo categoria di a7 e metto risultato in t3
    mv a5, a7
    jal get_category
    mv t2, a5
    #repristino ra
    mv ra t6
    #a6 categoria minore
    blt t1, t2, compare_chars_return
    #mv tp t1
    #a7 categoria minore
    bgt t1, t2, compare_chars_switch
    #se hanno la stessa categoria faccio confronto normale
    blt a6, a7, compare_chars_return
    compare_chars_switch:
    mv t0, a6
    mv a6, a7
    mv a7, t0
    compare_chars_return:
    jr ra
 
    
#a5 = carattere, restituisce in a5 la categoria:
#0 = extra, 1 = numero, 2 = minuscola, 3 = maiuscola
get_category:
    mv t0 a5
    #extra di default
    li a5, 0
    #se 48 <= c <= 57 allora numero
    li t3, 48
    li t2, 57
    blt t0, t3, get_category_return
    bgt t0, t2, get_category_check_lowercase
    li a5, 1
    jr ra
    get_category_check_lowercase:
    li t3, 97
    li t2, 122
    blt t0, t3, get_category_check_uppercase
    bgt t0, t2, get_category_return
    li a5, 2
    jr ra
    get_category_check_uppercase:
    li t3, 65
    li t2, 90
    blt t0, t3, get_category_return
    bgt t0, t2, get_category_return
    li a5, 3
    get_category_return:
    jr ra

    
#a0 indizzo base, a1 left, a2 right
merge_sort:
    #se left>=right allora return
    bge a1 a2 merge_sort_return
    #t0(mid) = (left+right)/2
    add t0 a1 a2
    srai t0 t0 1
    #salvo ra, left, right, mid
    lw t1 0(sp)
    sw ra 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    sw t0 12(sp)
    addi t1 t1 -16
    sw t1 0(sp)
    #chiamo merge_sort(a0, left, mid)
    mv a2 t0
    jal merge_sort
    #chiamo merge_sor(a0, mid+1, right)
    lw t1 0(sp)
    addi t1 t1 16
    lw a1 12(t1)
    addi a1 a1 1
    lw a2 8(sp)
    jal merge_sort
    #chiamo la funzione merge
    lw t1 0(sp)
    addi t1 t1 16
    lw a1 4(t1)
    lw a2 8(t1)
    lw a3 12(t1)
    la a4 buffer2
    jal merge
    #ricarico ra
    lw t1 0(sp)
    addi t1 t1 16
    lw ra 0(t1)
    sw t1 0(sp)
    merge_sort_return:
    jr ra
    
#a0 indirizzo base, a1 left, a2 right, a3 mid, a4 indirizzo base appoggio
merge:
    #t0 = left+base, t1 = mid+1+base, t2 = right+base
    add t0 a1 a0
    add t1 a3 a0
    addi t1 t1 1
    mv t3 t1
    add t2 a2 a0
    #t4 funge da i
    mv t4 a4
    merge_loop:
    #salvo tutte i registri per le funzioni di confronto gli modificano
    lw t5 0(sp)
    sw a0 0(t5)
    sw a1 4(t5)
    sw a2 8(t5)
    sw a3 12(t5)
    sw a4 16(t5)
    sw t0 20(t5)
    sw t1 24(t5)
    sw t2 28(t5)
    sw t3 32(t5)
    sw t4 36(t5)
    sw ra 40(t5)
    addi t5 t5 -44
    sw t5 0(sp)
    
    merge_back_to_loop:
    #ricarico tutti i registri
    lw t5 0(sp)
    addi t5 t5 44
    lw a0 0(t5)
    lw a1 4(t5)
    lw a2 8(t5)
    lw a3 12(t5)
    lw a4 16(t5)
    lw t0 20(t5)
    lw t1 24(t5)
    lw t2 28(t5)
    lw t3 32(t5)
    lw t4 36(t5)
    lw ra 40(t5)
    sw t5 0(sp)
    j merge_loop
    merge_add_from_left:
    #carico byte e aumento t0 (left)
    lbu t5 0(t0)
    addi t0 t0 1
    #salvo byte in buffer 2
    sb t5 0(t4)
    addi t4 t4 1
    j merge_loop
    merge_add_from_right:
    #carico byte
    lbu t5 0(t1)
    addi t1 t1 1
    #salvo byte
    sb t5 0(t4)
    addi t4 t4 1
    j merge_loop
    merge_copy_back_to_buffer1:
    
    merge_return:
    jr ra
    
#buffer1 viene riempito in ordine con i dati della linked list
to_array:
    lw t0 0(s0)
    la t1 buffer1
    to_array_loop:
    #se t0 == null allora return
    beq zero t0 to_array_return
    #carico byte e puntatore al prossio nodo
    lbu t2 0(t0)
    lw t0 1(t0)
    sb t2 0(t1)
    addi t1 t1 1
    j to_array_loop
    to_array_return:
    #salvo lunghezza array e return
    la t2 buffer1
    sub t1 t1 t2
    la t2 lunghezza_buffer1
    sb t1 0(t2)
    jr ra

clear_buffer1:
    la t0 lunghezza_buffer1
    sw zero 0(t0)
    la t0 buffer1
    addi t1 t0 100
    bge t0 t1 clear_buffer1_return
    sw zero 0(t0)
    addi t0 t0 4
    clear_buffer1_return:
    jr ra

clear_buffer2:
    la t0 lunghezza_buffer2
    sw zero 0(t0)
    la t0 buffer2
    addi t1 t0 100
    bge t0 t1 clear_buffer2_return
    sw zero 0(t0)
    addi t0 t0 4
    clear_buffer2_return:
    jr ra

#a0 = byte da eliminare
DEL:
    #t0 = nodo padre, t1 = nodo attuale
    li t0 0
    lw t1 0(s0)
    del_loop:
    #puntatore al nodo attuale == null allora return
    beq zero t1 del_return
    lbu t2 0(t1)
    bne t2 a0 del_continue
    #lunghezza lista += -1
    lw t4 8(s11)
    addi t4 t4 -1
    sw t4 8(s11)
    beq zero t0 del_del_head
    #nodo puntato dal padre = nodo puntato da attuale
    lw t3 1(t1)
    sw t3 1(t0)
    j del_clear_mem_tail_check
    del_del_head:
    #head = prossimo nodo
    lw t3 1(t1)
    sw t3 0(s0)
    del_clear_mem_tail_check:
    #azzero i 5 byte occupati dal nodo, cosi che vengano riusati
    sw zero 0(t1)
    sw zero 1(t1)
    #attuale = prossimo
    mv t1 t3
    #se t1 è null bisogna aggiornare tail e fine funzione
    bne zero t1 del_loop
    sw t0 0(s11)
    j del_return
    del_continue:
    # puntatore al padre = attuale, puntatore attuale = prossimo
    mv t0 t1
    lw t1 1(t1)
    j del_loop
    del_return:
    jr ra
    
REV:
    #return se lista è vuota
    lw t0 0(s0)
    beq zero t0 rev_return
    #carico head e sp
    lw t1 0(s0)
    lw t2 0(sp)
    #tail = head e salvo puntatore di tail in t4
    lw t4 0(s11)
    sw t1 0(s11)
    rev_stackup_loop:
    #if attuale puntatore == null fine loopyy
    #salvo attuale puntatore e carico quello del prossimo nodo
    sw t1 0(t2)
    addi t2 t2 -4
    lw t1 1(t1)
    bne zero t1 rev_stackup_loop
    #carico head (e lo aggiorno) e ultimo puntatore
    sw t4 0(s0)
    lw t1 1(t0)
    sw zero 1(t0)
    #sincronizzo t1 e t0 e riparto da capo per assegnare
    #al contrario gli indirizzi ai nodi
    mv t0 t1
    lw t2 0(sp)
    rev_rev_loop:
    lw t3 0(t2)
    lw t1 1(t0)
    sw t3 1(t0)
    mv t0 t1
    addi t2 t2 -4
    bne zero t0 rev_rev_loop
    rev_return:
    jr ra
    

#aggiunta in coda
#a0 byte da aggiungere
ADD:
    #carico indirizzo puntato da free_space
    lw t1 free_space
    #if tail == null nessun nodo precedente 
    #quindi nessun nodo da far puntare al nuovo nodo
    lw t2 tail
    beq zero t2 add_skip_tail_null
    sw t1 1(t2)
    add_skip_tail_null:
    #tail = attuale indirizzo puntato da free_space
    la t2 tail
    sw t1 0(t2)
    #length++
    lw t3 length
    addi t3 t3 1
    sw t3 8(t2)
    #salvo byte e puntatore a null
    sb a0 0(t1)
    sw zero 1(t1)
    #se head == null allora head = nodo appena creato
    lw t3 head
    bne zero t3 add_return
    la t3 head
    sw t1 0(t3)
    add_return:
    jr ra
    
#a1= nodo da qui iniziare a stampare
#se a1 = null (lista vuota) stampa ø
PRINT:
    beq zero a1 print_null
    print_ricorsive:
    #se a1 == null return
    beq zero a1 print_return
    #salvo ra in sp e aggiorno quest'ultimo
    lw t0 0(sp)
    sw ra 0(t0)
    addi t0 t0 -4
    sw t0 0(sp)
    #carico il nodo
    lbu a0 0(a1)
    lw a1 1(a1)
    #stampo e chiamo print sul prossimo nodo
    li a7 11
    ecall
    jal print_ricorsive
    #carico ra da sp e aggiorno quest'ultimo
    lw t0 0(sp)
    addi t0 t0 4
    lw ra 0(t0)
    sw t0 0(sp)
    print_return:
    jr ra
    print_null:
    li a0 248
    li a7 11
    ecall
    j rev_return
    
#viene aggiornata la word free_space con puntatore alla
#alla prima cella di prime 5 celle che hanno solo 0x0
#a partire dal indirizzo di memoria di free_space
#cercando a blocchi di 5, metodo presenta criticità.
find_free_space:
    la t0 free_space
    mv t1 t0
    find_free_space_loop:
    lb t2 0(t1)
    lw t3 1(t1)
    addi t1 t1 5
    bne zero t2 find_free_space_loop
    bne zero t3 find_free_space_loop
    addi t1 t1 -5
    sw t1 0(t0)
    jr ra

#trova spazio per un array di 100byte scandagliando ogni 100byte
find_free_space_array:
    
#spampa /n per differenziare da una stampa all'altra
new_line:
    li a0 10
    li a7 11
    ecall
    jr ra
print_length:
    lw a0 8(s11)
    li a7 1
    ecall
    jr ra