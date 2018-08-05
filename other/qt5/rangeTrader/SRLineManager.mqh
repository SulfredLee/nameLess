#property copyright "Copyright 2018, Damage Company"
#include "SRTracker.mqh"
#include "LimitOrder.mqh"

class SRLineManager
{
private:
    double m_SRLines[];
    int m_SRLines_len;
    LimitOrder m_SellLimitOrder[]; // 5 % above SRLine
    int m_SellLimitOrder_len;
    LimitOrder m_BuyLimitOrder[]; // 5 % below SRLine
    int m_BuyLimitOrder_len;
    string m_inputFolder;
    string m_outputFolder;
    double m_limitOffset;
    double m_TPOffset;
    double m_SLOffset;
    int m_SellLimitLayers;
    int m_BuyLimitLayers;
    double m_lastPrice;
    SRTracker m_tracker;
public:
    void SRLineManager()
    {
        m_inputFolder = "Data";
        m_outputFolder = "Data";
        m_limitOffset = 0.05;
        m_TPOffset = 0.05;
        m_SLOffset = 0.1;
        m_lastPrice = -1;
        m_SellLimitLayers = 4;
        m_BuyLimitLayers = 4;

        m_tracker.InitComponent(m_SellLimitLayers + m_BuyLimitLayers);
    };
    void ~SRLineManager()
    {
        ArrayFree(m_SRLines);
        ArrayFree(m_SellLimitOrder);
        ArrayFree(m_BuyLimitOrder);
    };

    void InitComponent(string SRFile);
    void PrintOrderList(string outputFile);
    void OnTick(double lastPrice);
    bool HasNextRequest();
    MqlTradeRequest GetNextLimitRequest();

private:
    int GetNumberOfSRLines(string inputFile);
    void InitSRLines(string inputFile);
    void InitOrders();
    void InitTracker();
};

void SRLineManager::InitComponent(string SRFile)
{
    PrintFormat("InitComponent");
    m_SRLines_len = GetNumberOfSRLines(SRFile);
    ArrayResize(m_SRLines, m_SRLines_len);

    InitSRLines(SRFile);
    InitOrders();
}

int SRLineManager::GetNumberOfSRLines(string inputFile)
{
    PrintFormat("GetNumberOfSRLines()");
    int numSRLine = 0;
    int FH = FileOpen(m_inputFolder + "//" + inputFile, FILE_TXT|FILE_READ);
    if(FH != INVALID_HANDLE)
    {
        PrintFormat("Reading SRFile: %s", inputFile);
        PrintFormat("File path: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));

        while (!FileIsEnding(FH))
        {
            FileReadString(FH);
            numSRLine++;
        }
        PrintFormat("Get number of m_SRLines: %d", numSRLine);

        FileClose(FH);
        PrintFormat("Data is read, %s file is closed", inputFile);
    }
    else
    {
        PrintFormat("Failed to open %s file, Error code = %d", inputFile, GetLastError());
    }
    return numSRLine;
}

void SRLineManager::InitSRLines(string inputFile)
{
    PrintFormat("InitSRLines()");
    int FH = FileOpen(m_inputFolder + "//" + inputFile, FILE_CSV|FILE_READ, ",");
    if(FH != INVALID_HANDLE)
    {
        PrintFormat("Reading SRFile: %s", inputFile);
        PrintFormat("File path: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));

        int index = 0;
        while (!FileIsEnding(FH))
        {
            m_SRLines[index++] = StringToDouble(FileReadString(FH)); // read the first column
            PrintFormat("Damage Debug, index: %f", m_SRLines[index - 1]);
        }
        //--- close the file
        FileClose(FH);
        PrintFormat("Data is read, %s file is closed", inputFile);
    }
    else
    {
        PrintFormat("Failed to open %s file, Error code = %d", inputFile, GetLastError());
    }
}

void SRLineManager::InitOrders()
{
    m_SellLimitOrder_len = m_SRLines_len - 1;
    m_BuyLimitOrder_len = m_SRLines_len - 1;
    ArrayResize(m_SellLimitOrder, m_SellLimitOrder_len);
    ArrayResize(m_BuyLimitOrder, m_BuyLimitOrder_len);
    for (int i = 0 ; i < m_SRLines_len - 1; i++)
    {
        // handle sell limit order
        m_SellLimitOrder[i].m_price = m_SRLines[i] - (m_SRLines[i] - m_SRLines[i+1]) * m_limitOffset;
        m_SellLimitOrder[i].m_TP = m_SRLines[i+1] + (m_SRLines[i] - m_SRLines[i+1]) * m_TPOffset;
        if (i >= 2)
        {
            double temp = (m_SRLines[i-2] - m_SRLines[i-1]);
            m_SellLimitOrder[i].m_SL = m_SRLines[i-1] + temp / 2 - temp * m_SLOffset;
        }
        else
        {
            m_SellLimitOrder[i].m_SL = -1;
        }
        m_SellLimitOrder[i].m_limitType = SELL_LIMIT;

        // handle buy limit order
        int j = i + 1;
        m_BuyLimitOrder[j-1].m_price = m_SRLines[j] + (m_SRLines[j-1] - m_SRLines[j]) * m_limitOffset;
        m_BuyLimitOrder[j-1].m_TP = m_SRLines[j-1] - (m_SRLines[j-1] - m_SRLines[j]) * m_TPOffset;
        if (j < m_SRLines_len - 2)
        {
            double temp = m_SRLines[j+1] - m_SRLines[j+2];
            m_BuyLimitOrder[j-1].m_SL = m_SRLines[j+1] - temp / 2 + temp * m_SLOffset;
        }
        else
        {
            m_BuyLimitOrder[j-1].m_SL = -1;
        }
        m_BuyLimitOrder[j-1].m_limitType = BUY_LIMIT;
    }
}

void SRLineManager::PrintOrderList(string outputFile)
{
    int fileHandle = FileOpen(m_outputFolder + "//" + outputFile, FILE_READ|FILE_WRITE|FILE_CSV);
    if(fileHandle != INVALID_HANDLE)
    {
        // CSV format : Sell limit, TP(Sell limit), SL(Sell limit), Buy limit, TP(Buy limit), SL(Buy limit)
        for (int i = 0; i < m_SellLimitOrder_len; i++)
        {
            FileWrite(fileHandle, m_SellLimitOrder[i].m_price, m_SellLimitOrder[i].m_TP, m_SellLimitOrder[i].m_SL, m_BuyLimitOrder[i].m_price, m_BuyLimitOrder[i].m_TP, m_BuyLimitOrder[i].m_SL);
        }
        //--- close the file
        FileClose(fileHandle);
        PrintFormat("Data is written, %s file is closed", outputFile);
    }
    else
    {
        PrintFormat("Failed to open %s file, Error code = %d", outputFile, GetLastError());
    }
}

void SRLineManager::OnTick(double lastPrice)
{
    m_lastPrice = lastPrice;
    if (m_lastPrice == -1)
    {
        InitTracker();
    }

    int hitIdx = m_tracker.IsLimit_Hit(m_lastPrice); // hit a buy limit or sell limit
    if (hitIdx != -1)
    {
        m_tracker.MakeAnOrder(hitIdx);
    }
    else
    {
        hitIdx = m_tracker.IsTP_SL_Hit(m_lastPrice); // hit TP or SL
        if (hitIdx != -1 && m_tracker.IsEmptyOrder())
        {
            m_tracker.Reset();
            InitTracker();
        }
        else if (hitIdx != -1)
        {
            m_tracker.ReFillOrder();
        }
    }
}

bool SRLineManager::HasNextRequest()
{
    return m_tracker.HasNextOrder();
}

MqlTradeRequest SRLineManager::GetNextLimitRequest()
{
    LimitOrder order = m_tracker.GetNextLimitOrder();
    MqlTradeRequest request;
    ZeroMemory(request);
    request.action = TRADE_ACTION_DEAL;
    request.type   = order.m_limitType == BUY_LIMIT ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
    request.price  = order.m_price;
    request.sl     = order.m_SL;
    request.tp     = order.m_TP;
    return request;
}

void SRLineManager::InitTracker()
{
    // find sell limit
    int justAbove = -1;
    for (int i = 0; i < m_SRLines_len - 1; i++)
    {
        if (m_SRLines[i] > m_lastPrice && m_lastPrice > m_SRLines[i+1])
        {
            justAbove = i;
            break;
        }
    }
    // add sell orders
    if (justAbove > -1)
    {
        for (int i = justAbove - m_SellLimitLayers + 1; i <= justAbove; i++)
        {
            if (i < 0)
                continue;
            m_tracker.AddOrder(m_SellLimitOrder[i]);
        }
    }
    // find buy limit
    int justBelow = -1;
    for (int i = m_SRLines_len - 1; i > 0; i--)
    {
        if (m_SRLines[i] < m_lastPrice && m_lastPrice < m_SRLines[i-1])
        {
            justBelow = i;
            break;
        }
    }
    // add buy orders
    if (justBelow > -1)
    {
        for (int i = justBelow + m_BuyLimitLayers - 1; i >= justBelow; i--)
        {
            if (i >= m_BuyLimitOrder_len)
                continue;
            m_tracker.AddOrder(m_BuyLimitOrder[i]);
        }
    }
}
