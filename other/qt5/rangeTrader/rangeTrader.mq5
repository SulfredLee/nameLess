#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Expert Advisor places buy/sell limit orders"
#property description "based on a special cirteria"

#include "SRLineManager.mqh"

input double Lots      = 0.01;

string SRFile = Symbol() + ".csv";
string ConfigFile = Symbol() + ".config.csv";
string OrderListFile = Symbol() + ".orderList.csv";

SRLineManager srLineManager();

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
    srLineManager.InitComponent(SRFile);
    srLineManager.PrintOrderList(OrderListFile); // for debug
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countTick = 0;
void OnTick()
{
    double lastPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    countTick++;
    if (countTick % 500000 == 0)
    {
        PrintFormat("countTick: %d", countTick);
    }
    srLineManager.OnTick(lastPrice);
    while (srLineManager.HasNextRequest())
    {
        MqlTradeRequest request = srLineManager.GetNextLimitRequest();
        request.magic = EXPERT_MAGIC;
        request.symbol = Symbol();
        request.volume = Lots;
        DebugPrintRequest(request);
        MqlTradeResult result;
        ZeroMemory(result);
        //--- send the request
        if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d", GetLastError());     // if unable to send the request, output the error code
        //--- information about the operation
        PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);
    }
    return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
