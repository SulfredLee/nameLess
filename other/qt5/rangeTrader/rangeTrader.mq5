#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Expert Advisor places buy/sell limit orders"
#property description "based on a special cirteria"

#define EXPERT_MAGIC 338866   // MagicNumber of the expert

input int    StartHour = 7;
input int    EndHour   = 19;
input int    MAper     = 240;
input double Lots      = 0.1;

#include "../Include/SRLineManager.mqh"

int hMA,hCI; // hMA: Moving Average indicator's handle, hCI: custom indicator's handle
string SRFile = Symbol() + ".csv";
string OrderListFile = Symbol() + ".orderList.csv";

SRLineManager srLineManager;

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
void OnTick()
{
    double lastPrice = SymbolInfoDouble(Symbol(), SYMBOL_LAST);
    srLineManager.OnTick(lastPrice);
    while (srLineManager.HasNextRequest())
    {
        MqlTradeRequest request = srLineManager.GetNextLimitRequest();
        request.magic = EXPERT_MAGIC;
        request.symbol = Symbol();
        request.volume = Lots;
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
