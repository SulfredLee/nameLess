#property copyright "Copyright 2018, Damage Company"

enum LIMIT_ORDER_TYPE
{
    BUY_LIMIT = 0,
    SELL_LIMIT = 1,
};

struct LimitOrder
{
    double m_price;
    double m_TP; // take profit
    double m_SL; // stop loss
    LIMIT_ORDER_TYPE m_limitType;
};
string LimitOrderToString(const LimitOrder& order)
{
    string result = "price: ";
    result += DoubleToString(order.m_price);
    result += " TP: " + DoubleToString(order.m_TP);
    result += " SL: " + DoubleToString(order.m_SL);
    if (order.m_limitType == BUY_LIMIT)
        result += " limitType: BuyLimit";
    else
        result += " limitType: SellLimit";
    return result;
}
