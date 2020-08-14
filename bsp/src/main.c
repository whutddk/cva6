#include "uart.h"
#include "gpio.h"

int main()
{
	uart_init();
    // while(1)
    // {
		// print_uart("Wuhan University of Technology, 666!\r\n");
    // }

	print_uart("Wuhan University of Technology, 666!\r\n");
	print_uart("Wuhan University of Technology, 666!\r\n");

	gpio_write( 0xffffffff );



	// print_uart("Program End!\r\n");

	while(1)
	{
		
	}

}

void handle_trap(void)
{
    // print_uart("trap\r\n");
}