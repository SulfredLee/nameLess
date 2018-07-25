#include <iostream>
#include <thread>

#include "MsgQ_C.h"
#include "Logger.h"

#include <string.h>
#include <unistd.h>

MsgQ_C* queue = createMsgQ_C();

void thread001Fun()
{
    int i = 0;
    while (true)
    {
        char* string = new char[1024];
        memset(string, 0, 1024);
        sprintf(string, "[%s:%d] number %03d", __FUNCTION__, __LINE__, i++);
        LOGMSG_INFO("%s", string);
        pushMsgQ_C((void**)&string, queue);
        usleep(500000); // sleep 0.5 sec
    }
}

void thread002Fun()
{
    int i = 1000;
    while (true)
    {
        char* string = new char[1024];
        memset(string, 0, 1024);
        sprintf(string, "[%s:%d] number %03d", __FUNCTION__, __LINE__, i++);
        LOGMSG_INFO("%s", string);
        pushMsgQ_C((void**)&string, queue);
        usleep(1000000); // sleep 1 sec
    }
}

int main(int argc, char* argv[])
{
    std::thread thread001(thread001Fun);
    std::thread thread002(thread002Fun);
    while (true)
    {
        char* string;
        getMsgQ_C((void**)&string, queue);
        LOGMSG_INFO("%s", string);
        delete string;
    }

    freeMsgQ_C(queue);
    return 0;
}
