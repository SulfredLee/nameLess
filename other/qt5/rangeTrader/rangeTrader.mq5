#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Expert Advisor places buy/sell limit orders"
#property description "based on a special cirteria"

#include "SRLineManager.mqh"
#include "onTickTimer.mqh"

input double Lots      = 0.01;

string SRFile = Symbol() + ".csv";
string ConfigFile = Symbol() + ".config.csv";
string OrderListFile = Symbol() + ".orderList.csv";

SRLineManager srLineManager();
onTickTimer g_onTickTimer;

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
    desc+="Price: "+StringFormat("%f",trans.price)+" ";
    desc+="Price trigger: "+StringFormat("%f",trans.price_trigger)+" ";
    desc+="Stop Loss: "+StringFormat("%f",trans.price_sl)+" ";
    desc+="Take Profit: "+StringFormat("%f",trans.price_tp)+" ";
    desc+="Volume: "+StringFormat("%f",trans.volume)+" ";
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
    srLineManager.InitComponent(SRFile);
    srLineManager.PrintOrderList(OrderListFile); // for debug
    srLineManager.RemoveRemainingOrder();
    g_onTickTimer.InitComponent(10); // trigger every 10 minute
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countTick = 0;
void OnTick()
{
    if (g_onTickTimer.IsStart())
    {
        for (int i = 0; i < 10; i++)
        {
            PrintFormat("-----------------------flush log file------------------------------------");
        }
    }
    double lastPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    countTick++;
    if (countTick % 500000 == 0)
    {
        PrintFormat("countTick: %d", countTick);
    }
    if (srLineManager.IsWatingLastPrice())
        srLineManager.OnTick(lastPrice);
    while (srLineManager.HasNextRequest())
    {
        MqlTradeRequest request = srLineManager.GetNextLimitRequest();
        request.magic = EXPERT_MAGIC;
        request.symbol = Symbol();
        request.volume = Lots;
        PrintFormat("%s:%d %s", __FUNCTION__, __LINE__, DebugPrintTradeRequest(request));
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
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
    if (!srLineManager.IsWatingLastPrice())
    {
        if (trans.type == TRADE_TRANSACTION_ORDER_DELETE)
        {
            srLineManager.OnTick(trans.price);
        }
    }
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
