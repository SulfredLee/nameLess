#include <iostream>

#include "Logger.h"
#include "SRCounter.h"

int main(int argc, char* argv[])
{
    if (argc < 3)
    {
        LOGMSG_ERROR("Usgae: %s data.csv outputFileName", argv[0]);
        return 0;
    }
    SRCounter counter;
    counter.InitComponent(argv[1], argv[2]);
    counter.DoCounting();
    counter.PrintResult();
    return 0;
}
