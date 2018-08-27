#property copyright "Copyright 2018, Damage Company"

#include "LimitOrder.mqh"
#include "common.mqh"

class SRLineDrawer
{
public:
    SRLineDrawer()
    {
    }
    ~SRLineDrawer()
    {
    }

    void DrawLine(LimitOrder& head[], int len);
private:
    void DrawBL(int index, double price);
    void DrawSL(int index, double price);
};

void SRLineDrawer::DrawLine(LimitOrder& head[], int len)
{
    PrintFormat("DrawLine, len: %d", len);
    int BL_Count = 0;
    int SL_Count = 0;
    for (int i = 0; i < len; i++)
    {
        if (head[i].m_limitType == BUY_LIMIT)
        {
            DrawBL(BL_Count++, head[i].m_price);
        }
        else
        {
            DrawSL(SL_Count++, head[i].m_price);
        }
    }

    // clear indicator
    for (int i = BL_Count; i < BL_LAYERS; i++)
    {
        DrawBL(i, 0.0);
    }
    for (int i = SL_Count; i < SL_LAYERS; i++)
    {
        DrawSL(i, 0.0);
    }
}

void SRLineDrawer::DrawBL(int index, double price)
{
    for (int i = 0; i < gBL_Indicators[index].Size(); i++)
    {
        gBL_Indicators[index].SetValue(price, i);
    }
}

void SRLineDrawer::DrawSL(int index, double price)
{
    for (int i = 0; i < gSL_Indicators[index].Size(); i++)
    {
        gSL_Indicators[index].SetValue(price, i);
    }
}
