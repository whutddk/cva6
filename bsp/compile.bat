

rmdir /s /q .\build
md .\build

@echo Remove Complete

@rem compile .c
riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
-I ./ -I ./src -I ./axi_gpio -I ./axi_uart ^
-c ./src/main.c ^
-o ./build/main.o

riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
-I ./ -I ./src ^
-c ./axi_uart/uart.c ^
-o ./build/uart.o

riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
-I ./ -I ./src -I ./axi_gpio ^
-c ./axi_gpio/gpio.c ^
-o ./build/gpio.o

riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
-I ./ -I ./src -I ./axi_uart ^
-c ./axi_uart/uart.c ^
-o ./build/uart.o

@rem riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
@rem -I./ -I ./src^ 
@rem -c .c 
@rem -o .\build\ .o

@echo C Code Compile Complete


@rem compile .s
riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs -mcmodel=medany -mexplicit-relocs ^
-I ./ -I ./src ^
-c ./src/startup.S ^
-o ./build/startup.o

@rem riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs -mcmodel=medany -mexplicit-relocs
@rem -I./ -I ./src ^
@rem -c .s  ^
@rem -o .\build\ .o

@rem riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs -mcmodel=medany -mexplicit-relocs
@rem -I./ -I ./src ^
@rem -c .s  ^
@rem -o .\build\ .o

@echo Asm Code Compile Complete


@rem linker
riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs -nostdlib -nodefaultlibs -nostartfiles ^
-I ./ -I ./src ^
-T linker.lds ./build/main.o ./build/uart.o ./build/startup.o ./build/gpio.o ^
-o software.elf


@pause




