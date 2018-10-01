#property copyright "Copyright 2018, Damage Company"

#include <Files\FileTxt.mqh>

class Logger
{
private:
    int m_timeDifferent; // second
    int m_preTime;
    string m_fileName;
    string m_EAName;
    CFileTxt m_FH;
public:
    Logger(string EAName);
    ~Logger();

    void PrintLog(string logMsg);
    void OnTick();
    string GetTradeResultString(const MqlTradeResult &result);
    string GetTradeRequestString(const MqlTradeRequest &request);
    string GetTradeTransactionString(const MqlTradeTransaction &trans);
private:
    string GetTimeStamp();
    void OpenNewFile();
};

Logger::Logger(string EAName)
{
    m_EAName = EAName;
    OpenNewFile();

    m_preTime = TimeCurrent();
    m_timeDifferent = 5 * 3600; // 5 hour
}

Logger::~Logger()
{
    m_FH.Close();
}

void Logger::OnTick()
{
    if (TimeCurrent() - m_preTime >= m_timeDifferent)
    {
        m_preTime = TimeCurrent();
        m_FH.Close();

        OpenNewFile();
    }
}

void Logger::PrintLog(string logMsg)
{
    string line = GetTimeStamp() + " " + logMsg + "\n";
    m_FH.WriteString(line);
    PrintFormat("%s", logMsg);
}

string Logger::GetTimeStamp()
{
    MqlDateTime now;
    TimeCurrent(now);
    return StringFormat("%04d%02d%02d_%02d%02d%02d", now.year, now.mon, now.day, now.hour, now.min, now.sec);
}

void Logger::OpenNewFile()
{
    m_fileName = m_EAName + "_" + Symbol() + "_" + GetTimeStamp() + ".log";
    int fHD = m_FH.Open(m_fileName, FILE_READ|FILE_WRITE|FILE_TXT);
    if (fHD < 0)
        PrintFormat("Logger Error %d", GetLastError());
    PrintFormat("create Logger %s, fHD: %d", m_fileName, fHD);
}

//+------------------------------------------------------------------+
//| Returns transaction textual description                          |
//+------------------------------------------------------------------+
string Logger::GetTradeTransactionString(const MqlTradeTransaction &trans)
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
string Logger::GetTradeRequestString(const MqlTradeRequest &request)
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
string Logger::GetTradeResultString(const MqlTradeResult &result)
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
