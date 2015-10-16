#include <stdio.h>
#include "proxy.h"
#include "cache.h"
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void *webTalk(void* args);
void parseAddress(char* url, char* host, char** file, int* serverPort);

int debug;
int proxyPort;
int debugfd;
int logfd;
pthread_mutex_t ll_mutex;
linkedlist_t * ll;
int num_thread;


int main(int argc, char *argv[]){
	fprintf(stdout, "start proxy\n");
	num_thread = 0;
	int serverfd;
	int connfd;
	int clientlen;
	int optval;
	int serverPort;
	int ll_size;
	sigset_t sig_pipe;
	struct sockaddr_in clientaddr;
  
	if (argc < 3) {
		fprintf(stdout, "input error\n");
		exit(1);
	}

	Signal(SIGPIPE, ignore);

	if(sigemptyset(&sig_pipe) || sigaddset(&sig_pipe, SIGPIPE))
		error_handler("creating sig_pipe set failed", 0, UNIX);
	if(sigprocmask(SIG_BLOCK, &sig_pipe, NULL) == -1)
		error_handler("sigprocmask failed", 0, UNIX);


	proxyPort = atoi(argv[1]);
	ll_size = atoi(argv[2]) * 1000000;
	serverPort = 80;
	ll = (linkedlist_t*)malloc(sizeof(linkedlist_t));
	linkedlist_ini(ll, ll_size);

	serverfd = start_server(proxyPort);

	optval = 1;
	setsockopt(serverfd, SOL_SOCKET, SO_REUSEADDR, (const void*)&optval, sizeof(int));
  
	pthread_mutex_init(&ll_mutex, NULL);
  
	while(1) {
		while(1){
			if(num_thread <= 20) break;
			
		}
		if(num_thread == 0) {
		  printf("ready for new connection\n");
		}
		clientlen = sizeof(clientaddr);

		connfd = accept(serverfd, (struct sockaddr *)&clientaddr, &clientlen);
		if(connfd < 0){
			error_handler("accept error", 0, LOG);
		}

		void *arg;
		arg = (void*)malloc(2 * sizeof(int));
		if(arg == NULL){
			error_handler("malloc error", 0, UNIX);
		}
		*((int * )arg) = connfd;
		*((int*)arg + 1) = serverPort;

		pthread_t tid;
		pthread_create(&tid, NULL, webTalk, (void *)arg);
		pthread_detach(tid);
		num_thread++;
	}
	pthread_mutex_destroy(&ll_mutex);
  
	return 0;
}

void *webTalk(void* args){
	int serverfd;
	int clientfd;
	int serverPort;
	int tries = 0;
	int byteCount = 0;
	char buf1[MAXLINE], buf2[MAXLINE], buf3[MAXLINE];
	char host[MAXLINE];
	char url[MAXLINE];
	char *saveptr;
	char *cmd;
	char *version;
	char *file;

	web_t client;
	char slash[10];
	strcpy(slash, "/");

	clientfd = ((int*)args)[0];
	serverPort = ((int*)args)[1];
	free(args);

	web_read_ini(&client, clientfd);
	for(tries = 0; tries < 6; tries++){
		if(tries == 5){
			return NULL;
		}
		if(web_readline(&client,(void *) buf1, sizeof(buf1)) > 0){
			break;
		}
	}

	cmd = strtok_r(buf1, " ", &saveptr);
	strcpy(url,  strtok_r(NULL, " ", &saveptr));
	version = strtok_r(NULL, "\r\n", &saveptr);
	parseAddress(url, host, &file, &serverPort);

	if(strcmp(cmd, "GET") == 0){
		char * read_buf[MAXARRAY];
		int value_size[MAXARRAY];
		int i;
		for(i = 0; i < MAXARRAY; i++){
			read_buf[i] = NULL;
			value_size[i] = 0;
		}
		int find_ans;
		pthread_mutex_lock(&ll_mutex);
		find_ans = linkedlist_find(ll, url, read_buf, value_size);
		pthread_mutex_unlock(&ll_mutex);
		if(find_ans == 1){
			fprintf(stdout, "read from cache, url is %s\n", url);
			for(i = 0; i < MAXARRAY; i++){
				if(read_buf[i] == NULL) break;
				web_writen(clientfd, (void*)read_buf[i], value_size[i]);
			}
		}
		else if(find_ans == -1){
			fprintf(stdout, "first time access to: %s\n", url);
			for(tries = 0; tries < 6; tries++){
				if(tries == 5){
					close(serverfd);

					return NULL;
				}
				if((serverfd = start_client(host, serverPort)) > 0){
					break;
				}
			}

			file = (file == NULL) ? slash:file;
			sprintf(buf2, "%s %s %s\r\n", cmd, file, version);
			int n_t = strlen(buf2);
			web_writen(serverfd, (void*)buf2, n_t);

			while((byteCount =  web_readline(&client, (void*)buf3, sizeof(buf3))) > 0){
				buf3[byteCount] = '\0';
				if(strcasecmp(buf3, "Connection: Keep-Alive\r\n") == 0){
					char * closeRequest = "Connection: Keep-Alive\r\n";
					n_t = strlen(closeRequest);
					web_writen(serverfd, (void *)closeRequest, n_t);
					continue;
				}
				n_t = strlen(buf3);
				web_writen(serverfd, (void *)buf3,n_t);
				if(strcmp(buf3, "\r\n") == 0){
					break;
				}
			}

			i = 0;
			while((byteCount = web_readp(serverfd, buf1, sizeof(buf1))) > 0) {
				web_writen(clientfd, (void*)buf1, byteCount);
				read_buf[i] = (char *)malloc(byteCount);
				memcpy(read_buf[i], buf1, byteCount);
				value_size[i] = byteCount;
				i++;
			}
			pthread_mutex_lock(&ll_mutex);
			linkedlist_add(ll, url, read_buf, value_size);
			pthread_mutex_unlock(&ll_mutex);
			for(i = 0; i < MAXARRAY; i++){
				if(read_buf[i] == NULL) break;
				free(read_buf[i]);
			}
		}
  }
  close(serverfd);
  close(clientfd);
  num_thread--;
  pthread_exit(0);
}

void parseAddress(char* url, char* host, char** file, int* serverPort){
  char *point1;
  char *saveptr;

  if(strstr(url, "http://"))
    url = &(url[7]);
  *file = strchr(url, '/');

  strcpy(host, url);

  strtok_r(host, "/", &saveptr);

  point1 = strchr(host, ':');
  if(!point1) {
    *serverPort = 80;
    return;
  }

  strtok_r(host, ":", &saveptr);

  *serverPort = atoi(strtok_r(NULL, "/",&saveptr));
}


