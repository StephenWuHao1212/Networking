#ifndef _PRINT_H_
#define _PRINT_H_

#include <cstdio>
#include <string>
#include <cstdlib>
#include <iostream>
#include <arpa/inet.h>


std::ostream & printIp(in_addr_t ip) {
    
    std::cout << ip % 256;
    for (int i=0; i<3; ++i) {
        ip /= 256;
        std::cout << "." << ip % 256;
    }
    return std::cout;
    
}

std::ostream & printPort(in_port_t port) {
    std::cout << port / 256 + port % 256 * 256;
    return std::cout;
}
#endif
