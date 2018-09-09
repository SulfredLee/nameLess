#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Expert Advisor do scapling by comparing trend from different time frame"

#define EXPERT_MAGIC 337866   // MagicNumber of the expert, for the first TP section

#include "onTickTimer.mqh"
#include "scapling_trader.mqh"
#include "TPEarlyExit.mqh"
#include "SLEarlyExit.mqh"

input double g_Lots      = 0.01;
input int g_SRange_SPeriod = 5; // min
input int g_SRange_MPeriod = 13; // min
input int g_SRange_LPeriod = 21; // min
input int g_LRange_SPeriod = 8; // min
input int g_LRange_LPeriod = 21; // min
input int g_SRange_TrendMinPeriod = 4; // bar
input int g_SRange_TrendConfirmPeriod = 3; // bar
input int g_SRange_TrendMaxPeriod = 6; // bar, when the trend is already longer than TrendMaxPeriod, we will not make a new order
input int g_LRange_TrendMinPeriod = 4; // bar
input int g_LRange_TrendConfirmPeriod = 3; // bar
input int g_LRange_TrendMaxPeriod = 8; // bar, when the trend is already longer than TrendMaxPeriod, we will not make a new order
input int g_SRange_Margin = 10; // pipe
input int g_LRange_Margin = 0; // pipe
input int g_ScanRange = 5; // bar
input int g_onTickTime = 5; // min
input int g_SLPipe = 500; // pipe
input int g_TPPipe = 250; // pipe

onTickTimer g_OnTickTimer;
ScaplingTrader g_Trader;
TPEarlyExit g_TPEarlyExit;
SLEarlyExit g_SLEarlyExit;

bool g_isWaiting;
int g_historyDealTotalPre, g_historyDealTotalCur;

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
{
    PrintFormat("OnInit()");

    g_isWaiting = true;

    g_historyDealTotalPre = 0;
    g_historyDealTotalCur = 0;

    // init tools
    g_TPEarlyExit.InitComponent(0, 5, 30, 0.9, EXPERT_MAGIC);
    g_SLEarlyExit.InitComponent(0, 8, 0, 0.8, EXPERT_MAGIC);
    g_OnTickTimer.InitComponent(g_onTickTime);
    g_Trader.InitComponent(g_SRange_SPeriod, g_SRange_MPeriod, g_SRange_LPeriod, g_LRange_SPeriod, g_LRange_LPeriod, g_SRange_TrendMinPeriod, g_SRange_TrendConfirmPeriod, g_SRange_TrendMaxPeriod, g_LRange_TrendMinPeriod, g_LRange_TrendConfirmPeriod, g_LRange_TrendMaxPeriod, g_ScanRange, g_SLPipe, g_TPPipe, g_SRange_Margin, g_LRange_Margin, g_Lots, EXPERT_MAGIC);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
    bool isStart = g_OnTickTimer.IsStart();
    if (g_isWaiting && isStart)
    {
        g_TPEarlyExit.OnTick();
        g_SLEarlyExit.OnTick();
        g_isWaiting = false;

        MqlTradeRequest request;
        if (g_Trader.OnTick(request))
        {
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
        g_isWaiting = true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
