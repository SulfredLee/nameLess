#property copyright   "Damage Company"
#property version     "1.00"
#property description "This Indicator shows several EMA lines"

input int g_SRange_SPeriod = 5;
input int g_SRange_MPeriod = 13;
input int g_SRange_LPeriod = 21;

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_type2   DRAW_LINE
#property indicator_color2  Yellow
#property indicator_type3   DRAW_LINE
#property indicator_color3  Green

//--- indicator buffer
double g_EMA_SRange_SPeriod[];
double g_EMA_SRange_MPeriod[];
double g_EMA_SRange_LPeriod[];
int g_EMA_SRange_SPeriod_Len;
int g_EMA_SRange_MPeriod_Len;
int g_EMA_SRange_LPeriod_Len;

//--- indicator handle
double g_hEMA_SRange_SPeriod;
double g_hEMA_SRange_MPeriod;
double g_hEMA_SRange_LPeriod;

void MapIndicator()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, g_EMA_SRange_SPeriod, INDICATOR_DATA);
    SetIndexBuffer(1, g_EMA_SRange_MPeriod, INDICATOR_DATA);
    SetIndexBuffer(2, g_EMA_SRange_LPeriod, INDICATOR_DATA);
    for (int i = 0; i < 3; i++)
    {
        //---- sets drawing line empty value--
        PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
        //--- sets first bar from what index will be draw
        PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, 0);
    }
    //--- set accuracy
    IndicatorSetInteger(INDICATOR_DIGITS, Digits() + 1);
    //--- name for DataWindow
    IndicatorSetString(INDICATOR_SHORTNAME, "EMA_Lines");
}
void InitIndicator()
{
    g_hEMA_SRange_SPeriod = iMA(Symbol(), PERIOD_M5, g_SRange_SPeriod, 0, MODE_EMA, PRICE_CLOSE);
    g_hEMA_SRange_MPeriod = iMA(Symbol(), PERIOD_M5, g_SRange_MPeriod, 0, MODE_EMA, PRICE_CLOSE);
    g_hEMA_SRange_LPeriod = iMA(Symbol(), PERIOD_M5, g_SRange_LPeriod, 0, MODE_EMA, PRICE_CLOSE);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
{
    PrintFormat("OnInit()");
    InitIndicator();
    MapIndicator();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
    if (prev_calculated == 0)
    {
        g_EMA_SRange_SPeriod_Len = ArrayInitialize(g_EMA_SRange_SPeriod, EMPTY_VALUE);
        g_EMA_SRange_MPeriod_Len = ArrayInitialize(g_EMA_SRange_MPeriod, EMPTY_VALUE);
        g_EMA_SRange_LPeriod_Len = ArrayInitialize(g_EMA_SRange_LPeriod, EMPTY_VALUE);
    }
    CopyBuffer(g_hEMA_SRange_LPeriod, 0, 0, g_EMA_SRange_LPeriod_Len, g_EMA_SRange_LPeriod);
    CopyBuffer(g_hEMA_SRange_MPeriod, 0, 0, g_EMA_SRange_MPeriod_Len, g_EMA_SRange_MPeriod);
    CopyBuffer(g_hEMA_SRange_SPeriod, 0, 0, g_EMA_SRange_SPeriod_Len, g_EMA_SRange_SPeriod);

    return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ArrayFree(g_EMA_SRange_SPeriod);
    ArrayFree(g_EMA_SRange_MPeriod);
    ArrayFree(g_EMA_SRange_LPeriod);
    IndicatorRelease(g_hEMA_SRange_LPeriod);
    IndicatorRelease(g_hEMA_SRange_MPeriod);
    IndicatorRelease(g_hEMA_SRange_SPeriod);
}
//+------------------------------------------------------------------+
