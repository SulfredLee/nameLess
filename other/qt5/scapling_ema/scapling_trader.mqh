#property copyright "Copyright 2018, Damage Company"


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
    int m_MinPeriod;
    int m_ConfirmRange;
    int m_MaxPeriod;
};
struct TrendMargin
{
    double m_Point;
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
    double m_SLPoint;
    double m_TPPoint;
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
    ulong m_magic;
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

    void InitComponent(int SRange_SPeriod, int SRange_MPeriod, int SRange_LPeriod, int LRange_SPeriod, int LRange_LPeriod, int SRange_TrendMinPeriod, int SRange_TrendConfirmPeriod, int SRange_TrendMaxPeriod, int LRange_TrendMinPeriod, int LRange_TrendConfirmPeriod, int LRange_TrendMaxPeriod, int ScanRange, int SLPipe, int TPPipe, int SRange_Margin, int LRange_Margin, double Lots, ulong magic);
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
    void prepareOrder(TREND_TYPE trendType, double& SL, double& TP, double& stopPrice);
    double getSL(TREND_TYPE trendType, double referencePrice);
    double getTP(TREND_TYPE trendType, double referencePrice);
    MqlTradeRequest makeRequest(TREND_TYPE trendType, double SL, double TP, double stopPrice);
    string DebugPrintTrend(const TREND_TYPE& inTrend);
    string DebugPrintBool(bool inBool);
    void DebugPrint_LRange_EMA();
    void DebugPrint_LRange_Bar();
    void DebugPrint_SRange_EMA();
    void DebugPrint_SRange_Bar();
    TREND_TYPE getBigTrendFromBar(int barIdx);
    bool isBigTrendTooLong(TREND_TYPE trendType);
    bool isSmallTrendTooLong(TREND_TYPE trendType);
    TREND_TYPE getSmallTrendFromBar(int barIdx);
};

void ScaplingTrader::InitComponent(int SRange_SPeriod, int SRange_MPeriod, int SRange_LPeriod, int LRange_SPeriod, int LRange_LPeriod, int SRange_TrendMinPeriod, int SRange_TrendConfirmPeriod, int SRange_TrendMaxPeriod, int LRange_TrendMinPeriod, int LRange_TrendConfirmPeriod, int LRange_TrendMaxPeriod, int ScanRange, int SLPipe, int TPPipe, int SRange_Margin, int LRange_Margin, double Lots, ulong magic)
{
    m_SRange_SPeriod = SRange_SPeriod;
    m_SRange_MPeriod = SRange_MPeriod;
    m_SRange_LPeriod = SRange_LPeriod;
    m_LRange_SPeriod = LRange_SPeriod;
    m_LRange_LPeriod = LRange_LPeriod;

    m_SRange_Description.m_MinPeriod = SRange_TrendMinPeriod;
    m_SRange_Description.m_ConfirmRange = SRange_TrendConfirmPeriod;
    m_SRange_Description.m_MaxPeriod = SRange_TrendMaxPeriod;
    m_LRange_Description.m_MinPeriod = LRange_TrendMinPeriod;
    m_LRange_Description.m_ConfirmRange = LRange_TrendConfirmPeriod;
    m_LRange_Description.m_MaxPeriod = LRange_TrendMaxPeriod;

    m_ScanRange = ScanRange;

    m_EMA_SRange_len = GetMax(GetMax(m_SRange_Description.m_MinPeriod, m_SRange_Description.m_ConfirmRange), m_SRange_Description.m_MaxPeriod);
    m_EMA_LRange_len = GetMax(GetMax(m_LRange_Description.m_MinPeriod, m_LRange_Description.m_ConfirmRange), m_LRange_Description.m_MaxPeriod);
    m_EMA_SRange_len++;
    m_EMA_LRange_len++;

    PrintFormat("m_EMA_SRange_len: %d, m_EMA_LRange_len: %d", m_SRange_Description.m_MaxPeriod, m_LRange_Description.m_MaxPeriod);

    m_SLPipe = SLPipe;
    m_TPPipe = TPPipe;

    if (Digits() == 3)
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
    PrintFormat("SRange_TrendMargin.m_Point: %f, SRange_TrendMargin.m_Price: %f, SRange_Margin: %d", m_SRange_TrendMargin.m_Point, m_SRange_TrendMargin.m_Price, SRange_Margin);
    PrintFormat("LRange_TrendMargin.m_Point: %f, LRange_TrendMargin.m_Price: %f, LRange_Margin: %d", m_LRange_TrendMargin.m_Point, m_LRange_TrendMargin.m_Price, LRange_Margin);

    m_Lots = Lots;
    m_magic = magic;
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
        double SL, TP, stopPrice; // stopPrice: buy/sell stop price
        prepareOrder(trendType, SL, TP, stopPrice);
        request = makeRequest(trendType, SL, TP, stopPrice);

        double bitPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
        double askPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
        PrintFormat("bitPrice: %f, askPrice: %f, Point: %f, Digits: %d", bitPrice, askPrice, Point(), Digits());
        return true;
    }
    return false;
}

void ScaplingTrader::SetTrendMargin(TrendMargin& trendMargin, int margin)
{
    if (Digits() ==  3)
        trendMargin.m_Point = margin * 10;
    else
        trendMargin.m_Point = margin;

    trendMargin.m_Price = NormalizeDouble(trendMargin.m_Point * Point(), Digits());
}

TREND_TYPE ScaplingTrader::getBigTrendFromBar(int barIdx)
{
    if (m_EMA_LRange_SPeriod[barIdx] < m_EMA_LRange_LPeriod[barIdx] - m_LRange_TrendMargin.m_Price)
        return SELL_TREND;
    else if (m_EMA_LRange_SPeriod[barIdx] > m_EMA_LRange_LPeriod[barIdx] + m_LRange_TrendMargin.m_Price)
        return BUY_TREND;
    else
        return NO_TREND;
}

bool ScaplingTrader::isBigTrendTooLong(TREND_TYPE trendType)
{
    for (int i = m_EMA_LRange_len - 2; i >= m_EMA_LRange_len - m_LRange_Description.m_MaxPeriod - 1; i--)
    {
        // PrintFormat("isBigTrendTooLong, i: %d", i);
        if (trendType != getBigTrendFromBar(i))
            return false;
    }
    return true;
}

bool ScaplingTrader::isSmallTrendTooLong(TREND_TYPE trendType)
{
    for (int i = m_EMA_SRange_len - 2; i >= m_EMA_SRange_len - m_SRange_Description.m_MaxPeriod - 1; i--)
    {
        // PrintFormat("isSmallTrendTooLong, i: %d", i);
        if (trendType != getSmallTrendFromBar(i))
            return false;
    }
    return true;
}

TREND_TYPE ScaplingTrader::getSmallTrendFromBar(int barIdx)
{
    if (m_EMA_SRange_SPeriod[barIdx] < m_EMA_SRange_MPeriod[barIdx] - m_SRange_TrendMargin.m_Price
        && m_EMA_SRange_MPeriod[barIdx] < m_EMA_SRange_LPeriod[barIdx] - m_SRange_TrendMargin.m_Price)
        return SELL_TREND;
    else if (m_EMA_SRange_SPeriod[barIdx] > m_EMA_SRange_MPeriod[barIdx] + m_SRange_TrendMargin.m_Price
             && m_EMA_SRange_MPeriod[barIdx] > m_EMA_SRange_LPeriod[barIdx] + m_SRange_TrendMargin.m_Price)
        return BUY_TREND;
    else
        return NO_TREND;
}

bool ScaplingTrader::isTrendMatch(TREND_TYPE& trendType)
{
    TREND_TYPE bigTrend = getBigTrend();
    TREND_TYPE smallTrend = getSmallTrend();
    bool isBigTrend = isBigTrendExist(bigTrend);
    bool isSmallTrend = isSmallTrendExist(smallTrend);
    bool isBTrendTooLong = isBigTrendTooLong(bigTrend);
    bool isSTrendTooLong = isSmallTrendTooLong(smallTrend);
    // PrintFormat("bigTrend: %s, %s, smallTrend: %s, %s", DebugPrintTrend(bigTrend), DebugPrintBool(isBigTrend), DebugPrintTrend(smallTrend), DebugPrintBool(isSmallTrend));
    if (isBigTrend && isSmallTrend && !isBTrendTooLong && !isSTrendTooLong)
    {
        // DebugPrint_LRange_EMA();
        // DebugPrint_SRange_EMA();
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
    for (int i = m_EMA_LRange_len - 2; i >= m_EMA_LRange_len - m_LRange_Description.m_MinPeriod - 1; i--)
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
    for (int i = m_EMA_SRange_len - 2; i >= m_EMA_SRange_len - m_SRange_Description.m_MinPeriod - 1; i--)
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
    int j = 2;
    if (trendType == BUY_TREND)
    {
        for (int i = m_EMA_LRange_len - 2; i >= m_EMA_LRange_len - m_LRange_Description.m_ConfirmRange - 1; i--)
        {
            if (iLow(Symbol(), PERIOD_H1, j++) <= m_EMA_LRange_LPeriod[i])
                return false;
        }
        return true;
    }
    else if (trendType == SELL_TREND)
    {
        for (int i = m_EMA_LRange_len - 2; i >= m_EMA_LRange_len - m_LRange_Description.m_ConfirmRange - 1; i--)
        {
            if (iHigh(Symbol(), PERIOD_H1, j++) >= m_EMA_LRange_LPeriod[i])
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
    int j = 2;
    if (trendType == BUY_TREND)
    {
        for (int i = m_EMA_SRange_len - 2; i >= m_EMA_SRange_len - m_SRange_Description.m_ConfirmRange - 1; i--)
        {
            if (iLow(Symbol(), PERIOD_M5, j--) <= m_EMA_SRange_LPeriod[i])
                return false;
        }
        return true;
    }
    else if (trendType == SELL_TREND)
    {
        for (int i = m_EMA_SRange_len - 2; i >= m_EMA_SRange_len - m_SRange_Description.m_ConfirmRange - 1; i--)
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

void ScaplingTrader::prepareOrder(TREND_TYPE trendType, double& SL, double& TP, double& stopPrice)
{
    if (trendType == BUY_TREND)
    {
        double high = 0;
        for (int i = 2; i < 2 + m_ScanRange; i++)
        {
            if (iHigh(Symbol(), PERIOD_M5, i) > high)
                high = iHigh(Symbol(), PERIOD_M5, i);
        }
        double askPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
        stopPrice = high < askPrice ? askPrice : high;
    }
    else if (trendType == SELL_TREND)
    {
        double low = iLow(Symbol(), PERIOD_M5, 2);
        for (int i = 2; i < 2 + m_ScanRange; i++)
        {
            if (iLow(Symbol(), PERIOD_M5, i) < low)
                low = iLow(Symbol(), PERIOD_M5, i);
        }
        double bitPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
        stopPrice = low > bitPrice ? bitPrice : low;
    }
    SL = getSL(trendType, stopPrice);
    TP = getTP(trendType, stopPrice);
}

double ScaplingTrader::getTP(TREND_TYPE trendType, double referencePrice)
{
    if (trendType == BUY_TREND)
    {
        return NormalizeDouble(referencePrice + m_TPPoint * Point(), Digits());
    }
    else if (trendType == SELL_TREND)
    {
        return NormalizeDouble(referencePrice - m_TPPoint * Point(), Digits());
    }
    else
        return 0;
}

double ScaplingTrader::getSL(TREND_TYPE trendType, double referencePrice)
{
    if (trendType == BUY_TREND)
    {
        return NormalizeDouble(referencePrice - m_SLPoint * Point(), Digits());
    }
    else if (trendType == SELL_TREND)
    {
        return NormalizeDouble(referencePrice + m_SLPoint * Point(), Digits());
    }
    else
        return 0;
}

MqlTradeRequest ScaplingTrader::makeRequest(TREND_TYPE trendType, double SL, double TP, double stopPrice)
{
    MqlTradeRequest request;
    ZeroMemory(request);
    request.action = TRADE_ACTION_PENDING; // TRADE_ACTION_DEAL;
    request.price  = stopPrice;
    request.magic  = m_magic;
    request.symbol = Symbol();
    request.volume = m_Lots;
    request.sl = SL;
    request.tp = TP;
    if (trendType == BUY_TREND)
    {
        request.type   = ORDER_TYPE_BUY_STOP;
    }
    else if (trendType == SELL_TREND)
    {
        request.type   = ORDER_TYPE_SELL_STOP;
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
    for (int i = 0; i < m_EMA_LRange_len; i++)
        line += " " + DoubleToString(m_EMA_LRange_LPeriod[i]);
    PrintFormat(line);
    line = "EMA_LRange_SPeriod:";
    for (int i = 0; i < m_EMA_LRange_len; i++)
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
    for (int i = 0; i < m_EMA_SRange_len; i++)
        line += " " + DoubleToString(m_EMA_SRange_LPeriod[i]);
    PrintFormat(line);
    line = "EMA_SRange_MPeriod";
    for (int i = 0; i < m_EMA_SRange_len; i++)
        line += " " + DoubleToString(m_EMA_SRange_MPeriod[i]);
    PrintFormat(line);
    line = "EMA_SRange_SPeriod";
    for (int i = 0; i < m_EMA_SRange_len; i++)
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
