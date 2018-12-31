#include "playerMsgQ.h"
#include "Logger.h"

playerMsgQ::playerMsgQ()
{
    m_totalMsgSizeLimit = 0;
    m_totalMsgSize = 0;
    pthread_cond_init(&m_cond, NULL);
}

playerMsgQ::~playerMsgQ()
{
    pthread_cond_destroy(&m_cond);
}

void playerMsgQ::InitComponent(int totalMsgSizeLimit)
{
    DefaultLock lock(&m_mutex);
    m_totalMsgSizeLimit = totalMsgSizeLimit;
}

bool playerMsgQ::AddMsg(std::shared_ptr<PlayerMsg_Base> msg)
{
    DefaultLock lock(&m_mutex);
    bool ret = false;
    if (m_totalMsgSize + msg->GetMsgSize() > m_totalMsgSizeLimit)
    {
        LOGMSG_ERROR("MsgSize in queue: %u, MsgSize: %u, Limit: %u", m_totalMsgSize, msg->GetMsgSize(), m_totalMsgSizeLimit);
        ret = false;
    }
    else
    {
        m_msgQ.push(msg);
        m_totalMsgSize += msg->GetMsgSize();
        pthread_cond_signal(&m_cond);
        ret = true;
    }
    return ret;
}

void playerMsgQ::GetMsg(std::shared_ptr<PlayerMsg_Base>& msg)
{
    pthread_mutex_lock(m_mutex.GetMutex());
    while (m_msgQ.size() == 0)
    {
        pthread_cond_wait(&m_cond, m_mutex.GetMutex());
    }
    msg = m_msgQ.front();
    m_msgQ.pop();
    m_totalMsgSize -= msg->GetMsgSize();
    pthread_mutex_unlock(m_mutex.GetMutex());
}

int playerMsgQ::GetMsgNum()
{
    DefaultLock lock(&m_mutex);
    return m_msgQ.size();
}

int playerMsgQ::GetTotalMsgSize()
{
    DefaultLock lock(&m_mutex);
    return m_totalMsgSize;
}
