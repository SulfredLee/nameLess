#include <iostream>

#include "StepCounter.h"
#include "Logger.h"

int main(int argc, char* argv[])
{
    if (argc < 4)
    {
        LOGMSG_ERROR("Usgae: %s data.csv outputFileName duration(month)", argv[0]);
        return 0;
    }
    StepCounter counter;
    counter.InitComponent(argv[1], argv[2], argv[3]);
    counter.DoCounting();
    return 0;
}
