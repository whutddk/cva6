// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

#include "utils.h"
#include "uart.h"
#include "int.h"
#include "uart.h"
#include "pulpino.h"

Uart_t uart;
/**
 * Setup UART. The UART defaults to 8 bit character mode with 1 stop bit.
 *
 * parity       Enable/disable parity mode
 * clk_counter  Clock counter value that is used to derive the UART clock.
 *              It has to be in the range of 1..2^16.
 *              There is a prescaler in place that already divides the SoC
 *              clock by 16.  Since this is a counter, a value of 1 means that
 *              the SoC clock divided by 16*2 = 32 is used. A value of 31 would mean
 *              that we use the SoC clock divided by 16*32 = 512.
 */
void uart_set_cfg(int parity, uint16_t clk_counter) {
  // unsigned int i;
  // CGREG |= (1 << CGUART); // don't clock gate UART
  *(volatile unsigned int*)(UART_REG_LCR) = 0x83; //sets 8N1 and set DLAB to 1
  *(volatile unsigned int*)(UART_REG_DLM) = (clk_counter >> 8) & 0xFF;
  *(volatile unsigned int*)(UART_REG_DLL) =  clk_counter       & 0xFF;
  *(volatile unsigned int*)(UART_REG_FCR) = 0xA7; //enables 16byte FIFO and clear FIFOs
  *(volatile unsigned int*)(UART_REG_LCR) = 0x03; //sets 8N1 and set DLAB to 0

  ///TODO: disable interrupt?
  *(volatile unsigned int*)(UART_REG_IER) = ((*(volatile unsigned int*)(UART_REG_IER)) & 0xF0) | 0x02; // set IER (interrupt enable register) on UART
}

void uart_set_cfg_without_fifo(int parity, uint16_t clk_counter) {
  // unsigned int i;
  // CGREG |= (1 << CGUART); // don't clock gate UART
  *(volatile unsigned int*)(UART_REG_LCR) = 0x83; //sets 8N1 and set DLAB to 1
  *(volatile unsigned int*)(UART_REG_DLM) = (clk_counter >> 8) & 0xFF;
  *(volatile unsigned int*)(UART_REG_DLL) =  clk_counter       & 0xFF;
  *(volatile unsigned int*)(UART_REG_FCR) = 0x00; //0xA7; //enables 16byte FIFO and clear FIFOs
  *(volatile unsigned int*)(UART_REG_LCR) = 0x03; //sets 8N1 and set DLAB to 0

  ///TODO: disable interrupt?
  *(volatile unsigned int*)(UART_REG_IER) = 0;//((*(volatile unsigned int*)(UART_REG_IER)) & 0xF0) | 0x02; // set IER (interrupt enable register) on UART
}
void uart_set_cfg_int() {
  // unsigned int i;
  // CGREG |= (1 << CGUART); // don't clock gate UART
  *(volatile unsigned int*)(UART_REG_LCR) = 0x83; //sets 8N1 and set DLAB to 1
  *(volatile unsigned int*)(UART_REG_DLM) = (uart.buad_div >> 8) & 0xFF;
  *(volatile unsigned int*)(UART_REG_DLL) =  uart.buad_div & 0xFF;
   //enables 64bytes FIFO and clear FIFOs, RX trigger if received 32bytes in FIFO
  *(volatile unsigned int*)(UART_REG_FCR) = 0xA7;
  *(volatile unsigned int*)(UART_REG_LCR) = 0x03; //sets 8N1 and set DLAB to 0

  uint8_t ier = 0;
  if (uart.ien_RDA || uart.ien_CTI)
    ier |= 1;
  //if (uart.ien_THR)
  //  ier |= 1<<1;
  if (uart.ien_RLS)
    ier |= 1<<2;
  if (uart.ien_MSR)
    ier |= 1<<3;
  ///TODO: disable interrupt?
  *(volatile unsigned int*)UART_REG_IER |= ier; // set IER (interrupt enable register) on UART
  IER |= (1<<24); // enable UART interrupt
}

void uart_cfg_int(uint16_t buad_div, uint8_t rda_en, uint8_t cti_en, uint8_t thr_en, uint8_t rls_en, uint8_t msr_en)
{
  uart.buad_div = buad_div;
  uart.ien_RDA = rda_en == 0 ? 0 : 1;
  uart.ien_CTI = cti_en == 0 ? 0 : 1;
  uart.ien_THR = thr_en == 0 ? 0 : 1;
  uart.ien_RLS = rls_en == 0 ? 0 : 1;
  uart.ien_MSR = msr_en == 0 ? 0 : 1;
  uart.rx_widx = uart.rx_ridx = uart.rx_count = 0;
  uart.tx_widx = uart.tx_ridx = uart.tx_count = 0;
  uart.recv_droped = 0;
  uart_set_cfg_int();
}

void uart_start_send()
{
  // *(volatile unsigned int*)(UART_REG_LCR) = 0x03; //sets 8N1 and set DLAB to 0
  *(volatile unsigned int*)(UART_REG_IER) |= 0x2; // set IER (interrupt enable register) on UART
}

int uart_send_int(const uint8_t* buf, uint16_t len)
{
  uint16_t send_cnt = 0;
  uint16_t wlen;
  uint16_t tx_widx;
  uint16_t tx_ridx;
  uint16_t tx_count;
  if (uart.ien_THR) {
    while(len > send_cnt) {
      tx_widx = uart.tx_widx;
      int_disable();
      tx_count = uart.tx_count;
      tx_ridx = uart.tx_ridx;
      int_enable();
      if (tx_count < SERIAL_TX_BUFFER_SIZE) {
        if(tx_widx >= tx_ridx) {
          wlen = (len - send_cnt) < (SERIAL_TX_BUFFER_SIZE - tx_widx) ? (len - send_cnt) : SERIAL_TX_BUFFER_SIZE - tx_widx;
        } else {
          wlen = (len - send_cnt) < (tx_ridx - tx_widx) ? (len - send_cnt) : tx_ridx - tx_widx;
        }
        m_memcpy(&uart.tx_buf[tx_widx], (uint8_t*)&buf[send_cnt], wlen);
        send_cnt += wlen;
        // len -= wlen;
        // tx_count += wlen;
        tx_widx += wlen;
        if (tx_widx == SERIAL_TX_BUFFER_SIZE)
          tx_widx = 0;
        int_disable();
        uart.tx_count += wlen;
        uart.tx_widx = tx_widx;
        int_enable();
      } else {
        uart_start_send();
        return send_cnt;
      }
    }
    uart_start_send();
    return send_cnt;
  } else {
    uart_send((const char*)buf, len);
    return len;
  }
}

int uart_recv_int(uint8_t* buf, uint16_t size)
{
  uint16_t cnt = 0;
  uint16_t rlen;
  uint16_t rx_ridx;
  uint16_t rx_count;
  uint16_t rx_widx;
  if (uart.ien_CTI == 1 || uart.ien_RDA == 1) {
    while(size > cnt) {
      rx_ridx = uart.rx_ridx;
      int_disable();
      rx_count = uart.rx_count;
      rx_widx = uart.rx_widx;
      int_enable();
      if (rx_count == 0)
        return cnt;

      if (rx_ridx < rx_widx) {
        rlen = (size - cnt) < rx_widx - rx_ridx ? (size - cnt) : rx_widx - rx_ridx;
      } else {
        rlen = (size - cnt) < SERIAL_RX_BUFFER_SIZE - rx_ridx ? (size - cnt) : SERIAL_RX_BUFFER_SIZE - rx_ridx;
      }
      m_memcpy(&buf[cnt], &uart.rx_buf[rx_ridx], rlen);

      cnt += rlen;
      // rx_count -= rlen;
      rx_ridx += rlen;
      if (rx_ridx == SERIAL_RX_BUFFER_SIZE)
        rx_ridx = 0;
      int_disable();
      uart.rx_count -= rlen;
      uart.rx_ridx = rx_ridx;
      int_enable();
    }
    return cnt;
  } else {
    while(size > cnt) {
      buf[cnt++] = uart_getchar();
    }
    return cnt;
  }
}

__attribute__((weak))
void ISR_UART(void)
{
  // while (1) {
    uint8_t iir = (*(volatile int*)UART_REG_IIR) & 0x0F;
    // printf("IIR: 0x%02x\n", iir);
    ICP |= (1<<24); //clear pending UART interrupt
    switch(iir) {
      case IIR_RDA:
        for (int i = 0; i < 32; ++i) {
          if (uart.rx_count < SERIAL_RX_BUFFER_SIZE) {
            uart.rx_buf[uart.rx_widx++] = *(volatile int*)UART_REG_RBR;
            uart.rx_widx &= 0x01FF;
            uart.rx_count++;
          } else {
            break;
          }
        }
        // break;
      case IIR_CTI:
        // printf("LSR: 0x%02X, count: %d, %c\n", *LSR_UART, uart.rx_count, uart.rx_buf[uart.rx_widx == 0 ? 0 : uart.rx_widx-1]);
        while (((*LSR_UART) & 0x1) && (uart.rx_count < SERIAL_RX_BUFFER_SIZE)) {
          uart.rx_buf[uart.rx_widx++] = *(volatile int*)UART_REG_RBR;
          uart.rx_widx &= 0x01FF;
          uart.rx_count++;
        }
        break;
      case IIR_THR:
        if(uart.tx_count == 0) {
          *(volatile int*)UART_REG_IER &= (~0x2);
          break;
        }
        // if ((*(volatile int*)UART_REG_LSR) & 0x40) {
          for (int i = 0; i < 64; ++i) //FIFO depth is 64 bytes
          {
            if ((((*(volatile int*)UART_REG_LSR) & 0x60)) && (uart.tx_count > 0))
            {
              *(volatile int*)UART_REG_THR = uart.tx_buf[uart.tx_ridx++];
              uart.tx_ridx &= 0x01FF;
              uart.tx_count--;
              if (uart.tx_count == 0) {
                *(volatile int*)UART_REG_IER &= (~0x2);
                break;
              }
            } else {
              if (uart.tx_count == 0) {
                *(volatile int*)UART_REG_IER &= (~0x2);
              }
              break;
            }
          }
        // } else if ((*(volatile int*)UART_REG_LSR) & 0x20) {
        //   *(volatile int*)UART_REG_THR = uart.tx_buf[uart.tx_ridx++];
        //     uart.tx_ridx &= 0x01FF;
        //     uart.tx_count--;
        //     if (uart.tx_count == 0) {
        //       *(volatile int*)UART_REG_IER &= (~0x2);
        //     }
        // }
        break;
      case IIR_RLS:
        if ((*(volatile int*)UART_REG_LSR) & 0x02)
          uart.recv_droped++;
        break;
      case IIR_MSR:

        break;
      default:
        return;
    }
  // }
}

void uart_send(const char* str, unsigned int len) {
  // unsigned int i;
  while(len > 0) {
    // process this in batches of 16 bytes to actually use the FIFO in the UART

    // // wait until there is space in the fifo
    // while( (*(volatile unsigned int*)(UART_REG_LSR) & 0x20) == 0);

    // for(i = 0; /*(i < UART_FIFO_DEPTH) && */(len > 0); i++) {
      // wait until there is space in the fifo
      while( (*(volatile unsigned int*)(UART_REG_LSR) & 0x20) == 0);

      // load FIFO
      *(volatile unsigned int*)(UART_REG_THR) = *str++;

      len--;
    // }
  }
}

void uart_sendstr(const char* str) {
  // unsigned int i;

  while(*str) {
    // process this in batches of 16 bytes to actually use the FIFO in the UART

    // // wait until there is space in the fifo
    // while( (*(volatile unsigned int*)(UART_REG_LSR) & 0x20) == 0);

    // for(i = 0; /*(i < UART_FIFO_DEPTH) && */(len > 0); i++) {
      // wait until there is space in the fifo
      while( (*(volatile unsigned int*)(UART_REG_LSR) & 0x20) == 0);

      // load FIFO
      *(volatile unsigned int*)(UART_REG_THR) = *str++;

    // }
  }
}

char uart_getchar() {
  // printf("CTI: %d, RDA: %d\n", uart.ien_CTI, uart.ien_RDA);
  while((*((volatile int*)UART_REG_LSR) & 0x1) != 0x1);//uart_sendchar('.');

  return *(volatile int*)UART_REG_RBR;
}

void uart_sendchar(const char c) {
  // wait until there is space in the fifo
  while( (*(volatile unsigned int*)(UART_REG_LSR) & 0x20) == 0);

  // load FIFO
  *(volatile unsigned int*)(UART_REG_THR) = c;
}

void uart_wait_tx_done(void) {
  // wait until there is space in the fifo
  while( (*(volatile unsigned int*)(UART_REG_LSR) & 0x40) == 0);
}

int uart_is_tx_ready(void) {
    return ( (*(volatile unsigned int*)(UART_REG_LSR) & 0x20) != 0);
}

int uart_is_rx_ready(void) {
    return ( (*(volatile unsigned int*)(UART_REG_LSR) & 0x1) == 1);
}
