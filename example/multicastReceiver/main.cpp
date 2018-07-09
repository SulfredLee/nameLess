#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include <unistd.h>
#include <string.h>

#include "MultiCast.h"
#include "Logger.h"

int main(int argc, char* argv[])
{
    std::vector<char> receivedData;
    std::string fromAddress;
    short fromPort;
    int byteRecv;
    Multicast MCast;

    if (MCast.InitComponent("192.168.0.110", 6000) == Multicast::MCStatus::SUCCESS)
    {
        MCast.JoinGroup("225.1.32.28");

        receivedData.resize(1024);
        while(true)
        {
            if (MCast.SelectRead(500, 0) == Multicast::MCStatus::READ) // wait for 500 microsecond
            {
                if (MCast.Recv(receivedData, fromAddress, fromPort, byteRecv) == Multicast::MCStatus::SUCCESS)
                {
                    int count;
                    memcpy(&count, &receivedData[0], sizeof(int));
                    LOGMSG_INFO("Received from %s:%u count: %d", fromAddress.c_str(), fromPort, count);
                }
            }
        }
    }
    return 0;
}
