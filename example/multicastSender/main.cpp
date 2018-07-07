#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include <unistd.h>
#include <string.h>

#include "MultiCast.h"

int main(int argc, char* argv[])
{
    std::vector<char> sendData;
    std::string toAddress = "225.1.32.28";
    Multicast MCast;

    if (MCast.InitComponent("192.168.0.110", 6000) == Multicast::MCStatus::SUCCESS)
    {
        sendData.resize(4);
        int count = 0;
        while(true)
        {
            memcpy(&sendData[0], &count, sizeof(int));
            Multicast::MCStatus retStatus = MCast.Send(toAddress, sendData, sizeof(int));
            if (retStatus == Multicast::MCStatus::SUCCESS)
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

    return 0;
}
