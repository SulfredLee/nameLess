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

    void PrintLog(const string& logMsg);
    void OnTick();
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

void Logger::PrintLog(const string& logMsg)
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
