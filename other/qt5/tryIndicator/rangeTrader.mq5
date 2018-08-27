#property copyright   "Damage Company"
#property version     "1.00"
#property description "A testing indicator"

#define EXPERT_MAGIC 338866   // MagicNumber of the expert

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red

//--- indicator buffers
double SL_1[];
int SL_1_len;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
{
    PrintFormat("OnInit()");
    //--- indicator buffers mapping
    SetIndexBuffer(0, SL_1, INDICATOR_DATA);
    //--- set accuracy
    IndicatorSetInteger(INDICATOR_DIGITS, Digits() + 1);
    // //--- sets first bar from what index will be drawn
    // PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 1);
    // //---- line shifts when drawing
    // PlotIndexSetInteger(0, PLOT_SHIFT, 0);
    //--- name for DataWindow
    IndicatorSetString(INDICATOR_SHORTNAME, "SRLines");
    //---- sets drawing line empty value--
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    //---- initialization done
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
    //--- first calculation or number of bars was changed
    if(prev_calculated==0)
        SL_1_len = ArrayInitialize(SL_1, EMPTY_VALUE);

    //--- sets first bar from what index will be draw
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);

    PrintFormat("begin: %d, rates_total: %d, price[begin]: %f, price[rates_total - 1]: %f", begin, rates_total, price[begin], price[rates_total - 1]);
    for (int i = 0; i < SL_1_len; i++)
    {
        SL_1[i] = price[rates_total - 1];
    }
    return(rates_total);
}
