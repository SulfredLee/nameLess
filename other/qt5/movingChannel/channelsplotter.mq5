//+------------------------------------------------------------------+
//|                                              ChannelsPlotter.mq5 |
//|                                           Copyright 2016, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
//--- include
#include "../Include/CFractalPoint.mqh"

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
sinput string Info_channels="+===--Channels--====+"; // +===--Channels of--====+
input int InpPrevFracNum=3;                        // Previous fractals
input int InpBarsBeside=5;                         // Bars to the left/ right of the fractal
input int InpBarsBetween=1;                        // Intermediate bars
input bool InpToDeletePrevious=true;               // Remove previous channels?
input bool InpIsAlt=true;                          // Alternative indicator?
input ENUM_RELEVANT_EXTREMUM InpRelevantPoint=RELEVANT_EXTREMUM_PREV; // Relevant point
sinput bool InpIsArray=true;                       // Draw arrow?
sinput int InpLineWidth=3;                         // Line width
sinput bool InpToLog=true;                         // Keep log?
//--- globals
CFractalSet myFractalSet;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    PrintFormat("OnInit on symbol %s at %s",_Symbol,TimeToString(TimeCurrent()));
    if(!myFractalSet.Init(InpPrevFracNum,InpBarsBeside,InpBarsBetween,InpToDeletePrevious,
                          InpIsAlt,InpRelevantPoint,InpIsArray,InpLineWidth,InpToLog))
    {
        Print("Error in initializing the fractal set!");
        return INIT_FAILED;
    }
    //---
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //---
    myFractalSet.Deinit();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    myFractalSet.Process();
}
//+------------------------------------------------------------------+
