

a = b + c

mov r0, 0
add r0, b
add r0, c
mov a, r0




a = (b + c) + (d + e)

# integer or identifier
push b
# integer or identifier
push c
# expression
add [esp+0x4], [esp]
pop ...

# integer or identifier
push d
# integer or identifier
push e
# expression
add [esp+0x4], [esp]
pop ...

#expression
add [esp+0x4], [esp]

