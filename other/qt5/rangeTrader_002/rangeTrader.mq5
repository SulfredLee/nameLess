//+------------------------------------------------------------------+
//|                                                     template.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input ulong g_EXPERT_MAGIC = 338866; // MagicNumber for expert
input double g_Lots = 0.01; // Lots

#include "../../Include/DCUtil/Logger.mqh"
#include "srLineManager.mqh"

Logger g_Logger("rangeTrader");
SRLineManager g_srLineManager;
bool g_hasPendingOrder = false;

bool HasPendingOrder()
{
    g_hasPendingOrder = false;
    MqlTradeRequest request={0};
    MqlTradeResult  result={0};
    int total = OrdersTotal(); // total number of placed pending orders
    //--- iterate over all placed pending orders
    for(int i = total-1; i >= 0; i--)
    {
        ulong  order_ticket = OrderGetTicket(i);                   // order ticket
        ulong  magic = OrderGetInteger(ORDER_MAGIC);               // MagicNumber of the order
        string symbol = OrderGetString(ORDER_SYMBOL);
        //--- if the pending order is made by this trader
        if (magic == g_EXPERT_MAGIC && symbol == Symbol())
        {
            g_hasPendingOrder = true;
            return g_hasPendingOrder;
        }
    }
    return g_hasPendingOrder;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- create timer
    EventSetTimer(60);
    //---
    g_Logger.PrintLog(StringFormat("%s:%d OnInit()", __FUNCTION__, __LINE__));
    g_srLineManager.InitComponent(&g_Logger);
    if (!g_hasPendingOrder && !HasPendingOrder())
    {
        g_srLineManager.MakeLimitRequest();
        while (g_srLineManager.HasNextLimitRequest())
        {
            MqlTradeRequest request = g_srLineManager.GetNextLimitRequest();
            request.magic = g_EXPERT_MAGIC;
            request.volume = g_Lots;
            g_Logger.PrintLog(StringFormat("%s:%d %s", __FUNCTION__, __LINE__, g_Logger.GetTradeRequestString(request)));
            MqlTradeResult result;
            ZeroMemory(result);
            //--- send the request
            if(!OrderSend(request,result))
            {
                g_Logger.PrintLog(StringFormat("%s:%d OrderSend error %d", __FUNCTION__, __LINE__, GetLastError())); // if unable to send the request, output the error code
            }
            //--- information about the operation
            g_Logger.PrintLog(StringFormat("%s:%d retcode=%u  deal=%I64u  order=%I64u", __FUNCTION__, __LINE__, result.retcode, result.deal, result.order));

            g_hasPendingOrder = true;
        }
    }
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- destroy timer
    EventKillTimer();
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    //---
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    //---
    // g_Logger.PrintLog(StringFormat("%s:%d IN", __FUNCTION__, __LINE__));
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
    //---
   
}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
    //---
    switch (trans.type)
    {
        case TRADE_TRANSACTION_DEAL_ADD:
            break;
        case TRADE_TRANSACTION_ORDER_DELETE:
            break;
        case TRADE_TRANSACTION_HISTORY_ADD:
            break;
        default:
            break;
    }
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    g_Logger.PrintLog(StringFormat("%s:%d bid: %f, ask: %f", __FUNCTION__, __LINE__, bid, ask));
    g_Logger.PrintLog(StringFormat("%s:%d %s", __FUNCTION__, __LINE__, g_Logger.GetTradeTransactionString(trans)));
    g_Logger.PrintLog(StringFormat("%s:%d %s", __FUNCTION__, __LINE__, g_Logger.GetTradeRequestString(request)));
    g_Logger.PrintLog(StringFormat("%s:%d %s", __FUNCTION__, __LINE__, g_Logger.GetTradeResultString(result)));
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
    //---
    double ret=0.0;
    //---

    //---
    return(ret);
}
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
{
    //---
   
}
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
{
    //---
   
}
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
{
    //---
   
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    //---
   
}
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
{
    //---
   
}
//+------------------------------------------------------------------+
