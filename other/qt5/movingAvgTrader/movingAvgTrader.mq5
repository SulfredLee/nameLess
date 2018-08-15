#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Expert Advisor places buy/sell orders"
#property description "based on moving average"

#define EXPERT_MAGIC 338866   // MagicNumber of the expert

input int    StartHour = 7;
input int    EndHour   = 19;
input double Lots      = 0.1;

int hMA_5min, hMA_10min, hMA_20min; // hMA: Moving Average indicator's handle
double MA_5min[], MA_10min[], MA_20min[];
int MA_5min_len, MA_10min_len, MA_20min_len;
int countTick;
bool isInitFinished;
bool isWaiting;
int SLPoint, TPPoint;
int SLPipe, TPPipe;
int MAPeriod;
int fileHandle;

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
void PrintDebug_MA_5min()
{
    string line = "";
    for (int i = 0; i < MA_5min_len; i++)
    {
        line += DoubleToString(MA_5min[i]) + " ";
    }
    PrintFormat("%s", line);
}
bool isBuyConfidence(bool& isBuy)
{
    for (int i = 0; i < MA_5min_len - 2; i++)
    {
        if (MA_5min[i] - MA_5min[i+1] < -0.020)
            isBuy = true;
        else
            return false;
    }
    return true;
}
bool isSellConfidence(bool& isBuy)
{
    for (int i = 0; i < MA_5min_len - 2; i++)
    {
        if (MA_5min[i] - MA_5min[i+1] > 0.020)
            isBuy = false;
        else
            return false;
    }
    return true;
}
bool isConfidence(bool& isBuy)
{
    return isBuyConfidence(isBuy) || isSellConfidence(isBuy);
}
void PrintDebug_Confidence()
{
    string line = "";
    for (int i = 0; i < MA_5min_len -1; i++)
    {
        line += DoubleToString(MA_5min[i]) + " ";
    }
    bool isBuy = false;
    PrintFormat("%s, isBuyConfidence(): %d, isSellConfidence(): %d, isBuy: %d", line, isBuyConfidence(isBuy), isSellConfidence(isBuy), isBuy);
}
void MakeABuyRequest()
{
    //--- declare and initialize the trade request and result of trade request
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    double latestAsk = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    //--- parameters of request
    request.action   = TRADE_ACTION_DEAL;                     // type of trade operation
    request.symbol   = Symbol();                              // symbol
    request.volume   = 0.1;                                   // volume of 0.1 lot
    request.type     = ORDER_TYPE_BUY;                        // order type
    request.price    = latestAsk; // price for opening
    request.sl = NormalizeDouble(latestAsk - SLPoint * Point(), Digits());
    request.tp = NormalizeDouble(latestAsk + TPPoint * Point(), Digits());
    request.deviation= 5;                                     // allowed deviation from the price
    request.magic    = EXPERT_MAGIC;                          // MagicNumber of the order
    //--- send the request
    if(!OrderSend(request, result))
        PrintFormat("OrderSend error %d", GetLastError());     // if unable to send the request, output the error code
    //--- information about the operation
    PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);
}
void MakeASellRequest()
{
    //--- declare and initialize the trade request and result of trade request
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    double latestBid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    //--- parameters of request
    request.action   = TRADE_ACTION_DEAL;                     // type of trade operation
    request.symbol   = Symbol();                              // symbol
    request.volume   = 0.1;                                   // volume of 0.2 lot
    request.type     = ORDER_TYPE_SELL;                       // order type
    request.price    = SymbolInfoDouble(Symbol(), SYMBOL_BID); // price for opening
    request.sl = NormalizeDouble(latestBid + SLPoint * Point(), Digits());
    request.tp = NormalizeDouble(latestBid - TPPoint * Point(), Digits());
    request.deviation= 5;                                     // allowed deviation from the price
    request.magic    = EXPERT_MAGIC;                          // MagicNumber of the order
    //--- send the request
    if(!OrderSend(request, result))
        PrintFormat("OrderSend error %d", GetLastError());     // if unable to send the request, output the error code
    //--- information about the operation
    PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
{
    PrintFormat("OnInit()");

    MAPeriod = 5;
    MA_5min_len = 5;
    MA_10min_len = 5;
    MA_20min_len = 5;
    countTick = 0;
    isInitFinished = false;
    isWaiting = true;
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

    hMA_5min = iMA(Symbol(), PERIOD_M1, MAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    ArrayResize(MA_5min, MA_5min_len);
    hMA_10min = iMA(Symbol(), PERIOD_M10, MAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    ArrayResize(MA_10min, MA_10min_len);
    hMA_20min = iMA(Symbol(), PERIOD_M20, MAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    ArrayResize(MA_20min, MA_20min_len);

    string outputFile = Symbol() + ".MA.csv";
    fileHandle = FileOpen("Data//" + outputFile, FILE_READ|FILE_WRITE|FILE_CSV);

    PrintFormat("SLPipe: %f, SLPoint: %f, Digits(): %d, Point(): %f", SLPipe, SLPoint, Digits(), Point());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
    bool isStart = isMinStart();
    if (isWaiting && isStart)
    {
        isWaiting = false;
        countTick++;
        CopyBuffer(hMA_5min, 0, 0, MA_5min_len, MA_5min); // MA_5min[0]: last min data, MA_5min[1]: current min data
        CopyBuffer(hMA_10min, 0, 0, MA_10min_len, MA_10min);
        CopyBuffer(hMA_20min, 0, 0, MA_20min_len, MA_20min);
        if(fileHandle != INVALID_HANDLE)
        {
            FileWrite(fileHandle, countTick, MA_5min[MA_5min_len-2], MA_10min[MA_10min_len-2], MA_20min[MA_20min_len-2]);
        }
        // bool isBuy = false;
        // if (isConfidence(isBuy))
        // {
        //     PrintDebug_Confidence();
        //     if (isBuy)
        //     {
        //         MakeABuyRequest();
        //     }
        //     else
        //     {
        //         MakeASellRequest();
        //     }
        // }
        // PrintDebug_MA_5min();
    }
    if (!isStart)
        isWaiting = true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    IndicatorRelease(hMA_5min);
    ArrayFree(MA_5min);
    IndicatorRelease(hMA_10min);
    ArrayFree(MA_10min);
    IndicatorRelease(hMA_20min);
    ArrayFree(MA_20min);

    FileClose(fileHandle);
}
//+------------------------------------------------------------------+
