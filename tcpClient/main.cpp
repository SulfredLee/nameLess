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
    TCPCast tcpClient;
    if (tcpClient.InitComponent("192.168.0.110", 0, true) == TCPCast::TCPStatus::SUCCESS)
    {
        sendData.resize(4);
        recvData.resize(4);
        if (tcpClient.Connect("192.168.0.110", 7788) == TCPCast::TCPStatus::SUCCESS)
        {
            int count = 2000;
            while (true)
            {
                int byteRecv = 0;
                TCPCast::TCPStatus retStatus = tcpClient.ClientRecv(recvData, byteRecv);
                if (retStatus == TCPCast::TCPStatus::SUCCESS && byteRecv > 0)
                {
                    int countRecv;
                    memcpy(&countRecv, &recvData[0], sizeof(int));
                    std::cout << "Received count: " << countRecv << std::endl;
                }

                memcpy(&sendData[0], &count, sizeof(int));
                retStatus = tcpClient.ClientSend(sendData, sizeof(int));
                if (retStatus == TCPCast::TCPStatus::SUCCESS)
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
    }
    return 0;
}
