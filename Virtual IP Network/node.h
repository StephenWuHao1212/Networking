#ifndef __NODE_H__
#define __NODE_H__

#include <vector>
#include <string>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <assert.h>
#include <pthread.h>
#include <set>
#include <stdio.h>
#include <errno.h>
#include <map>
#include <vector>
#include <set>

#include "print.h"
#include "server_client.h"

using namespace std;

static const int UP = 1;
static const int DOWN = 2;
//static const int NO_RESPOND = 3;
const int NO_RESPOND_TIME = 12;

const int RIP_REQUEST  = 1;
const int RIP_RESPONSE = 2;

static const int TIMER = 1;
static const int RECEIVER = 2;

pthread_mutex_t mut, update_mutex;
pthread_mutex_t table_mutex;
pthread_mutex_t mut_tmp;


struct link_t{
	int status;
	in_addr_t ip_addr;
	uint16_t port;
	in_addr_t localVIP;
	in_addr_t remoteVIP;
	int time;
	Client sender;

	link_t() : status(UP), time(0){}

	void send(char * header, const char * payload, uint32_t payloadLen) {
        sender.send(header, payload, payloadLen);
    }

};

struct forwardEntry_t{
	int linkNum;
	int cost;
};

class forwardTable;

class Node{
	private:
		in_addr_t ip_addr;
		uint16_t port;
		vector<link_t> links;

		int sockfd;
		sockaddr_in sin;

		void get_local_info(const string & line, in_addr_t & ip_addr, uint16_t & port);
		void get_link_info(const string & line, in_addr_t & localVIP, in_addr_t & remoteVIP
							,uint16_t & port, in_addr_t & ip_addr);
	public:
		Node(const char * fileName);
		in_addr_t get_ip_from_line(const char * ip_str) const;
		void up(forwardTable & table, int linkNum);
		void down(forwardTable & table, int linkNum);
		void ifconfig();
		void send(int linkNum, char * header, const char * payload, uint32_t payloadLen);
		int linkNum(const in_addr_t & addr, const in_port_t & port);
		int socket_();
		vector<link_t> & Links_();
		const link_t & Links_(int linkNum) const;
		void update_time(int mode, forwardTable & table, int arg = NO_RESPOND_TIME);
		bool dest_check(uint32_t dest);
		int links_size() const;
		in_addr_t ipAddr();
		const vector<link_t> & Links_() const;
		void print_local_VIP();

};

class forwardTable {
private:
    std::map<in_addr_t, forwardEntry_t> table;
public:
    struct entry_t{
        uint32_t cost;
        uint32_t address;
    };

    forwardTable(Node& node);
	void update(Node & node, int command, int linkNum, char * payload = NULL, uint32_t payloadLen = 0);
	int find_link_num(const in_addr_t & dest);
    char * payload_from_table(int linkNum, const Node & node, char * payload,
			uint16_t payloadLen, uint16_t command, uint16_t entriesNum);
    void send(Node & node, int command);
    void print();

};
Node::Node(const char * fileName){
	FILE * file = fopen(fileName, "r");
	if(file == NULL){
		perror(string("cannot open " + string(fileName)).c_str());
		exit(1);
	}
	//initialize ip and port
	char * line = NULL;
	size_t size = 0;

	if(getline(&line, &size, file) != -1){
		get_local_info(string(line), ip_addr, port);
		printIp(ip_addr) << endl;
		printPort(port) << endl;
	}
	else{
		perror("file format fault");
		exit(1);
	}
	//initialize socket
	sockfd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

    sin.sin_family = AF_INET;      
    sin.sin_port = port;
    sin.sin_addr.s_addr = INADDR_ANY;
  
    bind(sockfd, (struct sockaddr *)&sin, sizeof(sin));

	while (getline(&line, &size, file) != -1) {
       	link_t tmpLink;
 
        get_link_info(string(line), tmpLink.localVIP, tmpLink.remoteVIP, tmpLink.port, tmpLink.ip_addr);
        links.push_back(tmpLink);
    }
    
    for (int i = 0; i < links.size(); i++) {
        printIp(links[i].localVIP) << " ";
        printIp(links[i].remoteVIP) << endl;
    }
    
    free(line);
    fclose(file);
    
    for (int i = 0; i < links.size(); i++) {
        links[i].sender.setting(links[i].ip_addr, links[i].port, sockfd);
    }


}	

in_addr_t Node::get_ip_from_line(const char * ip_str) const{
	in_addr_t ip;
	const hostent * info = gethostbyname(ip_str);
	if(info) {
		memcpy(&ip, info->h_addr_list[0],4);
	}
	else{
		perror(string(string(ip_str) + ": invalid\n").c_str());
		exit(1);
	}
	return ip;
}

void Node::get_local_info(const string & line, in_addr_t & ip_addr, uint16_t & port){
	string localHostIn;
	string sPort;
	int localPortIn;
	std::size_t start = 0;
	std::size_t end= line.find(':');
	localHostIn = line.substr(start, end - start);
	
	ip_addr = get_ip_from_line(localHostIn.c_str());
	if (ip_addr == INADDR_NONE) {
		perror("input ip address is invalid\n");
		exit(1);
	}
	
	sPort = line.substr(end + 1, line.size() - end - 1);
	localPortIn = atoi(sPort.c_str());
	if (localPortIn < 1024 || localPortIn > 65535){
		perror("port number is invalid\n");
		exit(1);
	}
    port = htons(localPortIn);
}

void Node::get_link_info(const string & line, in_addr_t & localVIP, in_addr_t & remoteVIP
							,uint16_t & port, in_addr_t & ip_addr){
	 // [IP-address-of-remote-node]:[port-of-remote-node] [VIP of my interface] [VIP of the remote node's inteface]" 
	 // e.g. "localhost:17001 10.116.89.157 10.10.168.73"
	string::size_type end = line.find(":");
    string ip_tmp = line.substr(0, end);
    ip_addr = get_ip_from_line(ip_tmp.c_str());
   
   	string::size_type start = end + 1;
    end = line.find(" ", start);
 
    string port_tmp = line.substr(start, end - start);
    port = atoi(port_tmp.c_str());
    if (port < 1024 || port > 65535) {
    	perror("port number fail\n");
    	exit(1);
    }
    port = htons(port);

    start = end + 1;
    while (start < line.size() && line[start] == ' '){
    	start += 1;
    }

    if (start == line.size()){
   		perror("Invalid input file");
   		exit(1);
   	}
   
    //parse local VIP
    end = line.find(" ", start);
    if (end == line.npos) {
    	end = line.size();
    }
    
    localVIP = get_ip_from_line(line.substr(start, end - start).c_str());

	//parse remote VIP
    start = end + 1;
    while (start < line.size() && line[start] == ' '){
    	start += 1;
    }
    end = line.find("\n", start);
    if (end == line.npos) {
    	end = line.size();
//    	while(line[end] != '\0'){
//    		end = end + 1;
//    	}
    }
    cout << line << endl;
    cout << "get" << line.substr(start, end - start - 1).c_str() << endl;
    remoteVIP = get_ip_from_line(line.substr(start, end - start).c_str());
}




void Node::up(forwardTable & table, int linkNum) {
	if(linkNum <= 0 || linkNum > links.size()){
		cout << "Interface " << linkNum << " not found" << endl;
	}
	else if(links[linkNum - 1].status != UP){
		links[linkNum - 1].status = UP;
		table.update(*this, UP, linkNum, NULL, 0);
		cout << linkNum << " ";
		printIp(links[linkNum - 1].localVIP) << " up" << endl;
	}
}

void Node::down(forwardTable & table, int linkNum){
	if(linkNum <= 0 || linkNum > links.size()){
		cout << "Interface " << linkNum << " not found" << endl;
	}
	else if(links[linkNum - 1].status != DOWN){
		links[linkNum - 1].status = DOWN;
		table.update(*this, DOWN, linkNum, NULL, 0);
		cout << linkNum << " ";
		printIp(links[linkNum - 1].localVIP) << " down" << endl;
	}
}

void Node::ifconfig(){
	for(int i = 0; i < links.size(); i++){
		cout << i + 1 << " ";
		printIp(links[i].localVIP) << " ";
		if(links[i].status == UP) cout << "up" << endl;
		else if(links[i].status == DOWN) cout << "down" << endl;
		else assert(false);
	}
}

void Node::send(int linkNum, char * header, const char * payload, uint32_t payloadLen){
		links[linkNum - 1].send(header, payload, payloadLen);		
}

int Node::linkNum(const in_addr_t & addr, const in_port_t & port) {
    for (int i = 0; i < links.size(); i++) {
        if (links[i].ip_addr == addr && (in_port_t)links[i].port == port) {
        	return i + 1;
        }
    }
    return 0;
}

int Node::socket_() {
    return sockfd;
}

vector<link_t> & Node::Links_() {
    return links;
}

const link_t & Node::Links_(int linkNum) const{
    return links[linkNum - 1];
}

const vector<link_t> & Node::Links_() const{
	return links;
}

void Node::update_time(int mode, forwardTable & table, int arg){
	pthread_mutex_lock(&update_mutex);
	if(mode == TIMER){
		for(int i = 0; i < links.size(); i++){
			links[i].time++;
			if(links[i].time >= arg)
				table.update(*this, DOWN, i + 1);
//			if(links[i].status == UP && links[i].time >= arg){
//				links[i].status = NO_RESPOND;
//				table.update(*this, NO_RESPOND, i + 1);
//			}
		}
	}
	else if(mode == RECEIVER){
//		if(links[arg - 1].status == NO_RESPOND){
//			links[arg - 1].status == UP;
//		}
		links[arg - 1].time = 0;
	}
	pthread_mutex_unlock(&update_mutex);
}

bool Node::dest_check(uint32_t dest) {
    const vector<link_t> &links = Links_();
    for (int i = 0; i < Node::links_size(); i++){
        if (dest == Node::Links_(i).localVIP) {
        	return true;
        }
   	}
    return false;
}

int Node::links_size() const {
    return (int) links.size();
}

in_addr_t Node::ipAddr() {
    return ip_addr;
}


void Node::print_local_VIP(){
	for(int i = 0; i < links.size(); i++){
		cout << "local: ";
		printIp(links[i].localVIP) << " ";
		cout << "remote: ";
		printIp(links[i].remoteVIP) << endl;
	}
}



forwardTable::forwardTable(Node & node){
	int size = node.links_size();
	for(int i = 0; i < size; i++){
		forwardEntry_t entry;
		entry.cost = 1;
		entry.linkNum = i + 1;
		table[(node.Links_(i + 1)).remoteVIP] = entry;
	}
}


void forwardTable::send(Node & node, int command){
	pthread_mutex_lock(&table_mutex);

	ip header;
	header.ip_v = 4;
	header.ip_hl = 5;
	header.ip_ttl = 16;
	header.ip_p = 200;
	header.ip_off = 0;

	std::vector<link_t> & links = node.Links_();

	uint32_t payloadLen;
    uint16_t fwdCommand;
    uint16_t entriesNum;


	if(command == RIP_RESPONSE){
		payloadLen = sizeof(uint16_t) * 2 + sizeof(struct entry_t) * (uint32_t)(table.size() + node.links_size());
		fwdCommand = 2;
		entriesNum = table.size() + node.links_size();
	}
	else if (command == RIP_REQUEST){
		payloadLen = sizeof(uint16_t) * 2;
		fwdCommand = 1;
		entriesNum = 0;
	}
	else assert(false);

	for(int i = 0; i < node.links_size(); i++){
		if(node.Links_(i + 1).status == UP){
			header.ip_src.s_addr = node.Links_(i + 1).localVIP;
			header.ip_dst.s_addr = node.Links_(i + 1).remoteVIP;
			char payload[payloadLen];
			payload_from_table(i + 1, node, payload, payloadLen, fwdCommand, entriesNum);
			links[i].send((char*)&header, payload, payloadLen);
		}
	}
	pthread_mutex_unlock(&table_mutex);
}

char * forwardTable::payload_from_table(int linkNum, const Node & node, char * payload,
			uint16_t payloadLen, uint16_t command, uint16_t entriesNum){
	*(uint16_t*)payload = htons(command);
	*(uint16_t*)(payload + 2) = htons(entriesNum);

	if(command == RIP_RESPONSE){
        int i = 0;
        for (std::map<in_addr_t, forwardEntry_t>::iterator it = table.begin(); it != table.end(); it++) {
            struct entry_t entry;
            entry.address = it->first;
            if(linkNum == it->second.linkNum){
            	entry.cost = htonl(INFINITY);
            }
            else{
                entry.cost=htonl(it->second.cost);
            }
            *(struct entry_t*)(payload + sizeof(uint16_t) * 2 + sizeof(entry_t) * i) = entry;
            i++;
        }
        for (int j = 0; j < node.Links_().size(); j++) {
            struct entry_t entry;
            entry.cost = htonl(0);
            entry.address = node.Links_(j).localVIP;


            *(struct entry_t*)(payload + sizeof(uint16_t) * 2 + sizeof(entry_t) * i) = entry;
            i++;
        }
	}
	return payload;
}

void forwardTable::update(Node & node, int command, int linkNum, char * payload, uint32_t payloadLen){
	pthread_mutex_lock(&mut_tmp);
	//int cond = false;
	//if(payload == NULL && (command == DOWN 	|| command == NO_RESPOND)){
	if(payload == NULL){
		if(command == DOWN){
			for(std::map<in_addr_t, forwardEntry_t>::iterator it = table.begin(); it != table.end(); it++){
				if(it->second.linkNum == linkNum){
					table.erase(it);
				}
			}
		}
		else if( command == UP){
			//cout <<  "update up";
			forwardEntry_t entry;
			entry.linkNum = linkNum;
			entry.cost = 1;
			table[(node.Links_(linkNum - 1)).remoteVIP] = entry;
			send(node, RIP_REQUEST);
		}
	}

	else{
		uint16_t entriesNum;
		memcpy(&entriesNum, payload + 2, 2);
		entriesNum = ntohs(entriesNum);

		entry_t entries[entriesNum];
		memcpy(&entries, payload + 4, payloadLen - 4);

		std::set<uint32_t> newList;
		std::set<uint32_t> originList;
        for (std::map<in_addr_t, forwardEntry_t>::iterator it = table.begin(); it != table.end(); it++) {
            if(it->second.linkNum == linkNum){
                originList.insert(it->first);
            }
        }

		for(int i = 0; i < entriesNum; i++){
			entries[i].cost = ntohl(entries[i].cost);
			if (entries[i].cost == INFINITY || node.dest_check(entries[i].address)) continue;
			newList.insert(entries[i].address);
			std::map<in_addr_t, forwardEntry_t>::iterator it = table.find(entries[i].address);

			if(it == table.end()){
				forwardEntry_t entry;
				entry.linkNum = linkNum;
				entry.cost = entries[i].cost + 1;
				table[entries[i].address] = entry;
			//	cond = true;
			}
			else{
				if(it->second.linkNum == linkNum) it->second.cost = entries[i].cost + 1;
				else if(it->second.cost > (entries[i].cost + 1)){
					it->second.cost = entries[i].cost + 1;
					it->second.linkNum = linkNum;
			//		cond = true;
				}
			}
		}

		for(std::set<uint32_t>::iterator it = originList.begin(); it != originList.end(); it++){
			if(newList.find(*it) == newList.end()){
				table.erase(*it);
				//cond = true;
			}
		}
	}
	pthread_mutex_unlock(&mut_tmp);
//	if(cond){
//		std::cout << "update forward table" << std::endl;
//		send(node, RIP_RESPONSE);
//	}
}

int forwardTable::find_link_num(const in_addr_t & dest) {
	std::map<in_addr_t, forwardEntry_t>::iterator it = table.find(dest);
    if (it != table.end())
        return it->second.linkNum;
    return 0;
}

void forwardTable::print() {
    // respond to "route" command
    for (std::map<in_addr_t, forwardEntry_t>::iterator it = table.begin(); it != table.end(); it++) {
        printIp(it->first) << " " << it->second.linkNum << " " << it->second.cost << std::endl;
    }
}



#endif






