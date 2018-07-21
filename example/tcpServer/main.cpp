#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include <unistd.h>
#include <string.h>

#include "TCPCast.h"
#include "Logger.h"

int main(int argc, char* argv[])
{
    std::vector<char> sendData;
    std::vector<char> recvData;
    TCPCast tcpServer;
    if (tcpServer.InitComponent("192.168.0.110", 7788, false) == TCPCast::TCPStatus::SUCCESS)
    {
        int count = 0;
        sendData.resize(4);
        recvData.resize(4);
        int clientHandle = tcpServer.Accept(); // waiting for client
        while (true)
        {
            memcpy(&sendData[0], &count, sizeof(int));
            TCPCast::TCPStatus retStatus = tcpServer.ServerSend(clientHandle, &sendData[0], sizeof(int));
            if (retStatus == TCPCast::TCPStatus::SUCCESS)
            {
                LOGMSG_INFO("Send success! count: %d", count);
            }
            else
            {
                LOGMSG_ERROR("Send fail!");
            }
            count++;

            int byteRecv = 0;
            retStatus = tcpServer.ServerRecv(clientHandle, recvData, byteRecv);
            if (retStatus == TCPCast::TCPStatus::SUCCESS && byteRecv > 0)
            {
                int countRecv = -1;
                memcpy(&countRecv, &recvData[0], sizeof(int));
                LOGMSG_INFO("Received count: %d byteRecv: %d", countRecv, byteRecv);
            }
            usleep(1000000); // 1 sec
        }
    }
    else
    {
        LOGMSG_ERROR("Cannot InitComponent");
    }
    return 0;
}
