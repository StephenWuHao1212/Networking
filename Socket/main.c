/*
 * main.c
 *
 *  Created on: Jan 22, 2015
 *      Author: ubuntu
 */


#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <pthread.h>

void * serverReply(void * args);
int server(uint16_t port);
int client(const char * addr, uint16_t port);

#define MAX_MSG_LENGTH (512)
#define MAX_BACK_LOG (5)

int main(int argc, char ** argv)
{
  if (argc < 3) {
    printf("Command should be: myprog s <port> or myprog c <port> <address>\n");
    return 1;
  }
  int port = atoi(argv[2]);
  if (port < 1024 || port > 65535) {
    printf("Port number should be equal to or larger than 1024 and smaller than 65535\n");
    return 1;
  }
  if (argv[1][0] == 'c') {
    if(argv[3]==NULL){
      printf("NO IP address is given\n");
      return 1;
    }
    return client(argv[3], port);
  } else if (argv[1][0] == 's') {
    return server(port);
  } else {
    printf("unknown command type %s\nCommand should be: myprog s <port> or myprog c <port> <address>", argv[1]);
    return 1;
  }
  return 0;
}

int client(const char * addr, uint16_t port)
{
  int sock;
  struct sockaddr_in server_addr;
  char msg[MAX_MSG_LENGTH], reply[MAX_MSG_LENGTH*3];

  if ((sock = socket(AF_INET, SOCK_STREAM/* use tcp */, 0)) < 0) {
    perror("Create socket error:");
    return 1;
  }

  printf("Socket created\n");
  server_addr.sin_addr.s_addr = inet_addr(addr);
  server_addr.sin_family = AF_INET;
  server_addr.sin_port = htons(port);

  if (connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
    perror("Connect error:");
    return 1;
  }

  printf("Connected to server %s:%d\n", addr, port);

  int recv_len = 0;
  while (1) {
    fflush(stdin);
    printf("Enter message: \n");
    gets(msg);
    if (send(sock, msg, MAX_MSG_LENGTH, 0) < 0) {
      perror("Send error:");
      return 1;
    }
    recv_len = read(sock, reply, MAX_MSG_LENGTH*3);
    if (recv_len < 0) {
      perror("Recv error:");
      return 1;
    }
    reply[recv_len] = 0;
    printf("Server reply:\n%s\n", reply);
    memset(reply, 0, sizeof(reply));
  }
  close(sock);
  return 0;
}

int server(uint16_t port)
{
  /*
    add your code here
  */
  struct sockaddr_in sin;
  int sock;
  socklen_t len;
  /* build address data structure */
  memset((char *)&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = INADDR_ANY;
  sin.sin_port = htons(port);
  /* setup passive open */
  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("simplex-talk: socket");
    exit(1);
  }
  if ((bind(sock, (struct sockaddr *)&sin, sizeof(sin))) < 0) {
    perror("simplex-talk: bind");
    exit(1);
  }
  /* wait for connection, then receive and print text */
  int new_sock[MAX_BACK_LOG] = {-1,-1,-1,-1,-1};
  int i = 0;
  listen(sock, MAX_BACK_LOG);
  while(1) {
    if ((new_sock[i] = accept(sock, (struct sockaddr *)&sin, &len)) < 0) {
      perror("simplex-talk: accept");
      exit(1);
    }
    pthread_t server_thread;
    if(pthread_create(&server_thread, NULL, serverReply, &new_sock[i])) {
      fprintf(stderr, "Error creating thread\n");
      exit(1);
    }
    else{
      i++;
    }
  }
  return 0;
}

void* serverReply(void * args){
  int * new_sock = (int*)args;
  int len;
  char buf[MAX_MSG_LENGTH];
  char buf_server[MAX_MSG_LENGTH * 3];
  printf("before recv socket %d\n", *new_sock);
  while ((len = recv(*new_sock, buf, sizeof(buf), 0))){ 
    strcpy(buf_server, buf);
    strcat(buf_server, buf);
    strcat(buf_server, buf);
    if (send(*new_sock, buf_server, MAX_MSG_LENGTH * 3, 0) < 0) {
      perror("Send error:");
      exit(1);
    }
  }
  return 0;
}



