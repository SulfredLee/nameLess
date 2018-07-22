#include <iostream>

#include "MCastArbitrator.h"
#include "Logger.h"

#include <unistd.h>
#include <string.h>

int main(int argc, char* argv[])
{
    std::vector<char> sendData;
    std::string toAddress = "225.1.32.28";
    MCastArbitrator MCArbi;

    if (argc != 2)
    {
        LOGMSG_ERROR("Usgae: xx.exe instance");
        return -1;
    }
    short instance = atoi(argv[1]);
    if (MCArbi.InitComponent("192.168.0.112", 6000, 32, instance) == MCastArbitrator::MCArbiStatus::SUCCESS)
    {
        MCArbi.JoinGroup(toAddress);
        sendData.resize(4);
        int count = 0;
        while(true)
        {
            memcpy(&sendData[0], &count, sizeof(int));
            MCastArbitrator::MCArbiStatus retStatus = MCArbi.Send(&sendData[0], sizeof(int));
            if (retStatus == MCastArbitrator::MCArbiStatus::SUCCESS)
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

    return 0;
}
