#ifndef __PROXY_H__
#define __PROXY_H__

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <setjmp.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>
#include <math.h>
#include <pthread.h>
#include <semaphore.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define ETH_NAME "en0"


#define MAXLINE 102400
#define MAXBUF 102400
#define LISTENQ 1024
#define BUFSIZE 102400

#define UNIX   0
#define LOG    1
#define POSIX  2
#define DNS    3
#define LOGDNS 4
typedef void handler_t (int);


extern int h_errno;

struct _web_t{
	int web_fd;
	int web_num;
	char * web_buf_addr;
	char web_buf[BUFSIZE];
};
typedef struct _web_t web_t;


void error_handler(char* message, int num, int error_type);
void thread_join(pthread_t pid, void ** return_point);
void thread_create(pthread_t * pid, pthread_attr_t * attr,
		void * (*routine)(void*), void * args);
ssize_t web_readp(int fd, void * addr, size_t bytenum);
ssize_t web_writen(int fd, void * buf_t, size_t n);
int start_client(char * hostname, int port);
static ssize_t web_read(web_t * par, char * buf_tmp, size_t n);
ssize_t web_readline(web_t * par, void * buf_tmp, size_t len);
void web_read_ini(web_t * par, int fd);
int start_server(int port);
handler_t *Signal(int signum, handler_t *handler);
ssize_t rio_readnb(web_t *rp, void *usrbuf, size_t n);




void error_handler(char* message, int num, int error_type){
	if(error_type == UNIX){
	    fprintf(stderr, "%s: %s\n", message, strerror(errno));
	}
	else if (error_type == LOG){
	    fprintf(stderr, "%s: %s\n", message, strerror(errno));
	}
	else if (error_type == POSIX){
		fprintf(stderr, "%s: %s\n", message, strerror(num));
	}
	else if (error_type == DNS){
	    fprintf(stderr, "%s: DNS error %d\n", message, h_errno);
	}
	else if (error_type == LOGDNS){
	    fprintf(stderr, "%s: DNS error %d\n", message, h_errno);
	}
}

void thread_join(pthread_t pid, void ** return_point){
	int tmp;
	if((tmp = pthread_join(pid, return_point)) != 0){
		error_handler("thread join error", tmp, POSIX);
	}
}

void thread_create(pthread_t * pid, pthread_attr_t * attr,
		void * (*routine)(void*), void * args){
	int tmp;
	if((tmp = pthread_create(pid, attr, routine, args)) != 0){
		error_handler("thread create error", tmp, POSIX);
	}
}

ssize_t web_readp(int fd, void * addr, size_t bytenum){
	ssize_t n;
	while(1){
		n = read(fd, addr, bytenum);
		if(n < 0 && errno == EINTR) continue;
		break;
	}
	if(n < 0){
		if(errno != EPIPE){
			error_handler("wed read error", 0, LOG);
		}
		else
			return -1;
	}
	return n;
}

ssize_t web_writen(int fd, void * buf_t, size_t n){
	size_t byte_left = n;
	ssize_t byte_written;
	char * buf = (char*)buf_t;

	while(byte_left > 0){
		byte_written = write(fd, buf, byte_left);
		if(byte_written > 0){
			byte_left -= byte_written;
			buf += byte_written;
		}
		else{
			if(errno == EINTR)
				byte_written = 0;
			else{
				n = -1;
				break;
			}
		}
	}
	if(n == -1 && errno != EPIPE){
		error_handler("web writen error", 0, LOG);
	}
	return n;
}

int start_client(char * hostname, int port){
	int clientfd;
	struct hostent * host;
	struct sockaddr_in server_addr;

	clientfd = socket(AF_INET, SOCK_STREAM, 0);
	if(clientfd < 0){
		error_handler("client start unix error", 0, LOG);
		return -1;
	}

	host = gethostbyname(hostname);
	if(host == NULL){
		error_handler("client start DNS error", 0, LOGDNS);
		return -2;
	}
	bzero((char*) &server_addr, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	bcopy((char *)host->h_addr, (char *)&server_addr.sin_addr.s_addr,
			host->h_length);
	server_addr.sin_port = htons(port);

	if(connect(clientfd, (struct sockaddr *) & server_addr, sizeof(server_addr)) < 0){
		error_handler("client start unix error", 0, LOG);
		return -1;
	}
	return clientfd;
}


static ssize_t web_read(web_t * par, char * buf_tmp, size_t n){
	int num;
	while(par->web_num <= 0){
		par->web_num = read(par->web_fd, par->web_buf, sizeof(par->web_buf));
		if(par->web_num == 0)
			return 0;
		else if(par->web_num < 0 && errno != EINTR){
			return -1;
		}
		else{
			par->web_buf_addr = par->web_buf;
		}
	}

	num = n;
	if(par->web_num < n)
		num = par->web_num;
	memcpy(buf_tmp, par->web_buf_addr, num);
	par->web_buf_addr += num;
	par->web_num -= num;
	return num;
}
ssize_t web_readline(web_t * par, void * buf_tmp, size_t len){
	int n;
	n = 0;
	int tmp;
	char input;
	char * buf = (char*)buf_tmp;

	while(n < len - 1){
		tmp = web_read(par, &input, 1);
		if(tmp == 0)
			break;
		else if(tmp == 1){
			n++;
			*buf++ = input;
			if(input == '\n')
				break;
		}
		else{
			error_handler("web read line error", 0, LOG);
			return -1;
		}
	}
	*buf = 0;
	return n;
}


ssize_t rio_readnb(web_t *rp, void *usrbuf, size_t n) 
{
    size_t nleft = n;
    ssize_t nread;
    char *bufp = usrbuf;
    
    while (nleft > 0) {
	if ((nread = web_read(rp, bufp, nleft)) < 0) {
	    if (errno == EINTR) 
		nread = 0;     
	    else
		return -1;     
	} 
	else if (nread == 0)
	    break;             
	nleft -= nread;
	bufp += nread;
    }
    return (n - nleft);        
}
void web_read_ini(web_t * par, int fd)
{
    par->web_fd = fd;
    par->web_num = 0;
    par->web_buf_addr = par->web_buf;
}

int start_server(int port){
	int server_fd;
	int optval = 1;
	struct sockaddr_in server_addr;
	server_fd = socket(AF_INET, SOCK_STREAM, 0);
	if(setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR,
				(const void *) & optval, sizeof(int)) < 0)
			return -1;
	if(server_fd < 0)
		return -1;

	bzero((char *) & server_addr, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	server_addr.sin_port = htons((unsigned short) port);

	if(bind(server_fd, (struct sockaddr *) & server_addr, sizeof(server_addr)) < 0)
		return -1;

	if(listen(server_fd, LISTENQ) < 0)
		return -1;

	return server_fd;
}


handler_t *Signal(int signum, handler_t *handler)
{
    struct sigaction action, old_action;

    action.sa_handler = handler;
    sigemptyset(&action.sa_mask); /* block sigs of type being handled */
    action.sa_flags = SA_RESTART; /* restart syscalls if possible */

    if (sigaction(signum, &action, &old_action) < 0)
    	error_handler("signal error", 0, UNIX);
    return (old_action.sa_handler);
}


void ignore()
{
	;
}


#endif
