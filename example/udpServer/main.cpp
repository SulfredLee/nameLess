#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include <unistd.h>
#include <string.h>

#include "UDPCast.h"
#include "Logger.h"

int main(int argc, char* argv[])
{
    std::vector<char> sendData;
    std::vector<char> recvData;
    UDPCast udpServer;
    if (udpServer.InitComponent("192.168.0.112", 7788, false) == UDPCast::UDPStatus::SUCCESS)
    {
        int count = 0;
        sendData.resize(4);
        recvData.resize(4);
        while (true)
        {
            std::string clientAddress;
            short clientPort;
            int byteRecv = 0;
            UDPCast::UDPStatus retStatus = udpServer.Recv(clientAddress, clientPort, recvData, byteRecv);
            if (retStatus == UDPCast::UDPStatus::SUCCESS && byteRecv > 0)
            {
                int countRecv = -1;
                memcpy(&countRecv, &recvData[0], sizeof(int));
                LOGMSG_INFO("Received count: %d byteRecv: %d", countRecv, byteRecv);
            }

            memcpy(&sendData[0], &count, sizeof(int));
            retStatus = udpServer.Send(clientAddress, clientPort, &sendData[0], sizeof(int));
            if (retStatus == UDPCast::UDPStatus::SUCCESS)
            {
                LOGMSG_INFO("Send success! count: %d", count);
            }
            else
            {
                LOGMSG_ERROR("Send fail!");
            }
            count++;

            usleep(1000000); // 1 sec
        }
    }
    else
    {
        LOGMSG_ERROR("Cannot InitComponent");
    }
    return 0;
}
