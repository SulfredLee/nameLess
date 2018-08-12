//+------------------------------------------------------------------+
//|                                                    CisNewBar.mqh |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//|                                              Revision 2010.09.27 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CisNewBar.                                                 |
//| Function class for determining the appearance of the new bar     |
//+------------------------------------------------------------------+
class CisNewBar
  {
protected:
   datetime          m_lastbar_time;   // Time of opening the last bar

   string            m_symbol;         // Name of the instrument
   ENUM_TIMEFRAMES   m_period;         // Period of the chart

   uint              m_retcode;        // Result code for determining the new bar 
   int               m_new_bars;       // Number of new bars
   string            m_comment;        // Execution comment

public:
   void              CisNewBar();      // CisNewBar constructor  
   void              operator=(const CisNewBar &_src_new_bar);

   //--- Methods of access to protected data:
   uint              GetRetCode() const      {return(m_retcode);     }  // Result code of determining the new bar 
   datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Time of opening the last bar
   int               GetNewBars() const      {return(m_new_bars);    }  // Amount of new bars
   string            GetComment() const      {return(m_comment);     }  // Comment of execution
   string            GetSymbol() const       {return(m_symbol);      }  // Name of the instrument
   ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Period of the chart
   //--- Methods of initializing protected data:
   void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
   void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
   void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
   //--- Methods of detecting the new bar:
   bool              isNewBar(datetime new_Time);                       // First type of the new bar query.
   int               isNewBar();                                        // Second type of the new bar query. 
  };
//+------------------------------------------------------------------+
//| CisNewBar constructor.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Result code of determining the new bar 
   m_lastbar_time=0;    // Opening time of the last bar
   m_new_bars=0;        // Number of new bars
   m_comment="";        // Execution comment
   m_symbol=Symbol();   // Symbol name, symbol of the current chart by default
   m_period=Period();   // Period of the chart, period of the current chart by default    
  }
//+------------------------------------------------------------------+
//| Assignment operator                                              |
//+------------------------------------------------------------------+
void CisNewBar:: operator=(const CisNewBar &_src_new_bar)
  {
   m_lastbar_time=_src_new_bar.m_lastbar_time;   // Opening time of the last bar
   m_symbol=_src_new_bar.m_symbol;               // Name of the instrument
   m_period=_src_new_bar.m_period;               // Period of the chart
   m_retcode=_src_new_bar.m_retcode;             // Result code of determining the new bar 
   m_new_bars=_src_new_bar.m_new_bars;           // Number of new bars
   m_comment=_src_new_bar.m_comment;             // Execution comment
  }
//+------------------------------------------------------------------+
//| First type of request for the new bar.                           |
//| INPUT:  newbar_time - opening time of the presumably new bar     |
//| OUTPUT: true   - if the new bar(s) appeared                      |
//|         false  - if the new bar didn't appear or there was error |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
//--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of determining the new bar: 0 - no error
   m_comment  =__FUNCTION__+" Checking for a new bar was successful";
//---

//--- Just in case, we will check if the time of the presumably new bar m_newbar_time is less than the time of the last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If the new bar is older than the last bar, it prints error message
      m_comment=__FUNCTION__+" Synchronization error: time of the previous bar "+TimeToString(m_lastbar_time)+
                ", time of the new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of determining the new bar: return -1 - synchronization error
      return(false);
     }
//---

//--- if this is a first call 
   if(m_lastbar_time==0)
     {
      m_lastbar_time=newbar_time; //--- set the time of the last bar and exit
      m_comment=__FUNCTION__+" initialization lastbar_time="+TimeToString(m_lastbar_time);
      return(false);
     }
//---

//--- Check for a new bar: 
   if(m_lastbar_time<newbar_time)
     {
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember the time of the last bar
      return(true);
     }
//---

//--- if we made it to this point, it means that the bar is not new or there is error, return false
   return(false);
  }
//+------------------------------------------------------------------+
//| Second type of the new bar query.                                |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - number of new bars                          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;

//--- Request the opening time of the last bar:
   ResetLastError(); // Sets value of the predefined variable _LastError to zero.
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     { // If the request failed, print error:
      m_retcode=GetLastError();  // Result code of determining the new bar: write value of the _LastError variable
      m_comment=__FUNCTION__+" Error when receiving the opening time of the last bar: "+IntegerToString(m_retcode);
      return(0);
     }
//---

//---Next we use the first type of request for the new bar to complete the analysis:
   if(!isNewBar(newbar_time)) return(0);

//---Clarify the number of new bars:
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

//--- if we made it to this point - then there is(are) new bar(s), return their number:
   return(m_new_bars);
  }
//+------------------------------------------------------------------+