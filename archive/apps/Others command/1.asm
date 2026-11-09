    lui s0, 498043 // 498043 = 01111001100101111011
    addi s1, zero, 692
    addi s2, zero, 1832
    add s3, s1, s2
    sub s4, s1, s2
    sub s5, s2, s1
    ori s0, s0, 310 // 310 = 000100110110
    lui s6, 171699 // 171699 = 00101001111010110011
    ori s6, s6, 294 // 294 = 000100100110
    and s1, s0, s6
    or s2, s6, s0
    addi t0, zero, -8
    jalr ra, t0, 64
    addi t1, zero, 88
    bne t0, t1, jj
    addi t3, zero, 932
    addi t4, zero, 1913
jj:
    addi t5, zero, 897
