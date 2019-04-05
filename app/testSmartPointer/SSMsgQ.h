#ifndef SS_MSG_Q_H
#define SS_MSG_Q_H
#include "DefaultMutex.h"
#include "SmartPointer.h"

#include <queue>

class TestingMsg
{
 public:
    TestingMsg(){ m_number = 0; }
    ~TestingMsg(){}

    void SetNumber(int number) { m_number = number; }
    int GetNumber() { return m_number; }
 private:
    int m_number;
};

class SSMsgQ
{
 public:
    SSMsgQ();
    ~SSMsgQ();

    void InitComponent();
    bool AddMsg(SmartPointer<TestingMsg> msg);
    void GetMsg(SmartPointer<TestingMsg>& msg);
    int GetMsgNum();
    void Flush();
 private:
    DefaultMutex m_mutex;
    pthread_cond_t m_cond;
    std::queue<SmartPointer<TestingMsg> > m_msgQ;
};

#endif
