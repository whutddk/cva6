// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

#include "string_lib.h"
#include "gpio.h"
#include "uart.h"

int main()
{
  //char c = 'b';
  uart_set_cfg(0,26);
  //set_gpio_pin_direction(10, DIR_OUT);
  //set_pin_function(10, FUNC_GPIO);
  //set_gpio_pin_value(10, 1);
  while (1) {
  	uart_sendstr("hello world!");
  }
}
