.global _start
_start:

app:
    bl main_screen

    cmp r3, #2
    beq status_path
    b measure_path


status_path:
    bl sensor_ok_screen

    cmp r3, #1
    beq end

measure_path:
    bl measurement_type_screen

    cmp r3, #1
    beq temperature_measure_path
    b humidity_measure_path


temperature_measure_path:
    bl measurement_screen

    cmp r3, #1
    beq temp_normal
    b temp_cont

    temp_normal:
        bl temperature_screen
        cmp r3, #1
        beq end

    temp_cont:
        bl cont_temperature_screen
        cmp r3, #1
        beq temp_normal

humidity_measure_path:
    bl measurement_screen

    cmp r3, #1
    beq humi_normal
    b humi_cont

    humi_normal:
        bl humidity_screen
        cmp r3, #1
        beq end

    humi_cont:
        bl cont_humidity_screen
        cmp r3, #1
        beq humi_normal

@ printar
print:
    mov r0, #1
    mov r7, #4
    svc 0

    bx lr

main_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =status
    mov r2, #14
    bl print

    ldr r1, =measure
    mov r2, #15
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

status_screen:
    ldr r1, =status
    bl print

measurement_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =current_measure
    mov r2, #16
    bl print

    ldr r1, =continuous_measure
    mov r2, #17
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

measurement_type_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =temperature_measure
    mov r2, #16
    bl print

    ldr r1, =humidity_measure
    mov r2, #16
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

cont_humidity_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =humidity
    mov r2, #8
    bl print

    ldr r1, =stop_continuous
    mov r2, #14
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

cont_temperature_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =temperature
    mov r2, #8
    bl print

    ldr r1, =stop_continuous
    mov r2, #14
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

humidity_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =humidity
    mov r2, #8
    bl print

    ldr r1, =back_menu
    mov r2, #15
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

temperature_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =temperature
    mov r2, #8
    bl print

    ldr r1, =back_menu
    mov r2, #15
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

sensor_not_ok_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =sensor_not_ok
    mov r2, #14
    bl print

    ldr r1, =back_menu
    mov r2, #15
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

sensor_ok_screen:
    sub sp, sp, #4
    str lr, [sp]

    ldr r1, =sensor_ok
    mov r2, #10
    bl print

    ldr r1, =back_menu
    mov r2, #15
    bl print

    ldr lr, [sp]
    add sp, sp, #4

    mov r3, #1
    bx lr

end: @fechar o processo
    mov r0, #0
    mov r7, #1

    svc 0

.data 
value: .ascii "helloworld\n"
status: .ascii "1.Status Req.\n"
measure: .ascii "2.Measure Req.\n"
current_measure: .ascii "1.Current Measu.\n"
continuous_measure: .ascii "2.Contin. Measu.\n"
temperature_measure: .ascii "1.Temp. Measure\n"
humidity_measure: .ascii "2.Humi. Measure\n"
temperature: .ascii "T:21.0C\n"
humidity: .ascii "H:45.0%\n"
back_menu: .ascii "1.Back to Menu\n"
stop_continuous: .ascii "1.Stop conti.\n"
sensor_ok: .ascii "Sensor OK\n"
sensor_not_ok: .ascii "Sensor not OK\n"
