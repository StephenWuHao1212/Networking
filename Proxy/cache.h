/*
 * cache.c

 *
 *  Created on: Apr 11, 2015
 *      Author: ubuntu
 */

#ifndef __CACHE_H__
#define __CACHE_H__

#include <net/if.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <signal.h>
#include <unistd.h>

#define MAXBUFSIZE 102400
#define MAXARRAY 1000

struct _node{
	struct _node * next;
	struct _node * previous;

	char * key;
	char * value[MAXARRAY];
	int value_size[MAXARRAY];
	int nodesize;
	int flag;
};

typedef struct _node node_t;

struct _linkedlist{
	node_t * head;
	node_t * tail;
	int remainsize;
};

typedef struct _linkedlist linkedlist_t;


void node_ini(node_t * node, char * request, char * response[], int value_size[]);
void linkedlist_ini(linkedlist_t * ll, int size_t);
void linkedlist_add(linkedlist_t * ll, char * request_t, char * response[], int value_size[]);
void linkedlist_delete_last(linkedlist_t * ll);
void node_print(node_t * node);
void linkedlist_print(linkedlist_t * ll);
void destroy_helper(node_t * node);
void linkedlist_destroy(linkedlist_t * ll);
int linkedlist_find(linkedlist_t * ll, char *  request, char * ans[], int value_size[]);
void linkedlist_makespace(linkedlist_t * ll, int size);
void linkedlist_add_node(linkedlist_t * ll, node_t * node);



void node_ini(node_t * node, char * request, char * response[], int value_size[]){
	node->flag = 0;
	node->next = (node_t*) malloc(sizeof(node_t));
	node->next = NULL;
	node->previous = (node_t*)malloc(sizeof(node_t));
	node->previous = NULL;
	node->nodesize = 0;
	int i;
	for(i = 0; i < MAXARRAY; i++){
		if(response[i] == NULL){
			node->value_size[i] = 0;
			node->value[i] = NULL;
		}
		else{
			node->value_size[i] = value_size[i];
			node->value[i] = (char *)malloc(value_size[i]);
			memcpy(node->value[i], response[i], value_size[i]);
			node->nodesize += value_size[i] + 1;
		}
	}
	node->key = (char*)malloc(strlen(request) + 1);
	strcpy(node->key, request);
	node->nodesize += sizeof(node->next) + 3 * sizeof(int);
}

void linkedlist_ini(linkedlist_t * ll, int size_t){
	ll->head = (node_t*)malloc(sizeof(node_t));
	ll->head = NULL;
	ll->tail = (node_t*)malloc(sizeof(node_t));
	ll->tail = NULL;
	ll->remainsize = size_t - sizeof(ll);
}

void linkedlist_add_node(linkedlist_t * ll, node_t * node){
	node->flag = 0;
	assert(ll != NULL);
	assert((ll->head == NULL && ll->tail == NULL) ||
			(ll->head != NULL && ll->tail != NULL));
	if(ll->head == NULL){
		assert(node->nodesize <= ll->remainsize);
		ll->head = node;
		ll->tail = node;
		ll->remainsize -= node->nodesize;
		return;
	}

	if(ll->remainsize < node->nodesize)
		linkedlist_makespace(ll, node->nodesize);

	assert(node->nodesize <= ll->remainsize);
	ll->head->previous = node;
	node->next = ll->head;
	node->previous = NULL;
	ll->head = node;
	ll->remainsize -= node->nodesize;
	node->flag = 1;
}
void linkedlist_add(linkedlist_t * ll, char * request_t, char * response[], int value_size[]){
	printf("Add content to the cache\n");
	assert(ll != NULL);
	assert((ll->head == NULL && ll->tail == NULL) ||
			(ll->head != NULL && ll->tail != NULL));
	node_t * temp = (node_t *)malloc(sizeof(node_t));
	node_ini(temp, request_t, response, value_size);
	if(ll->head == NULL){
		assert(temp->nodesize <= ll->remainsize);
		ll->head = temp;
		ll->tail = temp;
		ll->remainsize -= temp->nodesize;
		return;
	}

	if(ll->remainsize < temp->nodesize)
		linkedlist_makespace(ll, temp->nodesize);

	assert(temp->nodesize <= ll->remainsize);
	ll->head->previous = temp;
	temp->next = ll->head;
	temp->previous = NULL;
	ll->head = temp;
	ll->remainsize -= temp->nodesize;
	temp->flag = 1;
}

void linkedlist_makespace(linkedlist_t * ll, int size){
	printf("making space for new content\n");
	while(ll->remainsize < size){
		linkedlist_delete_last(ll);
	}
}

void linkedlist_delete_last(linkedlist_t * ll){
	assert(ll != NULL);
	assert((ll->head == NULL && ll->tail == NULL) ||
			(ll->head != NULL && ll->tail != NULL));
	int i;
	i = 0;
	if(ll->tail == NULL) return;
	if(ll->tail == ll->head){
		ll->remainsize += ll->tail->nodesize;
		while(ll->tail->value[i] != NULL){
			free(ll->tail->value[i]);
			i++;
		}
		free(ll->tail->key);
		ll->head = NULL;
		ll->tail = NULL;
		return;
	}
	ll->remainsize += ll->tail->nodesize;
	assert(ll->tail->next == NULL);
	node_t * temp = ll->tail->previous;
	temp->next = NULL;
	ll->tail->previous = NULL;
	i = 0;
	while(ll->tail->value[i] != NULL){
		free(ll->tail->value[i]);
		i++;
	}
	free(ll->tail->key);
	ll->tail = temp;
}


void node_print(node_t * node){
	assert(node != NULL);
	printf("key: %d\n", node->key);
	printf("value: %s\n", node->value[0]);
	printf("       %s\n", node->value[1]);
	printf("       %s\n", node->value[2]);
	printf("       %s\n", node->value[3]);

}

void linkedlist_print(linkedlist_t * ll){
	assert(ll != NULL);
	assert((ll->head == NULL && ll->tail == NULL) ||
			(ll->head != NULL && ll->tail != NULL));
	node_t * curr = ll->head;
	int i = 0;
	while(curr != NULL){
		printf("node %d\n", i);
		node_print(curr);
		i++;
		curr = curr->next;
	}
}

void destroy_helper(node_t * node){
	if(node != NULL){
		destroy_helper(node->next);
		int i;
		i = 0;
		while(node->value[i] != NULL){
			free(node->value[i]);
			i++;
		}
		free(node);
	}
}

void linkedlist_destroy(linkedlist_t * ll){
	assert(ll != NULL);
	destroy_helper(ll->head);
}

//process the request,
//return 1: find the request in the linkedlist
//return -1: error
int linkedlist_find(linkedlist_t * ll, char *  request, char * ans[], int value_size[]){
	assert(ll != NULL);
	assert((ll->head == NULL && ll->tail == NULL) ||
			(ll->head != NULL && ll->tail != NULL));
	node_t * curr;
	curr = ll->head;
	while(curr != NULL && strcmp(curr->key, request) != 0){
		curr = curr->next;
	}
	if(curr == NULL ){
		return -1;
	}
	else if(curr->flag == 0){
		return -1;
	}
	else if(curr == ll->head || ll->head == ll->tail){
		int i;
		for(i = 0; i < MAXARRAY; i++){
			if(curr->value[i] != NULL){
				value_size[i] = curr->value_size[i];
				ans[i] = (char*)malloc(curr->value_size[i]);
				memcpy(ans[i], curr->value[i], curr->value_size[i]);
			}
			else break;
		}
		return 1;
	}
	else{
		int i;
		if(curr == ll->tail){
			ll->tail = curr->previous;
			curr->previous = NULL;
		}
		else{
			curr->previous->next = curr->next;
			curr->next->previous = curr->previous;
		}

		for(i = 0; i < MAXARRAY; i++){
			if(curr->value[i] != NULL){
				value_size[i] = curr->value_size[i];
				ans[i] = (char*)malloc(MAXBUFSIZE);
				strcpy(ans[i], curr->value[i]);
			}
			else break;
		}
		linkedlist_add_node(ll, curr);
		return 1;
	}
}




#endif
