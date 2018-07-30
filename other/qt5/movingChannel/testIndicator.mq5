#property copyright "Copyright 2018, Sulfred."
#property link      "nameless@gmail.com"
#property version   "1.00"
#property description "This is a testing indicator"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
//--- input parameters
input int            InpMAPeriod=13;         // Period
input int            InpMAShift=0;           // Shift
input ENUM_MA_METHOD InpMAMethod=MODE_SMMA;  // Method
//--- indicator buffers
double               ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
    PrintFormat("OnInit on symbol %s at %s INDICATOR_DATA: %d", _Symbol, TimeToString(TimeCurrent()), INDICATOR_DATA);
    //--- indicator buffers mapping
    SetIndexBuffer(0, ExtLineBuffer, INDICATOR_DATA);
    //--- set accuracy
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits+1);
    //--- sets first bar from what index will be drawn
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
    //---- line shifts when drawing
    PlotIndexSetInteger(0, PLOT_SHIFT, 0);
    //--- name for DataWindow
    string short_name="testingIndicator";
    switch(InpMAMethod)
    {
        case MODE_EMA :  short_name="EMA";  break;
        case MODE_LWMA : short_name="LWMA"; break;
        case MODE_SMA :  short_name="SMA";  break;
        case MODE_SMMA : short_name="SMMA"; break;
        default : short_name = "EMA"; break;
    }
    IndicatorSetString(INDICATOR_SHORTNAME, short_name + "("+string(InpMAPeriod)+")");
    //---- sets drawing line empty value--
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    //---- initialization done
}
string Period2String(ENUM_TIMEFRAMES period)
{
    switch (period)
    {
        case PERIOD_M1:
            return "M1";
        case PERIOD_M2:
            return "M2";
        case PERIOD_M3:
            return "M3";
        case PERIOD_M4:
            return "M4";
        case PERIOD_M5:
            return "M5";
        case PERIOD_M6:
            return "M6";
        case PERIOD_M10:
            return "M10";
        case PERIOD_M12:
            return "M12";
        case PERIOD_M15:
            return "M15";
        case PERIOD_M20:
            return "M20";
        case PERIOD_M30:
            return "M30";
        case PERIOD_H1:
            return "H1";
        case PERIOD_H2:
            return "H2";
        case PERIOD_H3:
            return "H3";
        case PERIOD_H4:
            return "H4";
        case PERIOD_H6:
            return "H6";
        case PERIOD_H8:
            return "H8";
        case PERIOD_H12:
            return "H12";
        case PERIOD_D1:
            return "D1";
        case PERIOD_W1:
            return "W1";
        case PERIOD_MN1:
            return "MN";
        default:
            return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    PrintFormat("OnCalculate on symbol %s at %s", _Symbol, TimeToString(TimeCurrent()));
    PrintFormat("rates_total: %d", rates_total);
    PrintFormat("prev_calculated: %d", prev_calculated);
    PrintFormat("----------------------------------------------------");
    //--- first calculation or number of bars was changed
    if(prev_calculated==0)
    {
        ArrayInitialize(ExtLineBuffer,0);
    }
    //--- sets first bar from what index will be draw
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);

    for (int i = 0; i < rates_total; i++)
    {
        ExtLineBuffer[i] = high[i];
    }
    string outputFile = _Symbol + "." + Period2String(Period()) + ".csv";
    int fileHandle = FileOpen("Data//" + outputFile, FILE_READ|FILE_WRITE|FILE_CSV);
    if(fileHandle != INVALID_HANDLE)
    {
        //--- first, write the number of signals
        FileWrite(fileHandle, _Symbol, TimeCurrent(), rates_total, prev_calculated, _Digits);
        //--- write the time and values of signals to the file
        for (int i = prev_calculated; i < rates_total; i++)
        {
            FileWrite(fileHandle, time[i], open[i], high[i], low[i], close[i], tick_volume[i], volume[i], spread[i]);
        }
        //--- close the file
        FileClose(fileHandle);
        PrintFormat("Data is written, %s file is closed", outputFile);
    }
    else
    {
        PrintFormat("Failed to open %s file, Error code = %d", outputFile, GetLastError());
    }

    return rates_total;
}
