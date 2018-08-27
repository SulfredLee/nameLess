#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Expert Advisor places buy/sell limit orders"
#property description "based on a special cirteria"

#include "SRLineManager.mqh"
#include "doubleArray.mqh"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_type3   DRAW_LINE
#property indicator_color3  Red
#property indicator_type4   DRAW_LINE
#property indicator_color4  Red
#property indicator_type5   DRAW_LINE
#property indicator_color5  Yellow
#property indicator_type6   DRAW_LINE
#property indicator_color6  Yellow
#property indicator_type7   DRAW_LINE
#property indicator_color7  Yellow
#property indicator_type8   DRAW_LINE
#property indicator_color8  Yellow

//--- indicator buffers
doubleArray gBL_Indicators[BL_LAYERS];
doubleArray gSL_Indicators[SL_LAYERS];

input double Lots      = 0.1;

string SRFile = Symbol() + ".csv";
string ConfigFile = Symbol() + ".config.csv";
string OrderListFile = Symbol() + ".orderList.csv";

SRLineManager srLineManager(BL_LAYERS, SL_LAYERS);

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
void InitIndicatorLines()
{
    for (int i = 0; i < BL_LAYERS; i++)
    {
        //--- indicator buffers mapping
        gBL_Indicators[i].SetIndexBuffer(i);
        //---- sets drawing line empty value--
        PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
        //--- sets first bar from what index will be draw
        PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, 0);
        //---- initialization done
    }
    for (int i = 0; i < SL_LAYERS; i++)
    {
        int j = i + BL_LAYERS;
        //--- indicator buffers mapping
        gSL_Indicators[i].SetIndexBuffer(j);
        //---- sets drawing line empty value--
        PlotIndexSetDouble(j, PLOT_EMPTY_VALUE, 0.0);
        //--- sets first bar from what index will be draw
        PlotIndexSetInteger(j, PLOT_DRAW_BEGIN, 0);
        //---- initialization done
    }
    //--- set accuracy
    IndicatorSetInteger(INDICATOR_DIGITS, Digits() + 1);
    //--- name for DataWindow
    IndicatorSetString(INDICATOR_SHORTNAME, "SRLines");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
{
    PrintFormat("OnInit()");
    InitIndicatorLines();
    srLineManager.InitComponent(SRFile);
    srLineManager.PrintOrderList(OrderListFile); // for debug
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countTick = 0;
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
    if (prev_calculated == 0)
    {
        for (int i = 0; i < BL_LAYERS; i++)
            gBL_Indicators[i].ArrayInitialize();
        for (int i = 0; i < SL_LAYERS; i++)
            gSL_Indicators[i].ArrayInitialize();
    }
    countTick++;
    if (countTick % 500000 == 0)
    {
        PrintFormat("countTick: %d", countTick);
    }
    srLineManager.OnTick(price[rates_total - 1]);

    return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    for (int i = 0; i < BL_LAYERS; i++)
        gBL_Indicators[i].ArrayFree();
    for (int i = 0; i < SL_LAYERS; i++)
        gSL_Indicators[i].ArrayFree();
    ArrayFree(gBL_Indicators);
    ArrayFree(gSL_Indicators);
}
//+------------------------------------------------------------------+
