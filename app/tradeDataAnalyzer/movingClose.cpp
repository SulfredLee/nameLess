#include "movingClose.h"
#include "common.h"

#include <stdlib.h>
#include <math.h>

#include <fstream>
#include <map>

#define PI 3.14159265

MovingClose::MovingClose(){}

MovingClose::~MovingClose(){}

void MovingClose::InitComponent(const std::string& dataFile, const std::string& resultFile)
{
    m_dataFile = dataFile;
    m_movingAverageFile = resultFile + ".movingAvg.csv";
    m_slopePDFFile = resultFile + ".slopePDF.csv";
    m_tradeData = Common::GetOHLCFrom(m_dataFile);
    m_period = 5; // 5 bars period

    m_correctCount = 0;
    m_wrongCount = 0;
    m_totalCount = 0;
}

void MovingClose::Main()
{
    MakeMovingAverage();
    MakeMVSlopePDF();
}

void MovingClose::PrintResult()
{
    PrintMovingAverage();
    PrintMVSlopePDF();
}

int MovingClose::periodDirection(size_t periodStart, size_t periodEnd)
{
    if (m_tradeData[periodStart].close > m_tradeData[periodEnd].close)
        return -1;
    else if (m_tradeData[periodStart].close < m_tradeData[periodEnd].close)
        return 1;
    else
        return 0;
}

int MovingClose::currentDirection(size_t Idx)
{
    if (m_tradeData[Idx].open > m_tradeData[Idx].close)
        return -1;
    else if (m_tradeData[Idx].open < m_tradeData[Idx].close)
        return 1;
    else
        return 0;
}

bool MovingClose::isBigChange(size_t periodStart, size_t periodEnd)
{
    return abs(m_tradeData[periodStart].close - m_tradeData[periodEnd].close) > 1 ? true : false;
}

void MovingClose::MakeMovingAverage()
{
    for (size_t i = 0; i < m_period; i++)
    {
        m_mvAvg.push_back(0);
    }

    for (size_t i = m_period; i < m_tradeData.size(); i++)
    {
        size_t periodStart = i - m_period;
        size_t periodEnd = i - 1;
        m_mvAvg.push_back(MakeOneMV(periodStart, periodEnd));
    }
}

double MovingClose::MakeOneMV(size_t periodStart, size_t periodEnd)
{
    double sum = 0;
    for (size_t i = periodStart; i < periodEnd; i++)
    {
        sum += m_tradeData[i].close;
    }
    return sum / m_period;
}

void MovingClose::MakeMVSlopePDF()
{
    for (size_t i = 1; i < m_mvAvg.size(); i++)
    {
        // calculate slope
        double slope = (m_mvAvg[i-1] - m_mvAvg[i]) / 10;
        double angle = atan (slope) * 180 / PI;
        int intAngle = angle * 100 + 0.5;
        angle = static_cast<double>(intAngle) / 100;
        // count
        auto it = m_slopePDF.find(angle);
        if (it == m_slopePDF.end())
            m_slopePDF.insert(std::make_pair(angle, 1));
        else
            it->second++;
    }
}

void MovingClose::PrintMVSlopePDF()
{
    std::ofstream FH(m_slopePDFFile.c_str());
    for (auto it = m_slopePDF.begin(); it != m_slopePDF.end(); it++)
    {
        FH << it->first << "," << it->second << std::endl;
    }
    FH.close();
}

void MovingClose::PrintMovingAverage()
{
    std::ofstream FH(m_movingAverageFile.c_str());
    for (size_t i = 0; i < m_mvAvg.size(); i++)
    {
        FH << m_mvAvg[i] << std::endl;
    }
    FH.close();
}
