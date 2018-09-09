#property copyright "Copyright 2018, Damage Company"

#include "../../Include/Trade/Trade.mqh"

class TPEarlyExit
{
private:
    int m_timeDifferent; // second
    double m_newTPRatio;
    ulong m_magic;
    CTrade m_trade;
public:
    TPEarlyExit(){}
    ~TPEarlyExit(){}

    void InitComponent(int day, int hour, int minute, double newTPRatio, ulong magic);
    void OnTick();
private:
    bool isPositionTooOld(int positionTime);
};

void TPEarlyExit::InitComponent(int day, int hour, int minute, double newTPRatio, ulong magic)
{
    m_timeDifferent = day * 24 * 3600 + hour * 3600 + minute * 60;
    m_newTPRatio = newTPRatio;
    m_magic = magic;
}

void TPEarlyExit::OnTick()
{
    for (int i = 0; i < PositionsTotal(); i++)
    {
        ulong position_ticket = PositionGetTicket(i);
        string position_symbol = PositionGetString(POSITION_SYMBOL);
        ulong magic = PositionGetInteger(POSITION_MAGIC);
        if (m_magic == magic && isPositionTooOld(PositionGetInteger(POSITION_TIME)))
        {
            ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double tp = PositionGetDouble(POSITION_TP);
            double volume = PositionGetDouble(POSITION_VOLUME);

            if (positionType == POSITION_TYPE_BUY)
            {
                double newTP = tp - (tp - openPrice) * m_newTPRatio;
                double askPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
                if (openPrice <= askPrice && askPrice >= newTP)
                {
                    // early exit
                    m_trade.PositionClosePartial(position_ticket, volume);
                    PrintFormat("%s:%d early exit, buy type", __FUNCTION__, __LINE__);
                }
            }
            else
            {
                double newTP = tp + (openPrice - tp) * m_newTPRatio;
                double bitPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
                if (openPrice >= bitPrice && bitPrice <= newTP)
                {
                    // early exit
                    m_trade.PositionClosePartial(position_ticket, volume);
                    PrintFormat("%s:%d early exit, sell type", __FUNCTION__, __LINE__);
                }
            }
            // MqlTradeRequest request;
            // MqlTradeResult  result;
            // //--- zeroing the request and result values
            // ZeroMemory(request);
            // ZeroMemory(result);
            // //--- setting the operation parameters
            // request.action = TRADE_ACTION_SLTP; // type of trade operation
            // request.position = position_ticket;   // ticket of the position
            // request.symbol = position_symbol;     // symbol
            // request.sl = sl;                // Stop Loss of the position
            // request.tp = tp;                // Take Profit of the position
            // request.magic = m_magic;         // MagicNumber of the position
            // //--- output information about the modification
            // PrintFormat("Modify #%I64d %s %s", position_ticket, position_symbol, EnumToString(type));
            // //--- send the request
            // if(!OrderSend(request, result))
            //     PrintFormat("OrderSend error %d", GetLastError());  // if unable to send the request, output the error code
            // //--- information about the operation
            // PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);

            // datetime time_start = (datetime)PositionGetInteger(POSITION_TIME);
            // PrintFormat("id: %d, positionObservation, symbol: %s, time_start: %s, sl: %f, tp: %f", position_ticket, position_symbol, TimeToString(time_start), sl, tp);
        }
    }
}

bool TPEarlyExit::isPositionTooOld(int positionTime)
{
    if (TimeCurrent() - positionTime >= m_timeDifferent)
        return true;
    else
        return false;
}
