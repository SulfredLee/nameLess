#property copyright "Copyright 2018, Damage Company"

#define EXPERT_MAGIC 337866   // MagicNumber of the expert, for the first TP section

enum TREND_TYPE
{
 BUY_TREND = 0,
 SELL_TREND = 1,
 NO_TREND = 2,
};
enum STOP_ORDER_TYPE
{
 BUY_STOP = 0,
 SELL_STOP = 1,
};
struct TrendDescription
{
    int m_TrendRange;
    int m_ConfirmRange;
};
struct TrendMargin
{
    int m_Point;
    double m_Price;
};
struct StopOrder
{
    double m_price;
    double m_TP; // take profit
    double m_SL; // stop loss
    STOP_ORDER_TYPE m_stopType;
};
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
    TrendDescription m_SRange_Description;
    TrendDescription m_LRange_Description;
    int m_ScanRange;
    TrendMargin m_SRange_TrendMargin;
    TrendMargin m_LRange_TrendMargin;
    double m_Lots;
public:
    ScaplingTrader(){}
    ~ScaplingTrader()
    {
        IndicatorRelease(m_hEMA_SRange_LPeriod);
        ArrayFree(m_EMA_SRange_LPeriod);
        IndicatorRelease(m_hEMA_SRange_MPeriod);
        ArrayFree(m_EMA_SRange_MPeriod);
        IndicatorRelease(m_hEMA_SRange_SPeriod);
        ArrayFree(m_EMA_SRange_SPeriod);
        IndicatorRelease(m_hEMA_LRange_LPeriod);
        ArrayFree(m_EMA_LRange_LPeriod);
        IndicatorRelease(m_hEMA_LRange_SPeriod);
        ArrayFree(m_EMA_LRange_SPeriod);
    }

    void InitComponent(int SRange_SPeriod, int SRange_MPeriod, int SRange_LPeriod, int LRange_SPeriod, int LRange_LPeriod, int SRange_TrendPeriod, int SRange_TrendConfirmPeriod, int LRange_TrendPeriod, int LRange_TrendConfirmPeriod, int ScanRange, int SLPipe, int TPPipe, int SRange_Margin, int LRange_Margin, double Lots);
    bool OnTick(MqlTradeRequest& request);
private:
    int GetMax(int first, int second);
    void SetTrendMargin(TrendMargin& SRange_Margin, int LRange_Margin);
    bool isTrendMatch(TREND_TYPE& trendType);
    TREND_TYPE getBigTrend();
    TREND_TYPE getSmallTrend();
    bool isBigTrendExist(TREND_TYPE trendType);
    bool isSmallTrendExist(TREND_TYPE trendType);
    bool isOrderTriggered(TREND_TYPE trendType);
    void prepareOrder(TREND_TYPE trendType, double& SLRange, double& stopPrice);
    double getSL(TREND_TYPE trendType, double referencePrice);
    MqlTradeRequest makeRequest(TREND_TYPE trendType, double SLRange, double stopPrice);
    string DebugPrintTrend(const TREND_TYPE& inTrend);
    string DebugPrintBool(bool inBool);
    void DebugPrint_LRange_EMA();
    void DebugPrint_LRange_Bar();
    void DebugPrint_SRange_EMA();
    void DebugPrint_SRange_Bar();
};

void ScaplingTrader::InitComponent(int SRange_SPeriod, int SRange_MPeriod, int SRange_LPeriod, int LRange_SPeriod, int LRange_LPeriod, int SRange_TrendPeriod, int SRange_TrendConfirmPeriod, int LRange_TrendPeriod, int LRange_TrendConfirmPeriod, int ScanRange, int SLPipe, int TPPipe, int SRange_Margin, int LRange_Margin, double Lots)
{
    m_SRange_SPeriod = SRange_SPeriod;
    m_SRange_MPeriod = SRange_MPeriod;
    m_SRange_LPeriod = SRange_LPeriod;
    m_LRange_SPeriod = LRange_SPeriod;
    m_LRange_LPeriod = LRange_LPeriod;

    m_SRange_Description.m_TrendRange = SRange_TrendPeriod;
    m_SRange_Description.m_ConfirmRange = SRange_TrendConfirmPeriod;
    m_LRange_Description.m_TrendRange = LRange_TrendPeriod;
    m_LRange_Description.m_ConfirmRange = LRange_TrendConfirmPeriod;

    m_ScanRange = ScanRange;

    m_EMA_SRange_len = GetMax(m_ScanRange + 1, GetMax(m_SRange_Description.m_TrendRange, m_SRange_Description.m_ConfirmRange));
    m_EMA_LRange_len = GetMax(m_LRange_Description.m_TrendRange, m_LRange_Description.m_ConfirmRange);

    m_SLPipe = SLPipe;
    m_TPPipe = TPPipe;

    if (Digits() == 5)
    {
        m_SLPoint = m_SLPipe * 10;
        m_TPPoint = m_TPPipe * 10;
    }
    else
    {
        m_SLPoint = m_SLPipe;
        m_TPPoint = m_TPPipe;
    }

    m_hEMA_SRange_LPeriod = iMA(Symbol(), PERIOD_M5, m_SRange_LPeriod, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(m_EMA_SRange_LPeriod, m_EMA_SRange_len);
    m_hEMA_SRange_MPeriod = iMA(Symbol(), PERIOD_M5, m_SRange_MPeriod, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(m_EMA_SRange_MPeriod, m_EMA_SRange_len);
    m_hEMA_SRange_SPeriod = iMA(Symbol(), PERIOD_M5, m_SRange_SPeriod, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(m_EMA_SRange_SPeriod, m_EMA_SRange_len);
    m_hEMA_LRange_LPeriod = iMA(Symbol(), PERIOD_H1, m_LRange_LPeriod, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(m_EMA_LRange_LPeriod, m_EMA_LRange_len);
    m_hEMA_LRange_SPeriod = iMA(Symbol(), PERIOD_H1, m_LRange_SPeriod, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(m_EMA_LRange_SPeriod, m_EMA_LRange_len);

    SetTrendMargin(m_SRange_TrendMargin, SRange_Margin);
    SetTrendMargin(m_LRange_TrendMargin, LRange_Margin);

    m_Lots = Lots;
}

int ScaplingTrader::GetMax(int first, int second)
{
    if (first < second)
        return second;
    else
        return first;
}

bool ScaplingTrader::OnTick(MqlTradeRequest& request)
{
    CopyBuffer(m_hEMA_SRange_LPeriod, 0, 0, m_EMA_SRange_len, m_EMA_SRange_LPeriod);
    CopyBuffer(m_hEMA_SRange_MPeriod, 0, 0, m_EMA_SRange_len, m_EMA_SRange_MPeriod);
    CopyBuffer(m_hEMA_SRange_SPeriod, 0, 0, m_EMA_SRange_len, m_EMA_SRange_SPeriod);
    CopyBuffer(m_hEMA_LRange_LPeriod, 0, 0, m_EMA_LRange_len, m_EMA_LRange_LPeriod);
    CopyBuffer(m_hEMA_LRange_SPeriod, 0, 0, m_EMA_LRange_len, m_EMA_LRange_SPeriod);

    TREND_TYPE trendType;
    if (isTrendMatch(trendType) && isOrderTriggered(trendType))
    {
        double SLRange, stopPrice; // stopPrice: buy/sell stop price
        prepareOrder(trendType, SLRange, stopPrice);
        request = makeRequest(trendType, SLRange, stopPrice);

        return true;
    }
    return false;
}

void ScaplingTrader::SetTrendMargin(TrendMargin& trendMargin, int margin)
{
    if (Digits() ==  5)
        trendMargin.m_Point = margin * 10;
    else
        trendMargin.m_Point = margin;

    trendMargin.m_Price = NormalizeDouble(trendMargin.m_Point * Point(), Digits());
}

bool ScaplingTrader::isTrendMatch(TREND_TYPE& trendType)
{
    TREND_TYPE bigTrend = getBigTrend();
    TREND_TYPE smallTrend = getSmallTrend();
    bool isBigTrend = isBigTrendExist(bigTrend);
    bool isSmallTrend = isSmallTrendExist(smallTrend);
    // PrintFormat("bigTrend: %s, %s, smallTrend: %s, %s", DebugPrintTrend(bigTrend), DebugPrintBool(isBigTrend), DebugPrintTrend(smallTrend), DebugPrintBool(isSmallTrend));
    if (isBigTrend && isSmallTrend)
    {
        // PrintFormat("--------Hit----------bigTrend: %s, %s, smallTrend: %s, %s", DebugPrintTrend(bigTrend), DebugPrintBool(isBigTrend), DebugPrintTrend(smallTrend), DebugPrintBool(isSmallTrend));
        trendType = smallTrend;

        if (smallTrend != NO_TREND && bigTrend == smallTrend)
            return true;
        else
            return false;
    }
    return false;
}

TREND_TYPE ScaplingTrader::getBigTrend()
{
    TREND_TYPE result = NO_TREND;
    for (int i = 0; i < m_LRange_Description.m_TrendRange; i++)
    {
        if (m_EMA_LRange_SPeriod[i] < m_EMA_LRange_LPeriod[i] - m_LRange_TrendMargin.m_Price)
        {
            if (result == BUY_TREND)
                return NO_TREND;
            else
                result = SELL_TREND;
        }
        else if (m_EMA_LRange_SPeriod[i] > m_EMA_LRange_LPeriod[i] + m_LRange_TrendMargin.m_Price)
        {
            if (result == SELL_TREND)
                return NO_TREND;
            else
                result = BUY_TREND;
        }
        else
            return NO_TREND;
    }
    return result;
}

TREND_TYPE ScaplingTrader::getSmallTrend()
{
    TREND_TYPE result = NO_TREND;
    for (int i = 0; i < m_SRange_Description.m_TrendRange; i++)
    {
        if (m_EMA_SRange_SPeriod[i] < m_EMA_SRange_MPeriod[i] - m_SRange_TrendMargin.m_Price && m_EMA_SRange_MPeriod[i] < m_EMA_SRange_LPeriod[i] - m_SRange_TrendMargin.m_Price)
        {
            if (result == BUY_TREND)
                return NO_TREND;
            else
                result = SELL_TREND;
        }
        else if (m_EMA_SRange_SPeriod[i] > m_EMA_SRange_MPeriod[i] + m_SRange_TrendMargin.m_Price && m_EMA_SRange_MPeriod[i] > m_EMA_SRange_LPeriod[i] + m_SRange_TrendMargin.m_Price)
        {
            if (result == SELL_TREND)
                return NO_TREND;
            else
                result = BUY_TREND;
        }
        else
            return NO_TREND;
    }
    return result;
}

bool ScaplingTrader::isBigTrendExist(TREND_TYPE trendType)
{
    // DebugPrint_1H_EMA();
    // DebugPrint_1H_Bar();
    int j = m_LRange_Description.m_ConfirmRange - 1;
    if (trendType == BUY_TREND)
    {
        for (int i = 0; i < m_LRange_Description.m_ConfirmRange; i++)
        {
            if (iLow(Symbol(), PERIOD_H1, j--) <= m_EMA_LRange_LPeriod[i])
                return false;
        }
        return true;
    }
    else if (trendType == SELL_TREND)
    {
        for (int i = 0; i < m_LRange_Description.m_ConfirmRange; i++)
        {
            if (iHigh(Symbol(), PERIOD_H1, j--) >= m_EMA_LRange_LPeriod[i])
                return false;
        }
        return true;
    }
    else
        return false;
}

bool ScaplingTrader::isSmallTrendExist(TREND_TYPE trendType)
{
    // DebugPrint_5M_EMA();
    // DebugPrint_5M_Bar();
    int j = m_SRange_Description.m_ConfirmRange - 1;
    if (trendType == BUY_TREND)
    {
        for (int i = 0; i < m_SRange_Description.m_ConfirmRange; i++)
        {
            if (iLow(Symbol(), PERIOD_M5, j--) <= m_EMA_SRange_LPeriod[i])
                return false;
        }
        return true;
    }
    else if (trendType == SELL_TREND)
    {
        for (int i = 0; i < m_SRange_Description.m_ConfirmRange; i++)
        {
            if (iHigh(Symbol(), PERIOD_M5, j--) >= m_EMA_SRange_LPeriod[i])
                return false;
        }
        return true;
    }
    else
        return false;
}

bool ScaplingTrader::isOrderTriggered(TREND_TYPE trendType)
{
    // PrintFormat("isOrderTriggered(), incomeTrend: %s", DebugPrintTrend(trendType));
    if (trendType == BUY_TREND)
    {
        if (iLow(Symbol(), PERIOD_M5, 1) <= m_EMA_SRange_SPeriod[m_EMA_SRange_len - 2] && iLow(Symbol(), PERIOD_M5, 1) > m_EMA_SRange_MPeriod[m_EMA_SRange_len - 2])
            return true;
        else
            return false;
    }
    else if (trendType == SELL_TREND)
    {
        if (iHigh(Symbol(), PERIOD_M5, 1) >= m_EMA_SRange_SPeriod[m_EMA_SRange_len - 2] && iHigh(Symbol(), PERIOD_M5, 1) < m_EMA_SRange_MPeriod[m_EMA_SRange_len - 2])
            return true;
        else
            return false;
    }
    else
        return false;
}

void ScaplingTrader::prepareOrder(TREND_TYPE trendType, double& SLRange, double& stopPrice)
{
    if (trendType == BUY_TREND)
    {
        double high = 0;
        for (int i = 2; i < 2 + m_ScanRange; i++)
        {
            if (iHigh(Symbol(), PERIOD_M5, i) > high)
                high = iHigh(Symbol(), PERIOD_M5, i);
        }
        stopPrice = high;
        SLRange = stopPrice - getSL(trendType, iLow(Symbol(), PERIOD_M5, 1));
    }
    else if (trendType == SELL_TREND)
    {
        double low = iLow(Symbol(), PERIOD_M5, 2);
        for (int i = 2; i < 2 + m_ScanRange; i++)
        {
            if (iLow(Symbol(), PERIOD_M5, i) < low)
                low = iLow(Symbol(), PERIOD_M5, i);
        }
        stopPrice = low;
        SLRange = getSL(trendType, iHigh(Symbol(), PERIOD_M5, 1)) - stopPrice;
    }
}

double ScaplingTrader::getSL(TREND_TYPE trendType, double referencePrice)
{
    int shiftPipe = 3;
    double shiftPrice;

    if (Digits() == 5)
        shiftPrice = shiftPipe * 10;
    else
        shiftPrice = shiftPipe;

    if (trendType == BUY_TREND)
    {
        return NormalizeDouble(referencePrice - shiftPrice, Digits());
    }
    else if (trendType == SELL_TREND)
    {
        return NormalizeDouble(referencePrice + shiftPrice, Digits());
    }
    else
        return 0;
}

MqlTradeRequest ScaplingTrader::makeRequest(TREND_TYPE trendType, double SLRange, double stopPrice)
{
    MqlTradeRequest request;
    ZeroMemory(request);
    request.action = TRADE_ACTION_PENDING; // TRADE_ACTION_DEAL;
    request.price  = stopPrice;
    request.magic  = EXPERT_MAGIC;
    request.symbol = Symbol();
    request.volume = m_Lots;
    if (trendType == BUY_TREND)
    {
        request.type   = ORDER_TYPE_BUY_STOP;
        request.sl     = stopPrice - SLRange;
        request.tp     = stopPrice + SLRange;
    }
    else if (trendType == SELL_TREND)
    {
        request.type   = ORDER_TYPE_SELL_STOP;
        request.sl     = stopPrice + SLRange;
        request.tp     = stopPrice - SLRange;
    }
    else
        ZeroMemory(request);
    return request;
}

string ScaplingTrader::DebugPrintTrend(const TREND_TYPE& inTrend)
{
    if (inTrend == BUY_TREND)
        return "BUY_TREND";
    else if (inTrend == SELL_TREND)
        return "SELL_TREND";
    else
        return "NO_TREND";
}

string ScaplingTrader::DebugPrintBool(bool inBool)
{
    if (inBool)
        return "TRUE";
    else
        return "FALSE";
}
void ScaplingTrader::DebugPrint_LRange_EMA()
{
    string line = "EMA_LRange_LPeriod:";
    for (int i = 0; i < m_LRange_Description.m_TrendRange; i++)
        line += " " + DoubleToString(m_EMA_LRange_LPeriod[i]);
    line += " EMA_LRange_SPeriod:";
    for (int i = 0; i < m_LRange_Description.m_TrendRange; i++)
        line += " " + DoubleToString(m_EMA_LRange_SPeriod[i]);
    PrintFormat(line);
}

void ScaplingTrader::DebugPrint_LRange_Bar()
{
    string line = "High:";
    for (int i = m_LRange_Description.m_ConfirmRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iHigh(Symbol(), PERIOD_H1, i));
    line += " Low:";
    for (int i = m_LRange_Description.m_ConfirmRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iLow(Symbol(), PERIOD_H1, i));
    PrintFormat(line);
}

void ScaplingTrader::DebugPrint_SRange_EMA()
{
    string line = "EMA_SRange_LPeriod:";
    for (int i = 0; i < m_SRange_Description.m_TrendRange; i++)
        line += " " + DoubleToString(m_EMA_SRange_LPeriod[i]);
    PrintFormat(line);
    line = "EMA_SRange_MPeriod";
    for (int i = 0; i < m_SRange_Description.m_TrendRange; i++)
        line += " " + DoubleToString(m_EMA_SRange_MPeriod[i]);
    PrintFormat(line);
    line = "EMA_SRange_SPeriod";
    for (int i = 0; i < m_SRange_Description.m_TrendRange; i++)
        line += " " + DoubleToString(m_EMA_SRange_SPeriod[i]);
    PrintFormat(line);
}

void ScaplingTrader::DebugPrint_SRange_Bar()
{
    string line = "High:";
    for (int i = m_SRange_Description.m_ConfirmRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iHigh(Symbol(), PERIOD_M5, i));
    line += " Low:";
    for (int i = m_SRange_Description.m_ConfirmRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iLow(Symbol(), PERIOD_M5, i));
    PrintFormat(line);
}
