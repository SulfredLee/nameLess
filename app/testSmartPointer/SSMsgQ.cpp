#include "SSMsgQ.h"

SSMsgQ::SSMsgQ()
{
    pthread_cond_init(&m_cond, NULL);
}

SSMsgQ::~SSMsgQ()
{
    pthread_cond_destroy(&m_cond);
}

void SSMsgQ::InitComponent()
{
}

bool SSMsgQ::AddMsg(SmartPointer<TestingMsg> msg)
{
    DefaultLock lock(&m_mutex);
    m_msgQ.push(msg);
    pthread_cond_signal(&m_cond);
    return true;
}

void SSMsgQ::GetMsg(SmartPointer<TestingMsg>& msg)
{
    pthread_mutex_lock(m_mutex.GetMutex());
    while (m_msgQ.size() == 0)
    {
        pthread_cond_wait(&m_cond, m_mutex.GetMutex());
    }
    msg = m_msgQ.front();
    msg->GetNumber();
    msg->SetNumber(10);
    msg->GetNumber();
    m_msgQ.pop();
    pthread_mutex_unlock(m_mutex.GetMutex());
}

int SSMsgQ::GetMsgNum()
{
    DefaultLock lock(&m_mutex);
    return m_msgQ.size();
}

void SSMsgQ::Flush()
{
    DefaultLock lock(&m_mutex);
    std::queue<SmartPointer<TestingMsg> > empty;
    std::swap(m_msgQ, empty);
}
