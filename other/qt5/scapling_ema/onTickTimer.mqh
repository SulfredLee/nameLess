#property copyright "Copyright 2018, Damage Company"

class onTickTimer
{
private:
    MqlDateTime m_preTime;
    MqlDateTime m_curTime;
    int m_timeRange; // Minute
public:
    onTickTimer(){}
    ~onTickTimer(){}

    void InitComponent(int timeRange);
    bool IsStart();
};

void onTickTimer::InitComponent(int timeRange)
{
    m_timeRange = timeRange;
    // init preTime
    datetime curTimeLocal = TimeCurrent();
    TimeToStruct(curTimeLocal, m_preTime);
}

bool IsStart()
{
    datetime curTimeLocal = TimeCurrent();
    TimeToStruct(curTimeLocal, m_curTime);

    if (m_preTime == m_curTime) // prevent always true for the same second
        return false;
    m_preTime = m_curTime;

    if (cur.min % m_timeRange == 0 && cur.sec == 0)
        return true;
    else
        return false;
}
