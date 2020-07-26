#include "uart.h"


int main()
{
    init_uart(30000000, 115200);
    print_uart("Hello World!\r\n");

    // jump to the address
    __asm__ volatile(
        "li s0, 0x80000000;"
        "la a1, _dtb;"
        "jr s0");

}

void handle_trap(void)
{
    // print_uart("trap\r\n");
}