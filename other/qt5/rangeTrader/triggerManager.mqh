#property copyright "Copyright 2018, Damage Company"

struct TriggerRange
{
    double start;
    double end;
};

class TriggerManager
{
private:
    TriggerRange m_triggerArray[];
    int m_triggerArray_len;
    string m_inputFile;
    string m_inputFolder;
public:
    TriggerManager()
    {
        m_inputFolder = "Data";
    }
    ~TriggerManager(){}

    void InitComponent(string inputFile);
    bool IsTriggerOn(double last);
private:
    void GetRange();
};

void TriggerManager::InitComponent(string inputFile)
{
    m_inputFile = inputFile;
    m_triggerArray_len = 0;
    GetRange();
}

bool TriggerManager::IsTriggerOn(double last)
{
    if (m_triggerArray_len == 0)
        return true;

    for (int i = 0; i < m_triggerArray_len; i++)
    {
        if (m_triggerArray[i].start < last && last < m_triggerArray[i].end)
            return true;
    }
    return false;
}

void TriggerManager::GetRange()
{
    string configPattern = Symbol() + ".numRange";
    int FH = FileOpen(m_inputFolder + "//" + m_inputFile, FILE_CSV|FILE_READ, ",");
    if(FH != INVALID_HANDLE)
    {
        while (!FileIsEnding(FH))
        {
            string first = FileReadString(FH);
            string second = FileReadString(FH);
            if (first == configPattern)
            {
                m_triggerArray_len = StringToInteger(second);
                break;
            }
        }
        if (m_triggerArray_len > 0)
        {
            ArrayResize(m_triggerArray, m_triggerArray_len);
            int idx = 0;
            while (!FileIsEnding(FH))
            {
                string first = FileReadString(FH);
                string second = FileReadString(FH);
                if (first != "" && idx < m_triggerArray_len)
                {
                    m_triggerArray[idx].start = StringToDouble(first);
                    m_triggerArray[idx].end = StringToDouble(second);
                    idx++;
                }
            }
        }
        FileClose(FH);
        PrintFormat("Data is read, %s file is closed", m_inputFile);
    }
    else
    {
        PrintFormat("Failed to open %s file, Error code = %d", m_inputFile, GetLastError());
    }
}
