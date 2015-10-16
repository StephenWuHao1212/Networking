#ifndef __TABLE_H__
#define __TABLE_H__

#include <map>
#include <vector>
#include <set>

#include "node.h"
#include "print.h"

struct forwardEntry_t{
	int linkNum;
	int cost;
};

pthread_mutex_t table_mutex;

//const int RIP_REQUEST  = 1;
//const int RIP_RESPONSE = 2;
//
//static const int UP      = 1;
//static const int DOWN    = 2;
//static const int NO_RESPOND = 3;
class Node;
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
            // print_ip(ent.address) << ", " << ntohl(ent.cost) << endl;
            *(struct entry_t*)(payload + sizeof(uint16_t) * 2 + sizeof(entry_t) * i) = entry;
            i++;
        }
        for (int j = 0; j < node.Links_().size(); j++) {
            struct entry_t entry;
            entry.cost = htonl(0);
            entry.address = node.Links_(j).localVIP;
            
            // print_ip(ent.address) << ", " << ent.cost << endl;

            *(struct entry_t*)(payload + sizeof(uint16_t) * 2 + sizeof(entry_t) * i) = entry;
            i++;
        }
	}
	return payload;
}

void forwardTable::update(Node & node, int command, int linkNum, char * payload, uint32_t payloadLen){
	pthread_mutex_lock(&table_mutex);
	int cond = false;
	if(payload == NULL && (command == DOWN || command == NO_RESPOND)){
		for(std::map<in_addr_t, forwardEntry_t>::iterator it = table.begin(); it != table.end(); it++){
			if(it->second.linkNum == linkNum){
				table.erase(it);
			}
		}
	}
	else if(payload == NULL && command == UP){
		forwardEntry_t entry;
		entry.linkNum = linkNum;
		entry.cost = 1;
		table[(node.Links_(linkNum)).remoteVIP] = entry;
		send(node, RIP_REQUEST);
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
				cond = true;
			}
			else{
				if(it->second.linkNum == linkNum) it->second.cost = entries[i].cost + 1;
				else if(it->second.cost > (entries[i].cost + 1)){
					it->second.cost = entries[i].cost + 1;
					it->second.linkNum = linkNum;
					cond = true;
				}
			}
		}

		for(std::vector<uint32_t>::iterator it = originList.begin(); it != originList.end(); it++){
			if(newList.find(*it) == newList.end()){
				table.erase(*it);
				cond = true;
			}
		}
	}
	pthread_mutex_unlock(&table_mutex);
	if(cond){
		std::cout << "update forward table" << std::endl;
		send(node, RIP_RESPONSE);
	}
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
