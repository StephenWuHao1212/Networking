#ifndef IPSUM_H
#define IPSUM_H

//do an ip checksum on a generic block of memory
//for IP, len should always be the size of the ip header (sizeof (struct ip))
#include <inttypes.h>

uint16_t ip_sum(char* packet, uint16_t len);

#endif
