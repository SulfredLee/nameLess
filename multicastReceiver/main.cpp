#include <iostream>
#include <vector>
#include <string>

#include "multicast.h"

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
                    std::copy(receivedData.begin(), receivedData.begin() + sizeof(int), &count);
                    std::cout << "Received from " << fromAddress << ":" << fromPort << " count: " << count << std::endl;
                }
            }
        }
        MCast.Stop();
    }
    return 0;
}
