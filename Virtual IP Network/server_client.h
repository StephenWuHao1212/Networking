#ifndef _SERVER_CLIENT_H_
#define _SERVER_CLIENT_H_

#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>
#include <pthread.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

#include "ipsum.h"

const uint16_t MTU = 1400;
const uint32_t BUFFER_SIZE = 65536;
const uint32_t INFINITY = 16;

pthread_mutex_t clientMutex;

class Server{
private:
	struct sockaddr_in clientAddr;
	char packet[MTU];
	int sockfd;
	int len;
public:
	Server(int sockfdTmp){
		sockfd = sockfdTmp;
		len = sizeof(clientAddr);
	}
	char * recv(){
		if (recvfrom(sockfd, (void *)packet, (size_t)MTU, 0, (struct sockaddr *)&clientAddr, (socklen_t *)&len)==-1){
			perror("server receive fail");
        	exit(1);
        }
        return packet;
	}
	in_addr_t addr(){
		return clientAddr.sin_addr.s_addr;
	}
	in_port_t port(){
		return clientAddr.sin_port;
	}
};

class Client{
private:
	int sock;
	struct sockaddr_in serverAddr;
	socklen_t len;
	uint16_t fragmentId;
public:
	Client() {}
	Client(int sockTmp) : sock(sockTmp){}
 	Client(int sockTmp, const in_addr_t & addr, const uint16_t & port) {
   		sock = sockTmp;
        
        // server_addr.sin_addr.s_addr = inet_addr(addr);
        serverAddr.sin_addr.s_addr = addr;
        serverAddr.sin_family = AF_INET;
        serverAddr.sin_port = port;
        len = sizeof(serverAddr);
        
        fragmentId = 0;
    }

    void send(char * headerTmp, const char * payload, uint32_t payloadLen){
    	pthread_mutex_lock(&clientMutex);
    	ip * header = (ip*) headerTmp;
    	uint16_t headerLen = header->ip_hl * 4;
    	uint32_t totalLen = headerLen + payloadLen;
    	header->ip_len = htons((uint16_t)totalLen);
    	header->ip_sum = 0;
    	header->ip_sum = htons(ip_sum((char * )header, headerLen));

    	char packet[totalLen];
    	memcpy(packet, header, headerLen);
    	memcpy(packet + headerLen, payload, payloadLen);
    	if (sendto(sock, (void *)packet, totalLen, 0, (struct sockaddr *)&serverAddr, len)==-1){
         	perror("send fail");
         	exit(1);
        }
        pthread_mutex_unlock(&clientMutex);
    }

    void setting(const in_addr_t &ip, const uint16_t & port, int sockTmp){
    	sock = sockTmp;
    	serverAddr.sin_addr.s_addr = ip;
    	serverAddr.sin_family = AF_INET;
    	serverAddr.sin_port = port;
    	len = sizeof(serverAddr);
    }

};
#endif
