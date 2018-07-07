#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <unistd.h>

#include "multicast.h"

int main(int argc, char* argv[])
{
    std::vector<char> sendData;
    std::string toAddress;
    Multicast MCast;

    if (MCast.InitComponent("192.168.0.110", 6000) == Multicast::MCStatus::SUCCESS)
    {
        sendData.resize(4);
        toAddress = "225.1.32.28";
        int count = 0;
        while(true)
        {
            int* p = &count;
            std::copy(p, p + 1, sendData.begin());
            Multicast::MCStatus retStatus = MCast.Send(toAddress, sendData);
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
        MCast.Stop();
    }

    return 0;
}
