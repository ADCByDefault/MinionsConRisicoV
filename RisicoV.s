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
    
    li a0 65
    jal link
    li a0 66
    jal link
    li a0 67
    jal link
    li a0 68
    jal link
    li a0 69
    jal link
    #exit
    li a7 10
    ecall
    
    
#add to tail
#a0 byte to add
link:
    #carico indirizzo di e indirizzo puntato da free_space
    la t0 free_space
    lw t1 free_space
    #if tail == null nessun nodo precedente 
    #quindi nessun nodo da far puntare al nuovo nodo
    lw t2 tail
    beq zero t2 link_skip_tail_null
    sw t1 1(t2)
    link_skip_tail_null:
    #tail = attuale indirizzo puntato da free_space
    la t2 tail
    sw t1 0(t2)
    #length++
    lw t3 length
    addi t3 t3 1
    sw t3 8(t2)
    #salvo byte e incremento di 1 indirizzo puntato da free_space
    sb a0 0(t1)
    addi t1 t1 1
    #nuovo nodo punta a null e indirizzo puntato da free_space += 4
    sw zero 0(t1)
    addi t1 t1 4
    #salvo nuovo indirizzo libero in free_space
    sw t1 0(t0)
    #se head == null allora head = nodo appena creato
    lw t3 head
    bne zero t3 link_return
    la t3 head
    addi t1 t1 -5
    sw t1 0(t3)
    link_return:
    jr ra