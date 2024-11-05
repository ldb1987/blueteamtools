#include <stdlib.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <pthread.h>

struct args {
    int port;
    int time_s;
};

//open a socket listening on port, for time_s amount of time, then close
void *listen_me(void * data) {
    struct args * listenArgs = (struct args*)data;
    int sockfd;
    struct sockaddr_in address, temp;
    int addr_len = sizeof(address);
    int templen_t = sizeof(temp);
    int opt = 1;

    

    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        exit(EXIT_FAILURE);
    }
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt) ) < 0) {
        exit(EXIT_FAILURE);
    }

    address.sin_family=AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = 0;

    if (bind(sockfd, (struct sockaddr*)&address, (socklen_t)sizeof(address)) < 0) {
        perror("Failed to create socket");
        exit(EXIT_FAILURE);
    }

    if (listen(sockfd, 3) < 0) {
        perror("Failed to listen on socket");
        exit(EXIT_FAILURE);
    }

    if ( getsockname(sockfd, (struct sockaddr*)&temp, &templen_t) < 0) {
        perror("Failed to retrieve socket information");
        exit(EXIT_FAILURE);
    }

    listenArgs->port = ntohs(temp.sin_port);

    if (accept(sockfd, (struct sockaddr*)&address, (socklen_t*)&addr_len) > 0) {
        perror("Failed to accept connection");
        exit(EXIT_FAILURE);
    }

    close(sockfd);

    return 0;
}

void monitor(int port) {
    return;
}



//get random ephemeral port and time in seconds; pass to listen,
//then open a terminal monitoring the open port
void *socketProc(void * data) {
    pthread_t listener, monitor_th;
    struct args *listenArgs = (struct args*)malloc(sizeof(struct args));
    listenArgs->time_s = (int)(((float)rand() / (float)RAND_MAX) * 10 ) + 10;
    pthread_create(&listener, NULL, listen_me, (void *)listenArgs);
    sleep(listenArgs->time_s);
    free(listenArgs);
}

int main() {
    pthread_t threads[6];
     for (int i = 0; i < 6; i++) {
         pthread_create(&threads[i], NULL, socketProc, NULL);
     }
     for (int i = 0; i < sizeof(threads) / sizeof(threads[0]); i++) {
        pthread_join(threads[i], NULL);
     }
     


    
    return 0;
}