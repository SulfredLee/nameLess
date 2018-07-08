#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include <unistd.h>
#include <string.h>

#include "UDPCast.h"

int main(int argc, char* argv[])
{
    std::vector<char> sendData;
    std::vector<char> recvData;
    UDPCast udpServer;
    if (udpServer.InitComponent("192.168.0.110", 7788, false) == UDPCast::UDPStatus::SUCCESS)
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
                std::cout << "Received count: " << countRecv << " byteRecv: " << byteRecv << std::endl;
            }

            memcpy(&sendData[0], &count, sizeof(int));
            retStatus = udpServer.Send(clientAddress, clientPort, sendData, sizeof(int));
            if (retStatus == UDPCast::UDPStatus::SUCCESS)
            {
                std::cout << "Send success! count: " << count << std::endl;
            }
            else
            {
                std::cout << "Send fail!" << std::endl;
            }
            count++;

            usleep(1000000); // 1 sec
        }
    }
    else
    {
        std::cerr << __FUNCTION__ << ":" << __LINE__ << " Cannot InitComponent" << std::endl;
    }
    return 0;
}
