// No copyright. Vladislav Aleinik 2020

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <sys/select.h>

int main(int argc, char* argv[])
{
	if (argc != 2)
	{
		printf("Usage: uart_recv </dev/ttyUSB0 or similar>\n");
		exit(EXIT_FAILURE);
	}

	int uart_fd = open(argv[1], O_RDONLY|O_NOCTTY);
	if (uart_fd == -1)
	{
		printf("[ERROR] Unable to open \"%s\"\n", argv[1]);
		exit(EXIT_FAILURE);
	}

	// Configure the UART:
	struct termios uart_config;
	if (tcgetattr(uart_fd, &uart_config) == -1)
	{
		printf("[ERROR] Unable to get UART configuration\n");
		exit(EXIT_FAILURE);
	}

	if (cfsetispeed(&uart_config, B230400) == -1 ||
		cfsetospeed(&uart_config, B230400) == -1)
	{
		printf("[ERROR] Baud rate 230400 is not supported\n");
		exit(EXIT_FAILURE);
	}

	// Set UART to raw mode:
	uart_config.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON);
	uart_config.c_oflag &= ~OPOST;
	uart_config.c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
	uart_config.c_cflag &= ~(CSIZE|PARENB);
	uart_config.c_cflag |= CS8;

	if (tcsetattr(uart_fd, TCSANOW, &uart_config) == -1)
	{
		printf("[ERROR] Unable to configure UART\n");
		exit(EXIT_FAILURE);
	}

	while (1)
	{
		// Read random bits from UART:
		const size_t BUFFER_SIZE = 1024;
		char buffer[1024];

		int bytes_read = read(uart_fd, &buffer, BUFFER_SIZE);
		if (bytes_read == -1)
		{
			printf("[ERROR] Unable to read from \"%s\"\n", argv[1]);
			exit(EXIT_FAILURE);
		}

		for (int i = 0; i < bytes_read; ++i)
		{
			printf("%c%c%c%c%c%c%c%c", (buffer[i] & 0x01)? '0' : '1', (buffer[i] & 0x02)? '0' : '1',
			                           (buffer[i] & 0x04)? '0' : '1', (buffer[i] & 0x08)? '0' : '1',
			                           (buffer[i] & 0x10)? '0' : '1', (buffer[i] & 0x20)? '0' : '1',
			                           (buffer[i] & 0x40)? '0' : '1', (buffer[i] & 0x80)? '0' : '1');
			fflush(stdout);
		}	
	}

	close(uart_fd);
}