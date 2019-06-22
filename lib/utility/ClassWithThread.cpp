#include "Trader.h"
#include "tool/Logger.h"

Trader::Trader()
{
}

Trader::~Trader()
{
    stopThread();
    joinThread();
}

bool Trader::InitComponent()
{
    LOGMSG_CLASS_NAME("Trder");
    startThread();
    return true;
}

// override
void* Trader::Main()
{
    LOGMSG_INFO("IN");

    while(isThreadRunning())
    {
        if (!isThreadRunning()) break;
    }

    LOGMSG_INFO("OUT");
    return NULL;
}
