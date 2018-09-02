#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Expert Advisor do scapling by comparing trend from different time frame"

#define EXPERT_MAGIC_FIRST 337866   // MagicNumber of the expert, for the first TP section
#define EXPERT_MAGIC_SECOND 336866   // MagicNumber of the expert, for the second TP section

input double Lots      = 0.01;

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
struct Margin
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
struct CheckRange
{
    int m_trendRange; // a range to find a trend
    int m_existRange; // a range to confirm a trend
};

int hEMA_5M_8P, hEMA_5M_13P, hEMA_5M_21P; // hEMA_5M_21P: indicator EMA, 5 minute, 21 period
int hEMA_1H_8P, hEMA_1H_21P; // hEMA_1H_8P: indicator EMA, 1 hour, 8 period
double EMA_5M_8P[], EMA_5M_13P[], EMA_5M_21P[];
double EMA_1H_8P[], EMA_1H_21P[];
int EMA_5M_len, EMA_1H_len;
int SLPipe, TPPipe;
int SLPoint, TPPoint;
bool isWaiting;
Margin BigTrendMargin, SmallTrendMargin;
int orderSearchPeriod;
int historyDealTotalPre, historyDealTotalCur;
CheckRange bigCheckRange, smallCheckRange;
int orderScan;

void DebugPrintRequest(const MqlTradeRequest& inRequest)
{
    PrintFormat("action: %d, type: %d, price: %f, sl: %f, tp: %f, magic: %d, symbol: %s, volume: %f",
                inRequest.action,
                inRequest.type,
                inRequest.price,
                inRequest.sl,
                inRequest.tp,
                inRequest.magic,
                inRequest.symbol,
                inRequest.volume);
}
string DebugPrintTrend(const TREND_TYPE& inTrend)
{
    if (inTrend == BUY_TREND)
        return "BUY_TREND";
    else if (inTrend == SELL_TREND)
        return "SELL_TREND";
    else
        return "NO_TREND";
}
string DebugPrintBool(bool inBool)
{
    if (inBool)
        return "TRUE";
    else
        return "FALSE";
}
void DebugPrint_1H_EMA()
{
    string line = "EMA_1H_21P:";
    for (int i = 0; i < bigCheckRange.m_trendRange; i++)
        line += " " + DoubleToString(EMA_1H_21P[i]);
    line += " EMA_1H_8P:";
    for (int i = 0; i < bigCheckRange.m_trendRange; i++)
        line += " " + DoubleToString(EMA_1H_8P[i]);
    PrintFormat(line);
}
void DebugPrint_1H_Bar()
{
    string line = "High:";
    for (int i = bigCheckRange.m_existRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iHigh(Symbol(), PERIOD_H1, i));
    line += " Low:";
    for (int i = bigCheckRange.m_existRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iLow(Symbol(), PERIOD_H1, i));
    PrintFormat(line);
}
void DebugPrint_5M_EMA()
{
    string line = "EMA_5M_21P:";
    for (int i = 0; i < smallCheckRange.m_trendRange; i++)
        line += " " + DoubleToString(EMA_5M_21P[i]);
    PrintFormat(line);
}
void DebugPrint_5M_Bar()
{
    string line = "High:";
    for (int i = smallCheckRange.m_existRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iHigh(Symbol(), PERIOD_M5, i));
    line += " Low:";
    for (int i = smallCheckRange.m_existRange - 1; i >= 0; i--)
        line += " " + DoubleToString(iLow(Symbol(), PERIOD_M5, i));
    PrintFormat(line);
}
bool isMinStart()
{
    datetime curTimeLocal = TimeCurrent();
    MqlDateTime cur;
    TimeToStruct(curTimeLocal, cur);
    if (cur.sec == 0)
        return true;
    else
        return false;
}
void setMargin(Margin& trendMargin, int pipe)
{
    if (Digits() ==  5)
        trendMargin.m_Point = pipe * 10;
    else
        trendMargin.m_Point = pipe;

    trendMargin.m_Price = NormalizeDouble(trendMargin.m_Point * Point(), Digits());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
{
    PrintFormat("OnInit()");

    EMA_1H_len = 5;
    EMA_5M_len = 9;

    bigCheckRange.m_trendRange = 4; // range is 4 hours
    bigCheckRange.m_existRange = 3; // range is 3 hours
    smallCheckRange.m_trendRange = 4; // range is 20 minutes
    smallCheckRange.m_existRange = 3; // range is 15 minutes

    orderScan = 5;

    SLPipe = 10;
    TPPipe = 20;
    if (Digits() == 5)
    {
        SLPoint = SLPipe * 10;
        TPPoint = TPPipe * 10;
    }
    else
    {
        SLPoint = SLPipe;
        TPPoint = TPPipe;
    }

    hEMA_5M_21P = iMA(Symbol(), PERIOD_M5, 21, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(EMA_5M_21P, EMA_5M_len);
    hEMA_5M_13P = iMA(Symbol(), PERIOD_M5, 13, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(EMA_5M_13P, EMA_5M_len);
    hEMA_5M_8P = iMA(Symbol(), PERIOD_M5, 8, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(EMA_5M_8P, EMA_5M_len);
    hEMA_1H_21P = iMA(Symbol(), PERIOD_H1, 21, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(EMA_1H_21P, EMA_1H_len);
    hEMA_1H_8P = iMA(Symbol(), PERIOD_H1, 8, 0, MODE_EMA, PRICE_CLOSE);
    ArrayResize(EMA_1H_8P, EMA_1H_len);

    isWaiting = true;

    setMargin(BigTrendMargin, 0);
    setMargin(SmallTrendMargin, 0);

    historyDealTotalPre = 0;
    historyDealTotalCur = 0;
}
TREND_TYPE getBigTrend()
{
    TREND_TYPE result = NO_TREND;
    for (int i = 0; i < bigCheckRange.m_trendRange; i++)
    {
        if (EMA_1H_8P[i] < EMA_1H_21P[i] - BigTrendMargin.m_Price)
        {
            if (result == BUY_TREND)
                return NO_TREND;
            else
                result = SELL_TREND;
        }
        else if (EMA_1H_8P[i] > EMA_1H_21P[i] + BigTrendMargin.m_Price)
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
TREND_TYPE getSmallTrend()
{
    TREND_TYPE result = NO_TREND;
    for (int i = 0; i < smallCheckRange.m_trendRange; i++)
    {
        if (EMA_5M_8P[i] < EMA_5M_13P[i] - SmallTrendMargin.m_Price && EMA_5M_13P[i] < EMA_5M_21P[i] - SmallTrendMargin.m_Price)
        {
            if (result == BUY_TREND)
                return NO_TREND;
            else
                result = SELL_TREND;
        }
        else if (EMA_5M_8P[i] > EMA_5M_13P[i] + SmallTrendMargin.m_Price && EMA_5M_13P[i] > EMA_5M_21P[i] + SmallTrendMargin.m_Price)
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
bool isBigTrendExist(TREND_TYPE trendType)
{
    // DebugPrint_1H_EMA();
    // DebugPrint_1H_Bar();
    if (trendType == BUY_TREND)
    {
        int j = bigCheckRange.m_existRange - 1;
        for (int i = 0; i < bigCheckRange.m_existRange; i++)
        {
            if (iLow(Symbol(), PERIOD_H1, j--) <= EMA_1H_8P[i])
                return false;
        }
        return true;
    }
    else if (trendType == SELL_TREND)
    {
        int j = bigCheckRange.m_existRange - 1;
        for (int i = 0; i < bigCheckRange.m_existRange; i++)
        {
            if (iHigh(Symbol(), PERIOD_H1, j--) >= EMA_1H_8P[i])
                return false;
        }
        return true;
    }
    else
        return false;
}
bool isSmallTrendExist(TREND_TYPE trendType)
{
    // DebugPrint_5M_EMA();
    // DebugPrint_5M_Bar();
    if (trendType == BUY_TREND)
    {
        int j = smallCheckRange.m_existRange - 1;
        for (int i = 0; i < smallCheckRange.m_existRange; i++)
        {
            if (iLow(Symbol(), PERIOD_M5, j--) <= EMA_5M_21P[i])
                return false;
        }
        return true;
    }
    else if (trendType == SELL_TREND)
    {
        int j = smallCheckRange.m_existRange - 1;
        for (int i = 0; i < smallCheckRange.m_existRange; i++)
        {
            if (iHigh(Symbol(), PERIOD_M5, j--) >= EMA_5M_21P[i])
                return false;
        }
        return true;
    }
    else
        return false;
}
bool isTrendMatch(TREND_TYPE& trendType)
{
    TREND_TYPE bigTrend = getBigTrend();
    TREND_TYPE smallTrend = getSmallTrend();
    bool isBigTrend = isBigTrendExist(bigTrend);
    bool isSmallTrend = isSmallTrendExist(smallTrend);
    if (isBigTrend && isSmallTrend)
    {
        PrintFormat("bigTrend: %s, %s, smallTrend: %s, %s", DebugPrintTrend(bigTrend), DebugPrintBool(isBigTrend), DebugPrintTrend(smallTrend), DebugPrintBool(isSmallTrend));
        smallTrend = trendType;

        if (smallTrend != NO_TREND && bigTrend == smallTrend)
            return true;
        else
            return false;
    }
    return false;
}
bool isOrderTriggered(TREND_TYPE trendType)
{
    if (trendType == BUY_TREND)
    {
        if (iLow(Symbol(), PERIOD_M5, 1) <= EMA_5M_8P[EMA_5M_len - 2] && iLow(Symbol(), PERIOD_M5, 1) > EMA_5M_13P[EMA_5M_len - 2])
            return true;
        else
            return false;
    }
    else if (trendType == SELL_TREND)
    {
        if (iHigh(Symbol(), PERIOD_M5, 1) >= EMA_5M_8P[EMA_5M_len - 2] && iHigh(Symbol(), PERIOD_M5, 1) < EMA_5M_13P[EMA_5M_len - 2])
            return true;
        else
            return false;
    }
    else
        return false;
}
double getSL(TREND_TYPE trendType, double referencePrice)
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
void prepareOrder(TREND_TYPE trendType, double& SLRange, double& stopPrice)
{
    if (trendType == BUY_TREND)
    {
        double high = 0;
        for (int i = 2; i < 2 + orderScan; i++)
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
        for (int i = 2; i < 2 + orderScan; i++)
        {
            if (iLow(Symbol(), PERIOD_M5, i) < low)
                low = iLow(Symbol(), PERIOD_M5, i);
        }
        stopPrice = low;
        SLRange = getSL(trendType, iHigh(Symbol(), PERIOD_M5, 1)) - stopPrice;
    }
}
MqlTradeRequest makeRequest(TREND_TYPE trendType, double SLRange, double stopPrice)
{
    MqlTradeRequest request;
    ZeroMemory(request);
    request.action = TRADE_ACTION_PENDING; // TRADE_ACTION_DEAL;
    request.type   = ORDER_TYPE_BUY_STOP;
    request.price  = stopPrice;
    request.magic  = EXPERT_MAGIC_FIRST;
    request.symbol = Symbol();
    request.volume = Lots;
    if (trendType == BUY_TREND)
    {
        request.sl     = stopPrice - SLRange;
        request.tp     = stopPrice + SLRange;
    }
    else if (trendType == SELL_TREND)
    {
        request.sl     = stopPrice + SLRange;
        request.tp     = stopPrice - SLRange;
    }
    else
        ZeroMemory(request);
    return request;
}
void tailingPosition()
{
}
// void startSecondTPSection()
// {
//     historyDealTotalPre = historyDealTotalCur;
//     historyDealTotalCur = HistoryDealsTotal();
//     if (historyDealTotalCur > historyDealTotalPre)
//     {
//         for (int i = 0; i < historyDealTotalCur - historyDealTotalPre; i++)
//         {
//             ulong deal_ticket = HistoryDealGetTicket(i);
//             ulong order_ticket = HistoryDealGetInteger(deal_ticket, DEAL_ORDER);
//         }
//     }
// }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
    bool isStart = isMinStart();
    if (isWaiting && isStart)
    {
        isWaiting = false;
        CopyBuffer(hEMA_5M_21P, 0, 0, EMA_5M_len, EMA_5M_21P);
        CopyBuffer(hEMA_5M_13P, 0, 0, EMA_5M_len, EMA_5M_13P);
        CopyBuffer(hEMA_5M_8P, 0, 0, EMA_5M_len, EMA_5M_8P);
        CopyBuffer(hEMA_1H_21P, 0, 0, EMA_1H_len, EMA_1H_21P);
        CopyBuffer(hEMA_1H_8P, 0, 0, EMA_1H_len, EMA_1H_8P);

        TREND_TYPE trendType;
        if (isTrendMatch(trendType) && isOrderTriggered(trendType))
        {
            double SLRange, stopPrice; // stopPrice: buy/sell stop price
            prepareOrder(trendType, SLRange, stopPrice);
            MqlTradeRequest request = makeRequest(trendType, SLRange, stopPrice);
            DebugPrintRequest(request);
            MqlTradeResult result;
            ZeroMemory(result);

            //--- send the request
            if(!OrderSend(request,result))
                PrintFormat("OrderSend error %d", GetLastError());     // if unable to send the request, output the error code
            //--- information about the operation
            PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);
        }
    }
    if (!isStart)
        isWaiting = true;

    tailingPosition();
    // startSecondTPSection();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    IndicatorRelease(hEMA_5M_21P);
    ArrayFree(EMA_5M_21P);
    IndicatorRelease(hEMA_5M_13P);
    ArrayFree(EMA_5M_13P);
    IndicatorRelease(hEMA_5M_8P);
    ArrayFree(EMA_5M_8P);
    IndicatorRelease(hEMA_1H_21P);
    ArrayFree(EMA_1H_21P);
    IndicatorRelease(hEMA_1H_8P);
    ArrayFree(EMA_1H_8P);
}
//+------------------------------------------------------------------+
