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
                    LOGMSG_INFO("Received count: %d", countRecv);
                }

                memcpy(&sendData[0], &count, sizeof(int));
                retStatus = tcpClient.ClientSend(&sendData[0], sizeof(int));
                if (retStatus == TCPCast::TCPStatus::SUCCESS)
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
    }
    return 0;
}
