#property copyright "Copyright 2018, Damage Company"

class ScaplingTrader
{
private:
    int m_hEMA_SRange_SPeriod;
    int m_hEMA_SRange_MPeriod;
    int m_hEMA_SRange_LPeriod;
    int m_hEMA_LRange_SPeriod;
    int m_hEMA_LRange_LPeriod;
    double m_EMA_SRange_SPeriod[];
    double m_EMA_SRange_MPeriod[];
    double m_EMA_SRange_LPeriod[];
    double m_EMA_LRange_SPeriod[];
    double m_EMA_LRange_LPeriod[];
    int m_EMA_SRange_len;
    int m_EMA_LRange_len;
    int m_SLPipe;
    int m_TPPipe;
    int m_SLPoint;
    int m_TPPoint;
    int m_SRange_SPeriod;
    int m_SRange_MPeriod;
    int m_SRange_LPeriod;
    int m_LRange_SPeriod;
    int m_LRange_LPeriod;
public:
    ScaplingTrader(){}
    ~ScaplingTrader(){}

    void InitComponent(int SRange_SPeriod, int SRange_MPeriod, int SRange_LPeriod, int LRange_SPeriod, int LRange_LPeriod);
};

void ScaplingTrader::InitComponent(int SRange_SPeriod, int SRange_MPeriod, int SRange_LPeriod, int LRange_SPeriod, int LRange_LPeriod)
{
    m_SRange_SPeriod = SRange_SPeriod;
    m_SRange_MPeriod = SRange_MPeriod;
    m_SRange_LPeriod = SRange_LPeriod;
    m_LRange_SPeriod = LRange_SPeriod;
    m_LRange_LPeriod = LRange_LPeriod;
}
