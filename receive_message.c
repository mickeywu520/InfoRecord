#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <linux/serial.h>
#include <signal.h>

#define TIOCSRS485 0x542F

int fd;

void sigint_handler(int signum) {
    close(fd);
    _exit(0);
}

int main(void) {
    char rxBuffer[65]; // 64 bytes for data + 1 byte for null terminator
    struct termios tty_attributes;
    struct serial_rs485 rs485conf;

    if ((fd = open("/dev/ttymxc3", O_RDWR | O_NOCTTY)) < 0) {
        fprintf(stderr, "Open error on %s\n", strerror(errno));
        return -1;
    }
    //fprintf(stderr, "Open success!\n");

    tcgetattr(fd, &tty_attributes);
 
    // c_cflag
    // Enable receiver
    tty_attributes.c_cflag |= CREAD;        
    // 8 data bits
    tty_attributes.c_cflag |= CS8;          

    // c_iflag
    // Ignore framing errors and parity errors. 
    tty_attributes.c_iflag |= IGNPAR;       

    // c_lflag
    // DISABLE canonical mode.
    // Disables the special characters EOF, EOL, EOL2, 
    // ERASE, KILL, LNEXT, REPRINT, STATUS, and WERASE, and buffers 
    // by lines.
    // DISABLE this: Echo input characters.
    // DISABLE this: If ICANON is also set, the ERASE character 
    // erases the preceding input   
    // character, and WERASE erases the preceding word.
    // DISABLE this: When any of the characters INTR, QUIT, SUSP, 
    // or DSUSP are received, generate the corresponding signal.    
    tty_attributes.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);      
 
    // Minimum number of characters for non-canonical read.
    tty_attributes.c_cc[VMIN] = 1;            

    // Timeout in deciseconds for non-canonical read.
    tty_attributes.c_cc[VTIME] = 0;           

    // Set the baud rate
    cfsetospeed(&tty_attributes, B9600);     
    cfsetispeed(&tty_attributes, B9600);

    tcsetattr(fd, TCSANOW, &tty_attributes);

    // Set RS485 mode: 
    rs485conf.flags = SER_RS485_ENABLED;
    if (ioctl(fd, TIOCSRS485, &rs485conf) < 0) {
        printf("ioctl error\n");
    }
    //fprintf(stderr, "Set RS485 mode!\n");

    // Register SIGINT (Ctrl + C) signal handler
    struct sigaction sigint_action;
    sigint_action.sa_handler = sigint_handler;
    sigemptyset(&sigint_action.sa_mask);
    sigint_action.sa_flags = 0;
    sigaction(SIGINT, &sigint_action, NULL);

    while (1) {
        // Read data into rxBuffer
        int bytesRead = read(fd, rxBuffer, 64);
        if (bytesRead > 0) {
            // Null-terminate the received data
            rxBuffer[bytesRead] = '\0';
            printf("COM4 Received message: %s\n", rxBuffer);
        }
    }
    return 0; // This line will never be executed due to the infinite loop
}
