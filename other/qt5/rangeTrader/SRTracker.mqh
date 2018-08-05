#property copyright "Copyright 2018, Damage Company"

#include "LimitOrder.mqh"

class SRTracker
{
private:
    LimitOrder m_curLimitStack[];
    int m_curLimitStack_len;
    int m_nextStack_Idx; // used when push a new order
    LimitOrder m_stagingStack[]; // order in this stack is waiting for pushing to server
    int m_stagingStack_len;
    int m_lastStagingStack_Idx;
    LimitOrder m_curPlacedStack[]; // here sotred the orders which have been sent to the server
    int m_curPlacedStack_len;
    int m_curPlacedStack_Idx;
    LimitOrder m_hitOrder;
public:
    SRTracker()
    {
        Reset();
    }

    ~SRTracker()
    {
        ArrayFree(m_curLimitStack);
        ArrayFree(m_stagingStack);
        ArrayFree(m_curPlacedStack);
    }

    void InitComponent(int orderStack_len);

    bool AddOrder(const LimitOrder& inOrder);
    int IsLimit_Hit(const double& lastPrice);
    void MakeAnOrder(int Idx);
    bool HasNextOrder();
    LimitOrder GetNextLimitOrder();
    int IsTP_SL_Hit(const double& lastPrice);
    bool IsEmptyOrder();
    void ReFillOrder();
    void Reset();
private:
    void RemoveFromArray(LimitOrder& array[], int Idx, int array_len);
};

void SRTracker::InitComponent(int orderStack_len)
{
    m_curLimitStack_len = orderStack_len;

    ArrayResize(m_curLimitStack, m_curLimitStack_len);
    ArrayResize(m_stagingStack, m_curLimitStack_len); // the maximum size of the stagingStack is equal to total limit stack
    ArrayResize(m_curPlacedStack, m_curLimitStack_len); // the maximum size of the stagingStack is equal to total limit stack
}

bool SRTracker::AddOrder(const LimitOrder& inOrder)
{
    if (m_nextStack_Idx < m_curLimitStack_len)
    {
        m_curLimitStack[m_nextStack_Idx++] = inOrder;
        return true;
    }
    else
        return false;
}

int SRTracker::IsLimit_Hit(const double& lastPrice)
{
    for (int i = 0; i < m_curLimitStack_len; i++)
    {
        if (m_curLimitStack[i].m_price == lastPrice)
            return i;
    }
    return -1;
}

int SRTracker::IsTP_SL_Hit(const double& lastPrice)
{
    for (int i = 0; i < m_curPlacedStack_len; i++)
    {
        if (m_curPlacedStack[i].m_TP == lastPrice || m_curPlacedStack[i].m_SL == lastPrice)
        {
            m_hitOrder = m_curPlacedStack[i];
            RemoveFromArray(m_curPlacedStack, i, m_curPlacedStack_len--);
            return i;
        }
    }
    return -1;
}

void SRTracker::MakeAnOrder(int Idx)
{
    if (m_stagingStack_len < m_curLimitStack_len)
    {
        m_stagingStack[m_stagingStack_len++] = m_curLimitStack[Idx];
        m_lastStagingStack_Idx = m_stagingStack_len - 1;
    }
    else
    {
        PrintFormat("MakeAnOrder: not enough space for new order. m_stagingStack_len: %d, m_curLimitStack_len: %d", m_stagingStack_len, m_curLimitStack_len);
    }
}

bool SRTracker::HasNextOrder()
{
    return m_stagingStack_len > 0 ? true : false;
}

LimitOrder SRTracker::GetNextLimitOrder()
{
    // get order
    LimitOrder order = m_stagingStack[m_lastStagingStack_Idx--];
    m_stagingStack_len--;

    // record the order that pushed
    if (m_curPlacedStack_len <= m_curLimitStack_len)
    {
        m_curPlacedStack[m_curPlacedStack_Idx++] = order;
        m_curPlacedStack_len++;
    }
    return order;
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
    return m_curPlacedStack_len <= 0 ? true : false;
}

void SRTracker::ReFillOrder()
{
    if (m_stagingStack_len < m_curLimitStack_len)
    {
        m_stagingStack[m_stagingStack_len++] = m_hitOrder;
        m_lastStagingStack_Idx = m_stagingStack_len - 1;
    }
    else
    {
        PrintFormat("ReFillOrder: not enough space for new order. m_stagingStack_len: %d, m_curLimitStack_len: %d", m_stagingStack_len, m_curLimitStack_len);
    }
}

void SRTracker::Reset()
{
    // same as constructor
    m_stagingStack_len = 0; // at the begining we have an empty stagingStack
    m_curPlacedStack_len = 0;

    m_nextStack_Idx = 0;
    m_lastStagingStack_Idx = 0;
    m_curPlacedStack_Idx = 0;
}
