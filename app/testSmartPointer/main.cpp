#include <iostream>
#include "SSMsgQ.h"
#include <unistd.h>
#include "DefaultMutex.h"

SSMsgQ m_msgQ;
DefaultMutex m_pushLock;
DefaultMutex m_getLock;
unsigned long long m_pushCount = 0;
unsigned long long m_getCount = 0;

static void* thread_pushMsg(void *content)
{
    while (1)
    {
        SmartPointer<TestingMsg> msg = MakeSmartPointer<TestingMsg>();
        m_msgQ.AddMsg(msg);

        m_pushLock.Lock();
        m_pushCount++;
        m_pushLock.Unlock();

        while (m_msgQ.GetMsgNum() >= 500000)
            usleep(10000); // 10 msec
    }
    return NULL;
}

static void* thread_getMsg(void *content)
{
    while (1)
    {
        SmartPointer<TestingMsg> msg;
        m_msgQ.GetMsg(msg);

        m_getLock.Lock();
        m_getCount++;
        m_getLock.Unlock();
    }
    return NULL;
}

static void* thread_flushQ(void *content)
{
    while (1)
    {
        std::cout << "Before Q size: " << m_msgQ.GetMsgNum() << std::endl;
        m_msgQ.Flush();
        usleep(1000000); // 1 sec
    }
    return NULL;
}

int main(int argc, char *argv[])
{
    // std::cout << "Before make smartPointer" << std::endl;

    // SmartPointer<TestingMsg> msg = MakeSmartPointer<TestingMsg>();

    // std::cout << "After make smartPointer" << std::endl;

    // msg->SetNumber(10);

    // std::cout << "Before Add message" << std::endl;
    // m_msgQ.AddMsg(msg);
    // std::cout << "After Add message" << std::endl;

    // SmartPointer<TestingMsg> msg002;
    // std::cout << "Before Get message" << std::endl;
    // m_msgQ.GetMsg(msg002);
    // std::cout << "After Get message" << std::endl;

    pthread_t pushThread, getThread, flushThread;
    int dummy;
    pthread_create(&pushThread, NULL, &thread_pushMsg, (void *)&dummy);
    pthread_create(&getThread, NULL, &thread_getMsg, (void *)&dummy);
    pthread_create(&flushThread, NULL, &thread_flushQ, (void *)&dummy);

    while (1)
    {
        std::cout << "Q size: " << m_msgQ.GetMsgNum() << std::endl;
        m_pushLock.Lock();
        std::cout << "push number: " << m_pushCount << std::endl;
        m_pushLock.Unlock();

        m_getLock.Lock();
        std::cout << "get number: " << m_getCount << std::endl;
        m_getLock.Unlock();
        usleep(1000000); // 1 sec
    }
    return 0;
}
