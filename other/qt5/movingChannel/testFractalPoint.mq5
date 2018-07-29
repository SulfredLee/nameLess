#include "../Include/CFractalPoint.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    PrintFormat("OnInit on symbol %s at %s", _Symbol, TimeToString(TimeCurrent()));

    //--- fractal point data
    datetime pnt_date=D'24.07.2018 16:00';
    double pnt_val=1.1716;
    ENUM_EXTREMUM_TYPE pnt_type=EXTREMUM_TYPE_MAX;
    int pnt_idx=0;

    //--- create fractal point
    CFractalPoint myFracPoint(pnt_date,pnt_val,pnt_type,pnt_idx);
    myFracPoint.Print();

    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
}
//+------------------------------------------------------------------+
