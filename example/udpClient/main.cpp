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
    UDPCast udpClient;
    if (udpClient.InitComponent("192.168.0.110", 8899, true) == UDPCast::UDPStatus::SUCCESS)
    {
        sendData.resize(4);
        recvData.resize(4);
        int count = 2000;
        while (true)
        {
            std::string serverAddress = "192.168.0.110";
            short serverPort = 7788;

            memcpy(&sendData[0], &count, sizeof(int));
            UDPCast::UDPStatus retStatus = udpClient.Send(serverAddress, serverPort, sendData, sizeof(int));
            if (retStatus == UDPCast::UDPStatus::SUCCESS)
            {
                std::cout << "Send success! count: " << count << std::endl;
            }
            else
            {
                std::cout << "Send fail!" << std::endl;
            }
            count++;

            int byteRecv = 0;
            retStatus = udpClient.Recv(serverAddress, serverPort, recvData, byteRecv);
            if (retStatus == UDPCast::UDPStatus::SUCCESS && byteRecv > 0)
            {
                int countRecv;
                memcpy(&countRecv, &recvData[0], sizeof(int));
                std::cout << "Received count: " << countRecv << std::endl;
            }
            usleep(1000000); // 1 sec
        }
    }
    return 0;
}
