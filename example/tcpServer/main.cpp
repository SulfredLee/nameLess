#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include <unistd.h>
#include <string.h>

#include "TCPCast.h"

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
            TCPCast::TCPStatus retStatus = tcpServer.ServerSend(clientHandle, sendData, sizeof(int));
            if (retStatus == TCPCast::TCPStatus::SUCCESS)
            {
                std::cout << "Send success! count: " << count << std::endl;
            }
            else
            {
                std::cout << "Send fail!" << std::endl;
            }
            count++;

            int byteRecv = 0;
            retStatus = tcpServer.ServerRecv(clientHandle, recvData, byteRecv);
            if (retStatus == TCPCast::TCPStatus::SUCCESS && byteRecv > 0)
            {
                int countRecv = -1;
                memcpy(&countRecv, &recvData[0], sizeof(int));
                std::cout << "Received count: " << countRecv << " byteRecv: " << byteRecv << std::endl;
            }
            usleep(1000000); // 1 sec
        }
    }
    else
    {
        std::cerr << __FUNCTION__ << ":" << __LINE__ << " Cannot InitComponent" << std::endl;
    }
    return 0;
}
