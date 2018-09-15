#property copyright "Copyright 2018, Damage Company"

#include "LimitOrder.mqh"
#include "../../Include/DCUtil/Logger.mqh"

#define EPSILON 0.00000000001

enum ORDER_HIT_TYPE
{
    TP_HIT = 0,
    SL_HIT = 1,
};

class SRTracker
{
private:
    int m_orderStatck_len;
    LimitOrder m_curLimitStack[];
    int m_curLimitStack_len;
    LimitOrder m_stagingStack[]; // order in this stack is waiting for pushing to server
    int m_stagingStack_len;
    LimitOrder m_ActivatedStack[]; // here sotred the orders which have been sent to the server
    int m_ActivatedStack_len;
    LimitOrder m_hitOrder;
    Logger* m_Logger;
    string m_LogLine;
public:
    SRTracker()
    {
        Reset();
    }

    ~SRTracker()
    {
        ArrayFree(m_curLimitStack);
        ArrayFree(m_stagingStack);
        ArrayFree(m_ActivatedStack);
    }

    void InitComponent(int orderStack_len, Logger* gLogger);

    bool AddOrder(const LimitOrder& inOrder);
    int IsLimit_Hit(const double& lastPrice);
    void MakeAnOrder(int Idx);
    bool HasNextOrder();
    LimitOrder GetNextLimitOrder();
    LimitOrder GetHitOrder();
    int IsTP_SL_Hit(const double& lastPrice, ORDER_HIT_TYPE& outHitType);
    bool IsEmptyOrder();
    void ReFillOrder();
    void Reset();
    void RefreshOrder();
    void ActivateOrder(int Idx);
    void RemoveLimitOrder();

    void DebugPrint();
private:
    void RemoveFromArray(LimitOrder& array[], int Idx, int array_len);
    bool EqualDoubles(double d1,double d2,double epsilon);
};

void SRTracker::InitComponent(int orderStack_len, Logger* gLogger)
{
    m_orderStatck_len = orderStack_len;
    Reset();

    ArrayResize(m_curLimitStack, m_orderStatck_len);
    ArrayResize(m_stagingStack, m_orderStatck_len); // the maximum size of the stagingStack is twice of current limit stack, since we have to handle clear order
    ArrayResize(m_ActivatedStack, m_orderStatck_len); // the maximum size of the stagingStack is equal to total limit stack

    m_Logger = gLogger;
}

bool SRTracker::AddOrder(const LimitOrder& inOrder)
{
    if (m_curLimitStack_len < m_orderStatck_len)
    {
        m_curLimitStack[m_curLimitStack_len++] = inOrder;
        return true;
    }
    else
        return false;
}

int SRTracker::IsLimit_Hit(const double& lastPrice)
{
    for (int i = 0; i < m_ActivatedStack_len; i++)
    {
        if (EqualDoubles(m_ActivatedStack[i].m_price, lastPrice, EPSILON))
            return -1;
    }
    for (int i = 0; i < m_curLimitStack_len; i++)
    {
        if (EqualDoubles(m_curLimitStack[i].m_price, lastPrice, EPSILON))
            return i;
    }
    return -1;
}

int SRTracker::IsTP_SL_Hit(const double& lastPrice, ORDER_HIT_TYPE& outHitType)
{
    for (int i = 0; i < m_ActivatedStack_len; i++)
    {
        if (EqualDoubles(m_ActivatedStack[i].m_TP, lastPrice, EPSILON) || EqualDoubles(m_ActivatedStack[i].m_SL, lastPrice, EPSILON))
        {
            if (EqualDoubles(m_ActivatedStack[i].m_TP, lastPrice, EPSILON))
                outHitType = TP_HIT;
            else
                outHitType = SL_HIT;
            m_hitOrder = m_ActivatedStack[i];
            m_LogLine = StringFormat("IsTP_SL_Hit: m_hitOrder: %s, lastPrice: %f", LimitOrderToString(m_hitOrder), lastPrice);
            m_Logger.PrintLog(m_LogLine);
            RemoveFromArray(m_ActivatedStack, i, m_ActivatedStack_len--);
            return i;
        }
    }
    return -1;
}

void SRTracker::MakeAnOrder(int Idx)
{
    if (m_stagingStack_len < m_orderStatck_len)
    {
        m_stagingStack[m_stagingStack_len++] = m_curLimitStack[Idx];
    }
    else
    {
        m_LogLine = StringFormat("MakeAnOrder: not enough space for new order. m_stagingStack_len: %d, m_orderStatck_len: %d", m_stagingStack_len, m_orderStatck_len);
        m_Logger.PrintLog(m_LogLine);
    }
}

bool SRTracker::HasNextOrder()
{
    return m_stagingStack_len > 0 ? true : false;
}

LimitOrder SRTracker::GetNextLimitOrder()
{
    return m_stagingStack[--m_stagingStack_len];
}

void SRTracker::RemoveFromArray(LimitOrder& array[], int Idx, int array_len)
{
    for (int i = Idx+1; i < array_len; i++)
    {
        array[i-1] = array[i];
    }
}

bool SRTracker::IsEmptyOrder()
{
    return m_ActivatedStack_len <= 0 ? true : false;
}

void SRTracker::ReFillOrder()
{
    if (m_stagingStack_len < m_orderStatck_len)
    {
        m_stagingStack[m_stagingStack_len++] = m_hitOrder;
    }
    else
    {
        m_LogLine = StringFormat("ReFillOrder: not enough space for new order. m_stagingStack_len: %d, m_orderStatck_len: %d", m_stagingStack_len, m_orderStatck_len);
        m_Logger.PrintLog(m_LogLine);
    }
}

void SRTracker::Reset()
{
    // same as constructor
    m_ActivatedStack_len = 0;
    m_curLimitStack_len = 0;
    m_stagingStack_len = 0;
}

void SRTracker::RefreshOrder()
{
    for (int i = 0; i < m_curLimitStack_len; i++)
    {
        MakeAnOrder(i);
    }
}

void SRTracker::ActivateOrder(int Idx)
{
    if (m_ActivatedStack_len < m_orderStatck_len && Idx < m_curLimitStack_len)
    {
        m_ActivatedStack[m_ActivatedStack_len++] = m_curLimitStack[Idx];
    }
}

void SRTracker::RemoveLimitOrder()
{
    for (int i = 0; i < m_curLimitStack_len; i++)
    {
        if (EqualDoubles(m_hitOrder.m_price, m_curLimitStack[i].m_price, EPSILON))
        {
            RemoveFromArray(m_curLimitStack, i, m_curLimitStack_len--);
            return;
        }
    }
}

void SRTracker::DebugPrint()
{
    m_LogLine = StringFormat("m_curLimitStack------------------------------len: %d", m_curLimitStack_len);
    m_Logger.PrintLog(m_LogLine);
    for (int i = 0; i < m_curLimitStack_len; i++)
    {
        m_LogLine = StringFormat("%s", LimitOrderToString(m_curLimitStack[i]));
        m_Logger.PrintLog(m_LogLine);
    }
    m_LogLine = StringFormat("m_stagingStack--------------------------len: %d", m_stagingStack_len);
    m_Logger.PrintLog(m_LogLine);
    for (int i = 0; i < m_stagingStack_len; i++)
    {
        m_LogLine = StringFormat("%s", LimitOrderToString(m_stagingStack[i]));
        m_Logger.PrintLog(m_LogLine);
    }
    m_LogLine = StringFormat("m_ActivatedStack--------------------------len: %d", m_ActivatedStack_len);
    m_Logger.PrintLog(m_LogLine);
    for (int i = 0; i < m_ActivatedStack_len; i++)
    {
        m_LogLine = StringFormat("%s", LimitOrderToString(m_ActivatedStack[i]));
        m_Logger.PrintLog(m_LogLine);
    }
}

LimitOrder SRTracker::GetHitOrder()
{
    return m_hitOrder;
}

bool SRTracker::EqualDoubles(double d1, double d2, double epsilon)
{
    if(epsilon < 0)
        epsilon = -epsilon;

    if (MathAbs(d1 - d2) <= epsilon)
        return true;
    else
        return false;
}
