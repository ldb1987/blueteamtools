#include <stdlib.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <pthread.h>
//open a socket listening on port, for time_s amount of time, then close
void listen_me(int time_s, int* port) {
    int sockfd;
    struct sockaddr_in address, temp;
    int socklen_t = sizeof(address);
    int templen_t = sizeof(temp);
    int opt = 1;

    

    if ((sockfd = socket(AF_INET | AF_INET6, SOCK_STREAM, 0)) < 0) {
        return -1;
    }
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt) ) < 0) {
        return -1;
    }

    address.sin_family=AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = 0;

    if (bind(sockfd, (struct sockaddr*)&address, sizeof(address)) < 0) {
        return -1;
    }

    if (listen(sockfd, 3) < 0) {
        return -1;
    }

    if ( getsockname(sockfd, &temp, &templen_t) < 0) {
        return -1;
    }

    port = temp.sin_port;

    sleep(time_s);

    close(sockfd);

    return;
}

void monitor(int port) {
    execvp("watch", "tmux tcpdump port port");
}

//get random ephemeral port and time in seconds; pass to listen,
//then open a terminal monitoring the open port
void socketProc() {
    int port;
    int time_s = ((rand() / RAND_MAX) * 600 ) * 600;
    pthread_t listener, monitor_th;
    int args = {port, time_s};
    pthread_create(&listener, NULL, &listen_me, args);
    pthread_create(&monitor_th, NULL, &monitor, &port);
    
}

int main() {
    pthread_t* threads[6];
    for (int i = 0; i < 6; i++) {
        pthread_create(threads[i], NULL, &socketProc, NULL);
    }
    
    return;
}