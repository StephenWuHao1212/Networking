#include <iostream>
#include <map>
#include <algorithm>

#include <pthread.h>
#include <assert.h>
#include <unistd.h>
#include <netinet/ip.h>
#include <string>

#include "print.h"
#include "node.h"
#include "ipsum.h"
#include "server_client.h"

using namespace std;
const int UPDATE_PERIOD = 5;

struct route_t{
    Node * node;
    forwardTable * table;
    route_t(Node * nodeTmp, forwardTable * tableTmp): node(nodeTmp), table(tableTmp){}
};

struct _key_t{
    u_short id;
    in_addr ip;
    _key_t(u_short idTmp, in_addr ipTmp): id(idTmp), ip(ipTmp){}
};

void driver(Node & node, forwardTable & table){
    string command;
    while(cin >> command){
    	if(command == "self"){
    		node.print_local_VIP();
    	}

    	else if(command == "up"){
    	//	cout << "repeat" << command << endl;
//    		string tmp; int linkNum;
//    		char * tmp1;
//    		int ans = sscanf(tmp.c_str(), "%s %d", tmp1, linkNum);
//			if(ans != 2){
//				cout << "command is not right" << endl;
//			}
    		int linkNum;
    		cin >> linkNum;
    		node.up(table, linkNum);
    	}
    	else if(command == "down"){
    		int linkNum;
    		cin >> linkNum;
    		node.down(table, linkNum);
    	}
    	else if(command == "send") {
    		string ip_str;
			cin >> ip_str;
			string line;
			cin.get(); getline(cin, line);

			in_addr_t destVIP = node.get_ip_from_line(ip_str.c_str());
			if(node.dest_check(destVIP)){
				cout << line << endl;
				continue;
			}

			int linkNum = table.find_link_num(destVIP);
			if(linkNum != 0){
				ip header;
				bzero(&header, sizeof(ip));
				header.ip_v = 4;
				header.ip_hl = 5;
				header.ip_ttl = 16;
				header.ip_p = 0;
				header.ip_off = 0;
				header.ip_src.s_addr = node.ipAddr();
				header.ip_dst.s_addr = destVIP;

				uint32_t payloadLen = (uint32_t)line.size() + 1;
				char payload[line.size() + 1];
				memcpy(payload, line.c_str(), payloadLen);

				node.send(linkNum, (char*)&header, payload, payloadLen);

			}
    	}
    	else if(command == "ifconfig"){
			node.ifconfig();
		}
    	else if(command == "routes") {
    		table.print();
    	}
		else{
			cout << "invalid command" << endl;
		}
    }

}

void * listen(void * route){
    Node & node = *(((route_t * )route) -> node);
    forwardTable & table = *(((route_t *)route)->table);
    Server server(node.socket_());
    while(1){
        char * packet = server.recv();
        int linkNum = node.linkNum(server.addr(), (in_port_t)server.port());
      //  assert(linkNum != 0);
        if(node.Links_(linkNum).status == DOWN){
            continue;
        }
        node.update_time(RECEIVER, table, linkNum);

        ip * header = (ip *)packet;
        char * payload = packet + header->ip_hl * 4;

        uint16_t totalLen = ntohs(header->ip_len);
        uint16_t payloadLen = totalLen - header->ip_hl * 4;

        u_int8_t protocol = header->ip_p;

        if(node.dest_check(header->ip_dst.s_addr)){
            if(protocol == 200){
                uint16_t com = ntohs(*(uint16_t*)payload);
                if(com == RIP_RESPONSE){
                    table.update(node, 0, linkNum, payload, payloadLen);
                }
                else if(com == RIP_REQUEST){
                    table.send(node, RIP_RESPONSE);
                }
                else assert(false);
            }
            else if(protocol == 0){
                cout << string(payload, payloadLen) << endl;
            }
            else assert(false);
            continue;
        }
        else{
            header->ip_ttl -= 1;
            if(header->ip_ttl == 0) continue;
            else{
                int linkNum = table.find_link_num(header->ip_dst.s_addr);
                if(linkNum != 0){
                    struct link_t nextHop = node.Links_(linkNum);
                    if(nextHop.status == UP){
                        nextHop.send((char*)header, payload, payloadLen);
                    }
                //    else if (nextHop.status == DOWN || nextHop.status == NO_RESPOND) continue;
                    else if(nextHop.status == DOWN) continue;
                    else assert(false);
                }
            }
        }
    }
    return NULL;
}

void * timer(void * router){
    unsigned time = 0;
    Node & node = *(((route_t *)router)->node);
    forwardTable & table = *(((route_t *)router)->table);
    table.send(node, RIP_REQUEST);
    while(1){
        sleep(1);
        time++;
        if(time % UPDATE_PERIOD == 0){
            table.send(node, RIP_RESPONSE);
        }
        node.update_time(TIMER, table);
    }
    return NULL;
}
int main(int argc, const char * argv[]){
    if(argc < 2) {
    	perror("input filename please");
    	exit(1);
    }
    
    Node node(argv[1]);
    
    forwardTable table(node);
    
    pthread_t recvThread;
    route_t route(&node, &table);
    pthread_create(&recvThread, 0, listen, (void *)&route);

    pthread_t timerThread;
    pthread_create(&timerThread, 0, timer, (void*)&route);

    driver(node, table);
    return 0;
}
