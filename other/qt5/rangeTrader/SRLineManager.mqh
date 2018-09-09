#property copyright "Copyright 2018, Damage Company"
#include "SRTracker.mqh"
#include "LimitOrder.mqh"
#include "triggerManager.mqh"

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

        PrintFormat("m_priceStep: %f", m_priceStep);
    };
    ~SRLineManager()
    {
        ArrayFree(m_SRLines);
        ArrayFree(m_SellLimitOrder);
        ArrayFree(m_BuyLimitOrder);
        ArrayFree(m_SLOrder);
    };

    void InitComponent(string SRFile);
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

void SRLineManager::InitComponent(string inSRFile)
{
    PrintFormat("InitComponent");
    m_SRLines_len = GetNumberOfSRLines(inSRFile);
    PrintFormat("m_SRLines_len: %d", m_SRLines_len);
    ArrayResize(m_SRLines, m_SRLines_len);
    ArrayResize(m_SLOrder, m_SellLimitLayers);

    InitSRLines(inSRFile);
    InitOrders();
    HandleDecimal();

    m_tracker.InitComponent(m_SellLimitLayers + m_BuyLimitLayers);
    m_triggerManager.InitComponent("rangeTrader.config.ini");
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
    PrintFormat("m_SellLimitOrder_len: %d, m_BuyLimitOrder_len: %d", m_SellLimitOrder_len, m_BuyLimitOrder_len);

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
        PrintFormat("m_SellLimitOrder_len: %d, m_BuyLimitOrder_len: %d", m_SellLimitOrder_len, m_BuyLimitOrder_len);
        // CSV format : Sell limit, TP(Sell limit), SL(Sell limit), Buy limit, TP(Buy limit), SL(Buy limit)
        for (int i = 0; i < m_SellLimitOrder_len; i++)
        {
            FileWrite(fileHandle, m_SellLimitOrder[i].m_price, m_SellLimitOrder[i].m_TP, m_SellLimitOrder[i].m_SL, m_BuyLimitOrder[i].m_price, m_BuyLimitOrder[i].m_TP, m_BuyLimitOrder[i].m_SL);
            PrintFormat("m_SellLimitOrder[i].m_price: %f, m_SellLimitOrder[i].m_TP: %f, m_SellLimitOrder[i].m_SL: %f, m_BuyLimitOrder[i].m_price: %f, m_BuyLimitOrder[i].m_TP: %f, m_BuyLimitOrder[i].m_SL: %f", m_SellLimitOrder[i].m_price, m_SellLimitOrder[i].m_TP, m_SellLimitOrder[i].m_SL, m_BuyLimitOrder[i].m_price, m_BuyLimitOrder[i].m_TP, m_BuyLimitOrder[i].m_SL);
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
        PrintFormat("First After InitTracker-----------------------------------------");
        PrintFormat("lastPrice: %f", lastPrice);
        m_tracker.DebugPrint();
        PrintFormat("---------------------------------------------------");
        PrintFormat("---------------------------------------------------");
        PrintFormat("---------------------------------------------------");
    }
    m_lastPrice = lastPrice;

    int hitIdx = m_tracker.IsLimit_Hit(m_lastPrice); // hit a buy limit or sell limit
    if (hitIdx != -1)
    {
        PrintFormat("IsLimit_Hit()--------------------------------------------");
        m_isFirstHit = false;
        PrintFormat("m_lastPrice: %f", m_lastPrice);
        m_tracker.ActivateOrder(hitIdx);
        PrintFormat("After ActivatedOrder");
        m_tracker.DebugPrint();
        PrintFormat("---------------------------------------------------");
        PrintFormat("---------------------------------------------------");
        PrintFormat("---------------------------------------------------");
    }
    if (!m_isFirstHit)
    {
        ORDER_HIT_TYPE orderHitType;
        hitIdx = m_tracker.IsTP_SL_Hit(m_lastPrice, orderHitType); // hit TP or SL
        if (hitIdx != -1)
        {
            PrintFormat("m_lastPrice: %f", m_lastPrice);
            if (m_tracker.IsEmptyOrder())
            {
                PrintFormat("IsEmptyOrder()----------------------------------------------");
                RemoveRemainingOrder();
                m_tracker.Reset();
                if (!InitTracker())
                {
                    PrintFormat("Fail InitTracker");
                    m_tracker.Reset();
                    m_lastPrice = -1;
                    return;
                }
                ResetSLRecord();
                m_tracker.RefreshOrder();
                PrintFormat("Second After InitTracker-------------------------------------");
                m_tracker.DebugPrint();
                PrintFormat("---------------------------------------------------");
                PrintFormat("---------------------------------------------------");
                PrintFormat("---------------------------------------------------");
            }
            else if(orderHitType == TP_HIT)
            {
                PrintFormat("TP Hit--------------------------------------");
                ResetSLRecord();

                m_tracker.ReFillOrder();
                PrintFormat("After ReFillOrder");
                m_tracker.DebugPrint();
                PrintFormat("---------------------------------------------------");
                PrintFormat("---------------------------------------------------");
                PrintFormat("---------------------------------------------------");
            }
            else if (orderHitType == SL_HIT)
            {
                PrintFormat("SL HIT------------------------------------------");
                SLEmailAlert(hitIdx);
                m_tracker.RemoveLimitOrder();
                PrintFormat("After Remove Limit Order");
                m_tracker.DebugPrint();
                PrintFormat("---------------------------------------------------");
                PrintFormat("---------------------------------------------------");
                PrintFormat("---------------------------------------------------");
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
    PrintFormat("Called RemoveRemainingOrder()");
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
            PrintFormat("Cleaning order %d", i);
            //--- zeroing the request and result values
            ZeroMemory(request);
            ZeroMemory(result);
            //--- setting the operation parameters
            request.action = TRADE_ACTION_REMOVE;                   // type of trade operation
            request.order = order_ticket;                         // order ticket
            //--- send the request
            if (!OrderSend(request,result))
                PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
            //--- information about the operation
            PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
        }
    }
}

void SRLineManager::SLEmailAlert(int hitIdx)
{
    PrintFormat("SLEmailAlert()");
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
        PrintFormat("%s", content);
        PrintFormat("SendMail is called");

        if (!SendMail(subject, content))
        {
            PrintFormat("SendMail error %d", GetLastError());
        }
    }
    else if (m_SLOrder_len >= 3)
    {
        m_isRunEA = false;
        PrintFormat("-------------------------EA is stopped due to 3 SL hit----------------------");
        PrintFormat("-------------------------EA is stopped due to 3 SL hit----------------------");
        PrintFormat("-------------------------EA is stopped due to 3 SL hit----------------------");
        PrintFormat("-------------------------EA is stopped due to 3 SL hit----------------------");
        RemoveRemainingOrder();
        m_tracker.Reset();
    }
}

void SRLineManager::ResetSLRecord()
{
    PrintFormat("ResetSLRecord()");
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
    PrintFormat("%s", content);
    PrintFormat("SendMail is called");

    if (!SendMail(subject, content))
    {
        PrintFormat("SendMail error %d", GetLastError());
    }
}

bool SRLineManager::IsWatingLastPrice()
{
    if (m_lastPrice == -1)
        return true;
    else
        return false;
}
