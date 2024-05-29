#include "stdio.h"     
#include "string.h"    
#include "unistd.h"    
#include "fcntl.h"     
#include "errno.h"     
#include "sys/types.h"
#include "sys/stat.h"
#include "stdlib.h"
#include "stdarg.h"
#include "termios.h"
#include "linux/serial.h"  
 
#define TIOCSRS485 0x542F
 
int main(void) {
    char txBuffer[65]; // 64 bytes for random string + 1 byte for null terminator
    int fd;
    struct termios tty_attributes;
    struct serial_rs485 rs485conf;
 
    if ((fd = open("/dev/ttymxc2",O_RDWR|O_NOCTTY|O_NONBLOCK))<0) {
        fprintf (stderr,"Open error on %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    } else {
        tcgetattr(fd,&tty_attributes);
 
        // c_cflag
        // Enable receiver
        tty_attributes.c_cflag |= CREAD;        
 
        // 8 data bit
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
        tty_attributes.c_lflag &= ~(ICANON);     
 
        tty_attributes.c_lflag &= ~(ECHO);      
 
        // DISABLE this: If ICANON is also set, the ERASE character 
        // erases the preceding input   
        // character, and WERASE erases the preceding word.
        tty_attributes.c_lflag &= ~(ECHOE);     
 
        // DISABLE this: When any of the characters INTR, QUIT, SUSP, 
        // or DSUSP are received, generate the corresponding signal.    
        tty_attributes.c_lflag &= ~(ISIG);      
 
        // Minimum number of characters for non-canonical read.
        tty_attributes.c_cc[VMIN]=1;            
 
        // Timeout in deciseconds for non-canonical read.
        tty_attributes.c_cc[VTIME]=0;           
 
        // Set the baud rate
        cfsetospeed(&tty_attributes,B9600);     
        cfsetispeed(&tty_attributes,B9600);
 
        tcsetattr(fd, TCSANOW, &tty_attributes);
 
        // Set RS485 mode:
        rs485conf.flags |= SER_RS485_ENABLED;
        rs485conf.flags |= SER_RS485_RTS_ON_SEND;
        if (ioctl(fd, TIOCSRS485, &rs485conf) < 0) {
            printf("ioctl error\n");
        }

          while (1) {
            // Generate random string
            for (int i = 0; i < 64; i++) {
                txBuffer[i] = 'A' + rand() % 26; // Random character from 'A' to 'Z'
            }
            txBuffer[64] = '\0'; // Null-terminate the string

            // Send the random string
            write(fd, txBuffer, 64);
            printf("COM3 Send message: %s\n", txBuffer);

            usleep(1000000); // Pause 1 second
        }
    }

    close(fd);
    return EXIT_SUCCESS;
}
