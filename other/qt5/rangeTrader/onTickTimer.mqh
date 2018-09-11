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
private:
    bool IsDateTimeEqual(const MqlDateTime& first, const MqlDateTime& second);
};

void onTickTimer::InitComponent(int timeRange)
{
    m_timeRange = timeRange;
    // init preTime
    datetime curTimeLocal = TimeCurrent();
    TimeToStruct(curTimeLocal, m_preTime);
}

bool onTickTimer::IsStart()
{
    datetime curTimeLocal = TimeCurrent();
    TimeToStruct(curTimeLocal, m_curTime);

    if (IsDateTimeEqual(m_preTime, m_curTime)) // prevent always true for the same second
        return false;
    m_preTime = m_curTime;

    if (m_curTime.min % m_timeRange == 0 && m_curTime.sec == 0)
        return true;
    else
        return false;
}

bool onTickTimer::IsDateTimeEqual(const MqlDateTime& first, const MqlDateTime& second)
{
    if (first.year == second.year
        && first.mon == second.mon
        && first.day == second.day
        && first.hour == second.hour
        && first.min == second.min
        && first.sec == second.sec)
        return true;
    else
        return false;
}
