#include "uart.h"
#include "gpio.h"

int main()
{
    init_uart(30000000, 115200);

    // while(1)
    // {
		// print_uart("Wuhan University of Technology, 666!\r\n");
    // }

	// print_uart("Wuhan University of Technology, 666!\r\n");
	// print_uart("Wuhan University of Technology, 666!\r\n");

	gpio_write( 0xffffffff );

	gpio_test();

	// print_uart("Program End!\r\n");

	while(1)
	{
		gpio_write( 0xffffffff );
	}

}

void handle_trap(void)
{
    // print_uart("trap\r\n");
}