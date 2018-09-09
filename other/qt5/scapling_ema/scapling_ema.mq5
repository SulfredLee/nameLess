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

//+------------------------------------------------------------------+
//| Returns transaction textual description                          |
//+------------------------------------------------------------------+
string DebugPrintTradeTransaction(const MqlTradeTransaction &trans)
{
    //---
    string desc=EnumToString(trans.type)+" ";
    desc+="Symbol: "+trans.symbol+" ";
    desc+="Deal ticket: "+(string)trans.deal+" ";
    desc+="Deal type: "+EnumToString(trans.deal_type)+" ";
    desc+="Order ticket: "+(string)trans.order+" ";
    desc+="Order type: "+EnumToString(trans.order_type)+" ";
    desc+="Order state: "+EnumToString(trans.order_state)+" ";
    desc+="Order time type: "+EnumToString(trans.time_type)+" ";
    desc+="Order expiration: "+TimeToString(trans.time_expiration)+" ";
    desc+="Price: "+StringFormat("%G",trans.price)+" ";
    desc+="Price trigger: "+StringFormat("%G",trans.price_trigger)+" ";
    desc+="Stop Loss: "+StringFormat("%G",trans.price_sl)+" ";
    desc+="Take Profit: "+StringFormat("%G",trans.price_tp)+" ";
    desc+="Volume: "+StringFormat("%G",trans.volume)+" ";
    desc+="Position: "+(string)trans.position+" ";
    desc+="Position by: "+(string)trans.position_by+" ";
    //--- return the obtained string
    return desc;
}
//+------------------------------------------------------------------+
//| Returns the trade request textual description                    |
//+------------------------------------------------------------------+
string DebugPrintTradeRequest(const MqlTradeRequest &request)
{
    //---
    string desc=EnumToString(request.action)+" ";
    desc+="Symbol: "+request.symbol+" ";
    desc+="Magic Number: "+StringFormat("%d",request.magic)+" ";
    desc+="Order ticket: "+(string)request.order+" ";
    desc+="Order type: "+EnumToString(request.type)+" ";
    desc+="Order filling: "+EnumToString(request.type_filling)+" ";
    desc+="Order time type: "+EnumToString(request.type_time)+" ";
    desc+="Order expiration: "+TimeToString(request.expiration)+" ";
    desc+="Price: "+StringFormat("%G",request.price)+" ";
    desc+="Deviation points: "+StringFormat("%G",request.deviation)+" ";
    desc+="Stop Loss: "+StringFormat("%G",request.sl)+" ";
    desc+="Take Profit: "+StringFormat("%G",request.tp)+" ";
    desc+="Stop Limit: "+StringFormat("%G",request.stoplimit)+" ";
    desc+="Volume: "+StringFormat("%G",request.volume)+" ";
    desc+="Comment: "+request.comment+" ";
    //--- return the obtained string
    return desc;
}
//+------------------------------------------------------------------+
//| Returns the textual description of the request handling result   |
//+------------------------------------------------------------------+
string DebugPrintTradeResult(const MqlTradeResult &result)
{
    //---
    string desc="Retcode "+(string)result.retcode+" ";
    desc+="Request ID: "+StringFormat("%d",result.request_id)+" ";
    desc+="Order ticket: "+(string)result.order+" ";
    desc+="Deal ticket: "+(string)result.deal+" ";
    desc+="Volume: "+StringFormat("%G",result.volume)+" ";
    desc+="Price: "+StringFormat("%G",result.price)+" ";
    desc+="Ask: "+StringFormat("%G",result.ask)+" ";
    desc+="Bid: "+StringFormat("%G",result.bid)+" ";
    desc+="Comment: "+result.comment+" ";
    //--- return the obtained string
    return desc;
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
            PrintFormat("%s:%d %s", __FUNCTION__, __LINE__, DebugPrintTradeRequest(request));
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
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    PrintFormat("%s:%d bid: %f, ask: %f", __FUNCTION__, __LINE__, bid, ask);
    PrintFormat("%s:%d %s", __FUNCTION__, __LINE__, DebugPrintTradeTransaction(trans));
    PrintFormat("%s:%d %s", __FUNCTION__, __LINE__, DebugPrintTradeRequest(request));
    PrintFormat("%s:%d %s", __FUNCTION__, __LINE__, DebugPrintTradeResult(result));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
