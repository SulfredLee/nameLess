#property copyright "Copyright 2018, Damage Company"

#include "../../Include/Trade/Trade.mqh"

class SLEarlyExit
{
private:
    int m_timeDifferent; // second
    double m_newSLRatio;
    ulong m_magic;
    CTrade m_trade;
public:
    SLEarlyExit(){}
    ~SLEarlyExit(){}

    void InitComponent(int day, int hour, int minute, double newSLRatio, ulong magic);
    void OnTick();
private:
    bool isPositionTooOld(int positionTime);
};

void SLEarlyExit::InitComponent(int day, int hour, int minute, double newSLRatio, ulong magic)
{
    m_timeDifferent = day * 24 * 3600 + hour * 3600 + minute * 60;
    m_newSLRatio = newSLRatio;
    m_magic = magic;
}

void SLEarlyExit::OnTick()
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
            double sl = PositionGetDouble(POSITION_SL);
            double volume = PositionGetDouble(POSITION_VOLUME);

            if (positionType == POSITION_TYPE_BUY)
            {
                double newSL = sl + (openPrice - sl) * m_newSLRatio;
                double askPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
                if (askPrice >= newSL)
                {
                    // early exit
                    m_trade.PositionClosePartial(position_ticket, volume);
                }
            }
            else
            {
                double newSL = sl - (sl - openPrice) * m_newSLRatio;
                double bitPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
                if (bitPrice <= newSL)
                {
                    // early exit
                    m_trade.PositionClosePartial(position_ticket, volume);
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

bool SLEarlyExit::isPositionTooOld(int positionTime)
{
    if (TimeCurrent() - positionTime >= m_timeDifferent)
        return true;
    else
        return false;
}
