#include "TCPCast.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <arpa/inet.h>

#include <iostream>

TCPCast::TCPCast()
{
}

TCPCast::~TCPCast()
{
    Stop();
}

TCPCast::TCPStatus TCPCast::InitComponent(const std::string& ifAddress, const short ifPort, bool isClient, const int numClients)
{
    m_ifAddress = m_ifAddress;
    m_isClient = isClient;
    if (m_isClient)
    {
        m_ifPort = 0;
        m_numClients = 0;
    }
    else
    {
        m_ifPort = ifPort;
        m_numClients = numClients;
    }
    return Start();
}

TCPCast::TCPStatus TCPCast::Start()
{
    // create TCP socket
    if ((m_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_IP)) < 0)
    {
        std::cerr << "[" << __FUNCTION__ << ":" << __LINE__ << "] errono " << strerror(errno) << std::endl;
        return TCPStatus::ERROR;
    }
    // set address and port for local address
    struct sockaddr_in local_addr;
    local_addr.sin_family = AF_INET;
    local_addr.sin_port = htons(m_ifPort);
    local_addr.sin_addr.s_addr = m_ifAddress == "" ? htonl(INADDR_ANY) : inet_addr(m_ifAddress.c_str());
    if (!m_isClient) // do binding if the socket need to listen incoming message
    {
        // bind local address
        if (bind(m_socket, (struct sockaddr *)&local_addr, sizeof(local_addr)) < 0)
        {
            std::cerr << "[" << __FUNCTION__ << ":" << __LINE__ << "] errono " << strerror(errno) << std::endl;
            return TCPStatus::ERROR;
        }
        // get ready the server
        listen(m_socket, m_numClients);
    }
    // set receive buffer size
    int recevBufSize = 1024 * 256; // 256 kByte
    setsockopt(m_socket, SOL_SOCKET, SO_RCVBUF, (char *)&recevBufSize, sizeof(recevBufSize));
    return TCPStatus::SUCCESS;
}

void TCPCast::Stop()
{
    shutdown(m_socket, 0x00);
}

TCPCast::TCPStatus TCPCast::Connect(const std::string& toAddress, const short toPort)
{
    struct sockaddr_in toInfo;
    memset(&toInfo, 0, sizeof(sockaddr_in));
    toInfo.sin_family = PF_INET;
    toInfo.sin_addr.s_addr = inet_addr(toAddress.c_str());
    toInfo.sin_port = htons(toPort);

    int err = connect(m_socket, (struct sockaddr*)&toInfo, sizeof(sockaddr_in));
    if (err == -1)
    {
        std::cerr << "[" << __FUNCTION__ << ":" << __LINE__ << "] errono " << strerror(errno) << std::endl;
        return TCPStatus::ERROR;
    }
    return TCPStatus::SUCCESS;
}

TCPCast::TCPStatus TCPCast::ClientSend(const std::vector<char>& sendMsg, const int msgLength)
{
    if (send(m_socket, &sendMsg[0], msgLength, 0) != msgLength)
    {
        std::cerr << "[" << __FUNCTION__ << ":" << __LINE__ << "] errono " << strerror(errno) << std::endl;
        return TCPStatus::ERROR;
    }
    return TCPStatus::SUCCESS;
}

TCPCast::TCPStatus TCPCast::ClientRecv(std::vector<char>& receiveBuffer, int& byteRecv)
{
    if ((byteRecv = recv(m_socket, &receiveBuffer[0], receiveBuffer.size(), MSG_WAITALL)) < 0)
    {
        std::cerr << "[" << __FUNCTION__ << ":" << __LINE__ << "] errono " << strerror(errno) << std::endl;
        return TCPStatus::ERROR;
    }
    return TCPStatus::SUCCESS;
}

int TCPCast::Accept()
{
    struct sockaddr_in clientInfo;
    int infoLength = sizeof(clientInfo);
    memset(&clientInfo, 0, infoLength);
    int clientHandle = accept(m_socket, (struct sockaddr*)&clientInfo, (socklen_t*)&infoLength);

    std::cout << "Received client " << inet_ntoa(clientInfo.sin_addr) << ":" << ntohs(clientInfo.sin_port) << std::endl;
    return clientHandle;
}

TCPCast::TCPStatus TCPCast::ServerSend(int clientHandle, const std::vector<char>& sendMsg, const int msgLength)
{
    if (send(clientHandle, &sendMsg[0], msgLength, 0) != msgLength)
    {
        std::cerr << "[" << __FUNCTION__ << ":" << __LINE__ << "] errono " << strerror(errno) << std::endl;
        return TCPStatus::ERROR;
    }
    return TCPStatus::SUCCESS;
}

TCPCast::TCPStatus TCPCast::ServerRecv(int clientHandle, std::vector<char>& receiveBuffer, int& byteRecv)
{
    if ((byteRecv = recv(clientHandle, &receiveBuffer[0], receiveBuffer.size(), MSG_WAITALL)) < 0)
    {
        std::cerr << "[" << __FUNCTION__ << ":" << __LINE__ << "] errono " << strerror(errno) << std::endl;
        return TCPStatus::ERROR;
    }
    return TCPStatus::SUCCESS;
}
