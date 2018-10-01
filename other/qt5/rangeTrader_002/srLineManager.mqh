#include "../../Include/DCUtil/Logger.mqh"
#include <Arrays\ArrayDouble.mqh>
#include "LimitOrder.mqh"

class SRLineManager
{
private:
    string m_inputFolder;
    string m_outputFolder;
    string m_srFile;
    string m_orderFile;
    Logger* m_logger;
    // support and resistance lines
    CArrayDouble m_srLines;
    // stop loss order record for e-mail alert
    LimitOrder m_slOrder[]; // save SL order, when 2 SL order happened continuously, we will send e-mail alert
    int m_slOrderTotal; // m_slOrder total element
    int m_slOrderLength; // m_slOrder memory size
    // SLimit orders
    LimitOrder m_sLimitOrder[]; // 5 % above SRLine
    int m_sLimitOrderTotal;
    int m_sLimitOrderLength;
    // BLimit orders
    LimitOrder m_bLimitOrder[]; // 5 % below SRLine
    int m_bLimitOrderTotal;
    int m_bLimitOrderLength;
    // Limit orders
    double m_limitOffset;
    double m_tpOffset;
    double m_slOffset;
    // Limit Pending orders
    LimitOrder m_limitPendingOrder[];
    int m_limitPendingOrderTotal;
    int m_limitPendingOrderLength;
    int m_sLimitPendingOrderTotal;
    int m_bLimitPendingOrderTotal;
public:
    SRLineManager();
    ~SRLineManager();

    void InitComponent(Logger* logger);
    void MakeLimitRequest();
    bool HasNextLimitRequest();
    MqlTradeRequest GetNextLimitRequest();
private:
    int GetNumberOfSRLines(string inputFile);
    void InitSRLines(string inputFile);
    void InitLimitOrders();
    void PrintOrderList(string outputFile);
    bool MakeLimitRequest_();
};

SRLineManager::SRLineManager()
{
}

SRLineManager::~SRLineManager()
{
    ArrayFree(m_slOrder);
    m_srLines.Shutdown();
    ArrayFree(m_sLimitOrder);
    ArrayFree(m_bLimitOrder);
    ArrayFree(m_limitPendingOrder);
}

void SRLineManager::InitComponent(Logger* logger)
{
    m_logger = logger;
    m_logger.PrintLog(StringFormat("%s:%d IN", __FUNCTION__, __LINE__));
    m_logger.PrintLog(StringFormat("%s:%d File path: %s\\Files\\", __FUNCTION__, __LINE__, TerminalInfoString(TERMINAL_DATA_PATH)));

    m_inputFolder = "Data";
    m_outputFolder = "Data";
    m_srFile = Symbol() + ".csv";
    m_orderFile = Symbol() + ".orderList.csv";
    // init SR line
    m_srLines.Resize(GetNumberOfSRLines(m_srFile));
    InitSRLines(m_srFile);
    // init SLimit and BLimit orders
    m_limitOffset = 0.05;
    m_tpOffset = 0.05;
    m_slOffset = 0.1;
    InitLimitOrders();
    // normalize double
    for (int i = 0; i < m_srLines.Total(); i++)
    {
        m_srLines.Update(i, NormalizeDouble(m_srLines.At(i), Digits()));
    }
    for (int i = 0; i < m_sLimitOrderLength; i++)
    {
        NormalizeLimitOrder(m_sLimitOrder[i]);
    }
    for (int i = 0; i < m_bLimitOrderLength; i++)
    {
        NormalizeLimitOrder(m_bLimitOrder[i]);
    }
    // print order list for debug
    PrintOrderList(m_orderFile);
    // init SL order for e-mail alert
    m_slOrderTotal = 0;
    m_slOrderLength = 4;
    ArrayResize(m_slOrder, m_slOrderLength);
    // init pending limit orders
    m_sLimitPendingOrderTotal = 4;
    m_bLimitPendingOrderTotal = 4;
    m_limitPendingOrderLength = m_sLimitPendingOrderTotal + m_bLimitPendingOrderTotal;
    m_limitPendingOrderTotal = 0;
    ArrayResize(m_limitPendingOrder, m_limitPendingOrderLength);

    m_logger.PrintLog(StringFormat("%s:%d OUT", __FUNCTION__, __LINE__));
}

int SRLineManager::GetNumberOfSRLines(string inputFile)
{
    m_logger.PrintLog(StringFormat("%s:%d IN", __FUNCTION__, __LINE__));

    int numSRLine = 0;
    int FH = FileOpen(m_inputFolder + "//" + inputFile, FILE_TXT|FILE_READ);
    if(FH != INVALID_HANDLE)
    {
        m_logger.PrintLog(StringFormat("%s:%d Reading SRFile: %s", __FUNCTION__, __LINE__, inputFile));
        while (!FileIsEnding(FH))
        {
            FileReadString(FH);
            numSRLine++;
        }
        FileClose(FH);
        m_logger.PrintLog(StringFormat("%s:%d Data is read, %s file is closed", __FUNCTION__, __LINE__, inputFile));
        m_logger.PrintLog(StringFormat("%s:%d Get number of number of SRLines: %d", __FUNCTION__, __LINE__, numSRLine));
    }
    else
    {
        m_logger.PrintLog(StringFormat("%s:%d Failed to open %s file, Error code = %d", __FUNCTION__, __LINE__, inputFile, GetLastError()));
    }
    return numSRLine;

    m_logger.PrintLog(StringFormat("%s:%d OUT", __FUNCTION__, __LINE__));
}

void SRLineManager::InitSRLines(string inputFile)
{
    m_logger.PrintLog(StringFormat("%s:%d IN", __FUNCTION__, __LINE__));

    int FH = FileOpen(m_inputFolder + "//" + inputFile, FILE_CSV|FILE_READ, ",");
    if(FH != INVALID_HANDLE)
    {
        m_logger.PrintLog(StringFormat("%s:%d Reading SRFile: %s", __FUNCTION__, __LINE__, inputFile));

        int index = 0;
        while (!FileIsEnding(FH))
        {
            m_srLines.Add(StringToDouble(FileReadString(FH)));
            m_logger.PrintLog(StringFormat("%s:%d index:%d, srLines: %f", __FUNCTION__, __LINE__, index, m_srLines.At(index)));
            index++;
        }
        FileClose(FH);
        m_logger.PrintLog(StringFormat("%s:%d Data is read, %s file is closed", __FUNCTION__, __LINE__, inputFile));
    }
    else
    {
        m_logger.PrintLog(StringFormat("%s:%d Failed to open %s file, Error code = %d", __FUNCTION__, __LINE__, inputFile, GetLastError()));
    }

    m_logger.PrintLog(StringFormat("%s:%d OUT", __FUNCTION__, __LINE__));
}

void SRLineManager::InitLimitOrders()
{
    m_logger.PrintLog(StringFormat("%s:%d IN", __FUNCTION__, __LINE__));

    m_sLimitOrderLength = m_srLines.Total() - 1;
    m_bLimitOrderLength = m_srLines.Total() - 1;
    m_sLimitOrderTotal = m_sLimitOrderLength;
    m_bLimitOrderTotal = m_bLimitOrderLength;
    m_logger.PrintLog(StringFormat("%s:%d m_sLimitOrderLength: %d, m_bLimitOrderLength: %d", __FUNCTION__, __LINE__, m_sLimitOrderLength, m_bLimitOrderLength));

    ArrayResize(m_sLimitOrder, m_sLimitOrderLength);
    ArrayResize(m_bLimitOrder, m_bLimitOrderLength);
    for (int i = 0 ; i < m_srLines.Total() - 1; i++)
    {
        // handle sell limit order
        m_sLimitOrder[i].m_price = m_srLines.At(i) - (m_srLines.At(i) - m_srLines.At(i+1)) * m_limitOffset;
        m_sLimitOrder[i].m_TP = m_srLines.At(i+1) + (m_srLines.At(i) - m_srLines.At(i+1)) * m_tpOffset;
        if (i >= 2)
        {
            double temp = (m_srLines.At(i-2) - m_srLines.At(i-1));
            m_sLimitOrder[i].m_SL = m_srLines.At(i-1) + temp / 2 - temp * m_slOffset;
        }
        else
        {
            m_sLimitOrder[i].m_SL = -1;
        }
        m_sLimitOrder[i].m_limitType = SELL_LIMIT;

        // handle buy limit order
        int j = i + 1;
        m_bLimitOrder[j-1].m_price = m_srLines.At(j) + (m_srLines.At(j-1) - m_srLines.At(j)) * m_limitOffset;
        m_bLimitOrder[j-1].m_TP = m_srLines.At(j-1) - (m_srLines.At(j-1) - m_srLines.At(j)) * m_tpOffset;
        if (j < m_srLines.Total() - 2)
        {
            double temp = m_srLines.At(j+1) - m_srLines.At(j+2);
            m_bLimitOrder[j-1].m_SL = m_srLines.At(j+1) - temp / 2 + temp * m_slOffset;
        }
        else
        {
            m_bLimitOrder[j-1].m_SL = -1;
        }
        m_bLimitOrder[j-1].m_limitType = BUY_LIMIT;
    }

    m_logger.PrintLog(StringFormat("%s:%d OUT", __FUNCTION__, __LINE__));
}

void SRLineManager::PrintOrderList(string outputFile)
{
    m_logger.PrintLog(StringFormat("%s:%d IN", __FUNCTION__, __LINE__));

    int fileHandle = FileOpen(m_outputFolder + "//" + outputFile, FILE_READ|FILE_WRITE|FILE_CSV);
    if(fileHandle != INVALID_HANDLE)
    {
        m_logger.PrintLog(StringFormat("%s:%d m_sLimitOrderLength: %d, m_bLimitOrderLength: %d", __FUNCTION__, __LINE__, m_sLimitOrderLength, m_bLimitOrderLength));
        // CSV format : Sell limit, TP(Sell limit), SL(Sell limit), Buy limit, TP(Buy limit), SL(Buy limit)
        for (int i = 0; i < m_sLimitOrderLength; i++)
        {
            FileWrite(fileHandle, m_sLimitOrder[i].m_price, m_sLimitOrder[i].m_TP, m_sLimitOrder[i].m_SL, m_bLimitOrder[i].m_price, m_bLimitOrder[i].m_TP, m_bLimitOrder[i].m_SL);
        }
        //--- close the file
        FileClose(fileHandle);
        m_logger.PrintLog(StringFormat("%s:%d Data is written, %s file is closed", __FUNCTION__, __LINE__, outputFile));
    }
    else
    {
        m_logger.PrintLog(StringFormat("%s:%d Failed to open %s file, Error code = %d", __FUNCTION__, __LINE__, outputFile, GetLastError()));
    }

    m_logger.PrintLog(StringFormat("%s:%d OUT", __FUNCTION__, __LINE__));
}

void SRLineManager::MakeLimitRequest()
{
    m_logger.PrintLog(StringFormat("%s:%d IN", __FUNCTION__, __LINE__));

    // reset request array
    m_limitPendingOrderTotal = 0;
    if (!MakeLimitRequest_())
    {
        m_limitPendingOrderTotal = 0;
        m_logger.PrintLog(StringFormat("%s:%d Fail MakeLimitRequest_()", __FUNCTION__, __LINE__));
    }

    m_logger.PrintLog(StringFormat("%s:%d OUT", __FUNCTION__, __LINE__));
}

bool SRLineManager::MakeLimitRequest_()
{
    double lastPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    m_logger.PrintLog(StringFormat("%s:%d lastPrice: %f", __FUNCTION__, __LINE__, lastPrice));
    // find sell limit
    int justAbove = -1;
    for (int i = 0; i < m_srLines.Total() - 1; i++)
    {
        if (m_srLines.At(i) > lastPrice && lastPrice > m_srLines.At(i+1))
        {
            justAbove = i;
            break;
        }
    }
    // add sell orders
    if (justAbove > -1)
    {
        for (int i = justAbove - m_sLimitPendingOrderTotal + 1; i <= justAbove; i++)
        {
            if (i < 2) // the first two orders in sell limit array are not useful
            {
                m_logger.PrintLog(StringFormat("%s:%d i is too small", __FUNCTION__, __LINE__));
                return false;
            }
            m_limitPendingOrder[m_limitPendingOrderTotal++] = m_sLimitOrder[i];
        }
    }
    else
    {
        m_logger.PrintLog(StringFormat("%s:%d cannot find justAbove", __FUNCTION__, __LINE__));
        return false;
    }
    // find buy limit
    int justBelow = -1;
    for (int i = m_srLines.Total() - 1; i > 0; i--)
    {
        if (m_srLines.At(i) < lastPrice && lastPrice < m_srLines.At(i-1))
        {
            justBelow = i;
            break;
        }
    }
    justBelow--; // alignment adjusting
    // add buy orders
    if (justBelow > -1)
    {
        for (int i = justBelow; i < justBelow + m_bLimitPendingOrderTotal; i++)
        {
            if (i >= m_bLimitOrderTotal - 2) // the last two orders in buy limit array are not useful
            {
                m_logger.PrintLog(StringFormat("%s:%d i is too large", __FUNCTION__, __LINE__));
                return false;
            }
            m_limitPendingOrder[m_limitPendingOrderTotal++] = m_bLimitOrder[i];
        }
    }
    else
    {
        m_logger.PrintLog(StringFormat("%s:%d cannot find justBelow", __FUNCTION__, __LINE__));
        return false;
    }
    return true;
}

bool SRLineManager::HasNextLimitRequest()
{
    if (m_limitPendingOrderTotal > 0)
        return true;
    else
        return false;
}

MqlTradeRequest SRLineManager::GetNextLimitRequest()
{
    LimitOrder order = m_limitPendingOrder[--m_limitPendingOrderTotal];
    MqlTradeRequest request;
    ZeroMemory(request);
    request.action = TRADE_ACTION_PENDING; // TRADE_ACTION_DEAL;
    request.type   = order.m_limitType == BUY_LIMIT ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
    request.price  = order.m_price;
    request.sl     = order.m_SL;
    request.tp     = order.m_TP;
    request.symbol = Symbol();
    return request;
}
