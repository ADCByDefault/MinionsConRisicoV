.data
sp: .word 0x0ffffffc
input: .string "ADD(1)"
tail: .word 0x0
head: .word 0x0
length: .word 0x0
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
    
    jal find_free_space
    li a0 65
    jal add
    jal find_free_space
    li a0 66
    jal add
    jal find_free_space
    li a0 67
    jal add
    jal find_free_space
    li a0 67
    jal add
    jal find_free_space
    li a0 69
    jal add
    jal find_free_space
    li a0 69
    jal add
    jal find_free_space
    li a0 69
    jal add
    jal find_free_space
    li a0 72
    jal add
    jal find_free_space
 
    lw a1 0(s0)
    jal print
    
    li a0 65
    jal del
    li a0 69
    jal del
    jal del
    
    jal rev
    jal new_line
    lw a1 0(s0)
    jal print
    #exit
    li a7 10
    ecall
    

#a0 = byte da eliminare
del:
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
    
rev:
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
add:
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
print:
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