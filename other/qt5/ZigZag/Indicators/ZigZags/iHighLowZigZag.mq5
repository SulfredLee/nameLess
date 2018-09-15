//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot ZigZag
#property indicator_label1  "ZigZag"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Direction
#property indicator_label2  "Direction"
#property indicator_type2   DRAW_NONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot LastHighBar
#property indicator_label3  "LastHighBar"
#property indicator_type3   DRAW_NONE
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot LastLowBar
#property indicator_label4  "LastLowBar"
#property indicator_type4   DRAW_NONE
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input int      period=12;
//--- indicator buffers
double         ZigZagBuffer[];
double         DirectionBuffer[];
double         LastHighBarBuffer[];
double         LastLowBarBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigZagBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DirectionBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,LastHighBarBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,LastLowBarBuffer,INDICATOR_CALCULATIONS);
//---
   return(INIT_SUCCEEDED);
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
//---

   int start; // variable for index of the bars to start calculation from 

   if(prev_calculated==0)
     { // at startup
      // initialize the buffer elements
      DirectionBuffer[0]=0;
      LastHighBarBuffer[0]=0;
      LastLowBarBuffer[0]=0;
      start=1; // calculation starting from the elements following the initialized ones
     }
   else
     { // during operation
      start=prev_calculated-1;
     }

   for(int i=start;i<rates_total;i++)
     {
      // get the value of the previously determined 
      // direction from the previous element
      DirectionBuffer[i]=DirectionBuffer[i-1];

      // calculation of the initial bar for 
      // the ArrayMaximum() and ArrayMinimum() functions 
      int ps=i-period+1;
      // determine High and Low bars in
      // the range of 'period' bars
      int hb=ArrayMaximum(high,ps,period);
      int lb=ArrayMinimum(low,ps,period);

      // if a High or Low is identified
      if(hb==i && lb!=i)
        { // High identified
         DirectionBuffer[i]=1;
        }
      else if(lb==i && hb!=i)
        { // Low identified
         DirectionBuffer[i]=-1;
        }
      //===
      LastHighBarBuffer[i]=LastHighBarBuffer[i-1];
      LastLowBarBuffer[i]=LastLowBarBuffer[i-1];
      ZigZagBuffer[i]=EMPTY_VALUE;

      switch((int)DirectionBuffer[i])
        {
         case 1:
            switch((int)DirectionBuffer[i-1])
              {
               case 1:
                  // continuation of an upward movement
                  if(high[i]>high[(int)LastHighBarBuffer[i]])
                    { // new High
                     // remove the old ZigZag point
                     ZigZagBuffer[(int)LastHighBarBuffer[i]]=EMPTY_VALUE;
                     // place a new point
                     ZigZagBuffer[i]=high[i];
                     // index of the bar with the new top
                     LastHighBarBuffer[i]=i;
                    }
                  break;
               case -1:
                  // beginning of a new upward movement
                  ZigZagBuffer[i]=high[i];
                  LastHighBarBuffer[i]=i;
                  break;
              }
            break;
         case -1:
            switch((int)DirectionBuffer[i-1])
              {
               case -1:
                  // continuation of a downward movement
                  if(low[i]<low[(int)LastLowBarBuffer[i]])
                    { // new Low
                     // remove the old ZigZag point                  
                     ZigZagBuffer[(int)LastLowBarBuffer[i]]=EMPTY_VALUE;
                     // place a new point
                     ZigZagBuffer[i]=low[i];
                     // index of the bar with the new top
                     LastLowBarBuffer[i]=i;
                    }
                  break;
               case 1:
                  // beginning of a new downward movement     
                  ZigZagBuffer[i]=low[i];
                  LastLowBarBuffer[i]=i;
                  break;
              }
            break;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
