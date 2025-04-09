.data
sp: .word 0x10000000
input: .string "ADD(1) "
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
    li a0 68
    jal add
    
    jal find_free_space
    li a0 69
    jal add
    jal find_free_space
    #exit
    li a7 10
    ecall
    
    
#add to tail
#a0 byte to add
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
    
#a1= puntatore a head
print:
    beq zero a1 print_return
    lb t0 0(a1)
    lw t1 1(a1)
    print_return:
    jr ra
    
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
    
    