    addi sp, zero, 0
    addi t0, zero, 5
    sw t0, (0)sp
    addi t0, zero, 4
    sw t0, (4)sp
    addi t0, zero, 7
    sw t0, (8)sp
    addi t0, zero, 2
    sw t0, (12)sp
    addi t0, zero, 8
    sw t0, (16)sp
    addi t0, zero, 11
    sw t0, (20)sp
    addi t0, zero, 3
    sw t0, (24)sp
    addi t0, zero, 15
    sw t0, (28)sp
    addi t0, zero, 6
    sw t0, (32)sp
    addi t0, zero, 9
    sw t0, (36)sp
    addi t0, zero, 12
    sw t0, (40)sp
    addi t0, zero, 20
    sw t0, (44)sp
    addi t0, zero, 10
    sw t0, (48)sp
    addi t0, zero, 13
    sw t0, (52)sp
    addi t0, zero, 5
    sw t0, (56)sp
    addi t0, zero, 0
    sw t0, (60)sp
    addi t0, zero, 2
    sw t0, (64)sp
    addi t0, zero, 3
    sw t0, (68)sp
    addi t0, zero, 4
    sw t0, (72)sp
    addi t0, zero, 8
    sw t0, (76)sp


    add s0, zero, zero // max_inedx
    lw t0, (0)sp
    add s1, t0, zero // max

    addi s2, zero, 1 // i
    addi s3, zero, 4 // 4*i

begin_for:
    slti t0, s2, 20
    beq t0, zero, end_for
    add t0, sp, s3
    lw t1, 0(t0)
    slt t0, s1, t1
    beq t0, zero, end_if
    add s1, zero, t1
    add s0, zero, s2
end_if:
    addi s2, s2, 1
    addi s3, s3, 4
    jal ra, begin_for
end_for:
