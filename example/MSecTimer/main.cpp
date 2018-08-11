#include <iostream>

#include <time.h>

#include "MSecTimer.h"
#include "Logger.h"
void fooPrint()
{
    LOGMSG_INFO("Hello");
}

class Apple
{
private:
    MSecTimer m_oneSecTimer;
public:
    Apple()
        :m_oneSecTimer(1000, std::bind(&Apple::printApple, this))
    {}
    ~Apple(){}

    void printApple()
    {
        LOGMSG_INFO("Hello Apple");
    }
};

int main(int argc, char* argv[])
{
    MSecTimer oneSecTimer(1000, std::bind(&fooPrint));
    Apple apple;
    while (true)
    {
        usleep(1000000000);
    }
    return 0;
}
