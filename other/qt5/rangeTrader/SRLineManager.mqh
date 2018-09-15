#property copyright "Copyright 2018, Damage Company"
#include "SRTracker.mqh"
#include "LimitOrder.mqh"
#include "triggerManager.mqh"
#include "../../Include/DCUtil/Logger.mqh"

#define EXPERT_MAGIC 338866   // MagicNumber of the expert

class SRLineManager
{
private:
    double m_SRLines[];
    int m_SRLines_len;
    LimitOrder m_SellLimitOrder[]; // 5 % above SRLine
    int m_SellLimitOrder_len;
    LimitOrder m_BuyLimitOrder[]; // 5 % below SRLine
    int m_BuyLimitOrder_len;
    LimitOrder m_SLOrder[]; // save SL order, when 2 SL order happened continuously, we will send e-mail alert
    int m_SLOrder_len;
    string m_inputFolder;
    string m_outputFolder;
    double m_limitOffset;
    double m_TPOffset;
    double m_SLOffset;
    int m_SellLimitLayers;
    int m_BuyLimitLayers;
    double m_lastPrice;
    SRTracker m_tracker;
    bool m_isFirstHit;
    bool m_isRunEA;
    double m_digitShift;
    double m_priceStep;
    TriggerManager m_triggerManager;
    Logger* m_Logger;
    string m_LogLine;
public:
    SRLineManager()
    {
        m_inputFolder = "Data";
        m_outputFolder = "Data";
        m_limitOffset = 0.05;
        m_TPOffset = 0.05;
        m_SLOffset = 0.1;
        m_lastPrice = -1;
        m_SellLimitLayers = 4;
        m_BuyLimitLayers = 4;
        m_isFirstHit = true;
        m_isRunEA = true;
        m_digitShift = MathPow(10, Digits());
        m_priceStep = 1 / m_digitShift;
    };
    ~SRLineManager()
    {
        ArrayFree(m_SRLines);
        ArrayFree(m_SellLimitOrder);
        ArrayFree(m_BuyLimitOrder);
        ArrayFree(m_SLOrder);
    };

    void InitComponent(string SRFile, Logger* gLogger);
    void PrintOrderList(string outputFile);
    void OnTick(double lastPrice);
    bool HasNextRequest();
    MqlTradeRequest GetNextLimitRequest();
    void RemoveRemainingOrder();
    void SetIndicatorsLen(int BL_Indicators_len, int SL_Indicators_len);
    void TestEmailAlert();
    bool IsWatingLastPrice();

private:
    int GetNumberOfSRLines(string inputFile);
    void InitSRLines(string inputFile);
    void InitOrders();
    bool InitTracker();
    void HandleDecimal();
    double GetDecimalRounding(const double& inData);
    void SLEmailAlert(int hitIdx);
    void ResetSLRecord();
};

void SRLineManager::InitComponent(string inSRFile, Logger* gLogger)
{
    m_Logger = gLogger;

    m_LogLine = StringFormat("%s:%d InitComponent", __FUNCTION__, __LINE__);
    m_Logger.PrintLog(m_LogLine);
    m_SRLines_len = GetNumberOfSRLines(inSRFile);
    m_LogLine = StringFormat("%s:%d m_SRLines_len: %d", __FUNCTION__, __LINE__, m_SRLines_len);
    m_Logger.PrintLog(m_LogLine);
    ArrayResize(m_SRLines, m_SRLines_len);
    ArrayResize(m_SLOrder, m_SellLimitLayers);

    InitSRLines(inSRFile);
    InitOrders();
    HandleDecimal();

    m_tracker.InitComponent(m_SellLimitLayers + m_BuyLimitLayers, gLogger);
    m_triggerManager.InitComponent("rangeTrader.config.ini", gLogger);

    m_LogLine = StringFormat("%s:%d m_priceStep: %f", __FUNCTION__, __LINE__, m_priceStep);
    m_Logger.PrintLog(m_LogLine);
}

int SRLineManager::GetNumberOfSRLines(string inputFile)
{
    m_LogLine = StringFormat("%s:%d GetNumberOfSRLines()", __FUNCTION__, __LINE__);
    m_Logger.PrintLog(m_LogLine);
    int numSRLine = 0;
    int FH = FileOpen(m_inputFolder + "//" + inputFile, FILE_TXT|FILE_READ);
    if(FH != INVALID_HANDLE)
    {
        m_LogLine = StringFormat("Reading SRFile: %s", inputFile);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("File path: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));
        m_Logger.PrintLog(m_LogLine);

        while (!FileIsEnding(FH))
        {
            FileReadString(FH);
            numSRLine++;
        }
        m_LogLine = StringFormat("Get number of m_SRLines: %d", numSRLine);
        m_Logger.PrintLog(m_LogLine);

        FileClose(FH);
        m_LogLine = StringFormat("Data is read, %s file is closed", inputFile);
        m_Logger.PrintLog(m_LogLine);
    }
    else
    {
        m_LogLine = StringFormat("Failed to open %s file, Error code = %d", inputFile, GetLastError());
        m_Logger.PrintLog(m_LogLine);
    }
    return numSRLine;
}

void SRLineManager::InitSRLines(string inputFile)
{
    m_LogLine = StringFormat("%s:%d InitSRLines()", __FUNCTION__, __LINE__);
    m_Logger.PrintLog(m_LogLine);
    int FH = FileOpen(m_inputFolder + "//" + inputFile, FILE_CSV|FILE_READ, ",");
    if(FH != INVALID_HANDLE)
    {
        m_LogLine = StringFormat("Reading SRFile: %s", inputFile);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("File path: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));
        m_Logger.PrintLog(m_LogLine);

        int index = 0;
        while (!FileIsEnding(FH))
        {
            m_SRLines[index++] = StringToDouble(FileReadString(FH)); // read the first column
            m_LogLine = StringFormat("Damage Debug, index: %f", m_SRLines[index - 1]);
            m_Logger.PrintLog(m_LogLine);
        }
        //--- close the file
        FileClose(FH);
        m_LogLine = StringFormat("Data is read, %s file is closed", inputFile);
        m_Logger.PrintLog(m_LogLine);
    }
    else
    {
        m_LogLine = StringFormat("Failed to open %s file, Error code = %d", inputFile, GetLastError());
        m_Logger.PrintLog(m_LogLine);
    }
}

void SRLineManager::InitOrders()
{
    m_SellLimitOrder_len = m_SRLines_len - 1;
    m_BuyLimitOrder_len = m_SRLines_len - 1;
    m_LogLine = StringFormat("m_SellLimitOrder_len: %d, m_BuyLimitOrder_len: %d", m_SellLimitOrder_len, m_BuyLimitOrder_len);
    m_Logger.PrintLog(m_LogLine);

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
        m_LogLine = StringFormat("m_SellLimitOrder_len: %d, m_BuyLimitOrder_len: %d", m_SellLimitOrder_len, m_BuyLimitOrder_len);
        m_Logger.PrintLog(m_LogLine);
        // CSV format : Sell limit, TP(Sell limit), SL(Sell limit), Buy limit, TP(Buy limit), SL(Buy limit)
        for (int i = 0; i < m_SellLimitOrder_len; i++)
        {
            FileWrite(fileHandle, m_SellLimitOrder[i].m_price, m_SellLimitOrder[i].m_TP, m_SellLimitOrder[i].m_SL, m_BuyLimitOrder[i].m_price, m_BuyLimitOrder[i].m_TP, m_BuyLimitOrder[i].m_SL);
            m_LogLine = StringFormat("m_SellLimitOrder[i].m_price: %f, m_SellLimitOrder[i].m_TP: %f, m_SellLimitOrder[i].m_SL: %f, m_BuyLimitOrder[i].m_price: %f, m_BuyLimitOrder[i].m_TP: %f, m_BuyLimitOrder[i].m_SL: %f", m_SellLimitOrder[i].m_price, m_SellLimitOrder[i].m_TP, m_SellLimitOrder[i].m_SL, m_BuyLimitOrder[i].m_price, m_BuyLimitOrder[i].m_TP, m_BuyLimitOrder[i].m_SL);
            m_Logger.PrintLog(m_LogLine);
        }
        //--- close the file
        FileClose(fileHandle);
        m_LogLine = StringFormat("Data is written, %s file is closed", outputFile);
        m_Logger.PrintLog(m_LogLine);
    }
    else
    {
        m_LogLine = StringFormat("Failed to open %s file, Error code = %d", outputFile, GetLastError());
        m_Logger.PrintLog(m_LogLine);
    }
}

void SRLineManager::OnTick(double lastPrice)
{
    if (!m_isRunEA && !m_triggerManager.IsTriggerOn(lastPrice))
        return;
    m_isRunEA = true;
    if (m_lastPrice == -1)
    {
        m_lastPrice = lastPrice;
        if (!InitTracker())
        {
            m_tracker.Reset();
            m_lastPrice = -1;
            return;
        }
        ResetSLRecord();
        m_tracker.RefreshOrder();
        m_LogLine = StringFormat("%s:%d First After InitTracker-----------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("lastPrice: %f", lastPrice);
        m_Logger.PrintLog(m_LogLine);
        m_tracker.DebugPrint();
        m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
    }
    m_lastPrice = lastPrice;

    int hitIdx = m_tracker.IsLimit_Hit(m_lastPrice); // hit a buy limit or sell limit
    if (hitIdx != -1)
    {
        m_LogLine = StringFormat("%s:%d IsLimit_Hit()--------------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_isFirstHit = false;
        m_LogLine = StringFormat("m_lastPrice: %f", m_lastPrice);
        m_Logger.PrintLog(m_LogLine);
        m_tracker.ActivateOrder(hitIdx);
        m_LogLine = StringFormat("%s:%d After ActivatedOrder", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_tracker.DebugPrint();
        m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
    }
    if (!m_isFirstHit)
    {
        ORDER_HIT_TYPE orderHitType;
        hitIdx = m_tracker.IsTP_SL_Hit(m_lastPrice, orderHitType); // hit TP or SL
        if (hitIdx != -1)
        {
            m_LogLine = StringFormat("m_lastPrice: %f", m_lastPrice);
            m_Logger.PrintLog(m_LogLine);
            if (m_tracker.IsEmptyOrder())
            {
                m_LogLine = StringFormat("%s:%d IsEmptyOrder()----------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                RemoveRemainingOrder();
                m_tracker.Reset();
                if (!InitTracker())
                {
                    m_LogLine = StringFormat("%s:%d Fail InitTracker", __FUNCTION__, __LINE__);
                    m_Logger.PrintLog(m_LogLine);
                    m_tracker.Reset();
                    m_lastPrice = -1;
                    return;
                }
                ResetSLRecord();
                m_tracker.RefreshOrder();
                m_LogLine = StringFormat("%s:%d Second After InitTracker-------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_tracker.DebugPrint();
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
            }
            else if(orderHitType == TP_HIT)
            {
                m_LogLine = StringFormat("%s:%d TP Hit--------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                ResetSLRecord();

                m_tracker.ReFillOrder();
                m_LogLine = StringFormat("%s:%d After ReFillOrder", __FUNCTION__, __LINE__);
                m_tracker.DebugPrint();
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
            }
            else if (orderHitType == SL_HIT)
            {
                m_LogLine = StringFormat("%s:%d SL HIT------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                SLEmailAlert(hitIdx);
                m_tracker.RemoveLimitOrder();
                m_LogLine = StringFormat("%s:%d After Remove Limit Order", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
                m_LogLine = StringFormat("%s:%d ---------------------------------------------------", __FUNCTION__, __LINE__);
                m_Logger.PrintLog(m_LogLine);
            }
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
    request.action = TRADE_ACTION_PENDING; // TRADE_ACTION_DEAL;
    request.type   = order.m_limitType == BUY_LIMIT ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
    request.price  = order.m_price;
    request.sl     = order.m_SL;
    request.tp     = order.m_TP;
    return request;
}

bool SRLineManager::InitTracker()
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
            if (i < 2) // the first two orders in sell limit array are not useful
                return false;
            m_tracker.AddOrder(m_SellLimitOrder[i]);
        }
    }
    else
    {
        return false;
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
    justBelow--; // alignment adjusting
    // add buy orders
    if (justBelow > -1)
    {
        for (int i = justBelow; i < justBelow + m_BuyLimitLayers; i++)
        {
            if (i >= m_BuyLimitOrder_len - 2) // the last two orders in buy limit array are not useful
                return false;
            m_tracker.AddOrder(m_BuyLimitOrder[i]);
        }
    }
    else
    {
        return false;
    }
    return true;
}

void SRLineManager::HandleDecimal()
{
    for (int i = 0; i < m_SRLines_len; i++)
    {
        m_SRLines[i] = GetDecimalRounding(m_SRLines[i]);
    }
    for (int i = 0; i < m_SellLimitOrder_len; i++)
    {
        m_SellLimitOrder[i].m_price = GetDecimalRounding(m_SellLimitOrder[i].m_price);
        m_SellLimitOrder[i].m_TP = GetDecimalRounding(m_SellLimitOrder[i].m_TP);
        m_SellLimitOrder[i].m_SL = GetDecimalRounding(m_SellLimitOrder[i].m_SL);
    }
    for (int i = 0; i < m_BuyLimitOrder_len; i++)
    {
        m_BuyLimitOrder[i].m_price = GetDecimalRounding(m_BuyLimitOrder[i].m_price);
        m_BuyLimitOrder[i].m_TP = GetDecimalRounding(m_BuyLimitOrder[i].m_TP);
        m_BuyLimitOrder[i].m_SL = GetDecimalRounding(m_BuyLimitOrder[i].m_SL);
    }
}

double SRLineManager::GetDecimalRounding(const double& inData)
{
    int resultInt = inData * m_digitShift + 0.5;
    return (double)resultInt / m_digitShift;
}

void SRLineManager::RemoveRemainingOrder()
{
    m_LogLine = StringFormat("%s:%d Called RemoveRemainingOrder()", __FUNCTION__, __LINE__);
    m_Logger.PrintLog(m_LogLine);
    MqlTradeRequest request={0};
    MqlTradeResult  result={0};
    int total = OrdersTotal(); // total number of placed pending orders
    //--- iterate over all placed pending orders
    for(int i = total-1; i >= 0; i--)
    {
        ulong  order_ticket = OrderGetTicket(i);                   // order ticket
        ulong  magic = OrderGetInteger(ORDER_MAGIC);               // MagicNumber of the order
        string symbol = OrderGetString(ORDER_SYMBOL);
        //--- if the MagicNumber matches
        if (magic == EXPERT_MAGIC && symbol == Symbol())
        {
            m_LogLine = StringFormat("Cleaning order %d", i);
            m_Logger.PrintLog(m_LogLine);
            //--- zeroing the request and result values
            ZeroMemory(request);
            ZeroMemory(result);
            //--- setting the operation parameters
            request.action = TRADE_ACTION_REMOVE;                   // type of trade operation
            request.order = order_ticket;                         // order ticket
            //--- send the request
            if (!OrderSend(request,result))
            {
                m_LogLine = StringFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
                m_Logger.PrintLog(m_LogLine);
            }
            //--- information about the operation
            m_LogLine = StringFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
            m_Logger.PrintLog(m_LogLine);
        }
    }
}

void SRLineManager::SLEmailAlert(int hitIdx)
{
    m_LogLine = StringFormat("%s:%d SLEmailAlert()", __FUNCTION__, __LINE__);
    m_Logger.PrintLog(m_LogLine);
    // add SL record
    m_SLOrder[m_SLOrder_len++] = m_tracker.GetHitOrder();

    if (m_SLOrder_len == 2)
    {
        string subject;
        subject = Symbol();
        subject += " 2 SL hit\n";

        string content;
        for (int i = 0; i < m_SLOrder_len; i++)
        {
            content += LimitOrderToString(m_SLOrder[i]);
            content += "\n";
        }
        m_LogLine = StringFormat("%s", content);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d SendMail is called", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);

        if (!SendMail(subject, content))
        {
            m_LogLine = StringFormat("SendMail error %d", GetLastError());
            m_Logger.PrintLog(m_LogLine);
        }
    }
    else if (m_SLOrder_len >= 3)
    {
        m_isRunEA = false;
        m_LogLine = StringFormat("%s:%d -------------------------EA is stopped due to 3 SL hit----------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d -------------------------EA is stopped due to 3 SL hit----------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d -------------------------EA is stopped due to 3 SL hit----------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        m_LogLine = StringFormat("%s:%d -------------------------EA is stopped due to 3 SL hit----------------------", __FUNCTION__, __LINE__);
        m_Logger.PrintLog(m_LogLine);
        RemoveRemainingOrder();
        m_tracker.Reset();
    }
}

void SRLineManager::ResetSLRecord()
{
    m_LogLine = StringFormat("%s:%d ResetSLRecord()", __FUNCTION__, __LINE__);
    m_Logger.PrintLog(m_LogLine);
    m_SLOrder_len = 0;
}

void SRLineManager::TestEmailAlert()
{
    string subject;
    subject = Symbol();
    subject += " 2 SL hit\n";

    string content = "testing email";
    for (int i = 0; i < m_SLOrder_len; i++)
    {
        content += LimitOrderToString(m_SLOrder[i]);
        content += "\n";
    }
    m_LogLine = StringFormat("%s", content);
    m_Logger.PrintLog(m_LogLine);
    m_LogLine = StringFormat("%s:%d SendMail is called", __FUNCTION__, __LINE__);
    m_Logger.PrintLog(m_LogLine);

    if (!SendMail(subject, content))
    {
        m_LogLine = StringFormat("SendMail error %d", GetLastError());
        m_Logger.PrintLog(m_LogLine);
    }
}

bool SRLineManager::IsWatingLastPrice()
{
    if (m_lastPrice == -1)
        return true;
    else
        return false;
}
