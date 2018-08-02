#include "dbBuilder.h"
#include "Logger.h"
#include "Tools.h"

#include <fstream>

#include <math.h>
DBBuilder::DBBuilder(const std::string& inFile)
{
    LOGMSG_INFO("Process File: %s", inFile.c_str());
    std::ifstream FH(inFile.c_str());
    if (!FH.is_open())
    {
        LOGMSG_ERROR("Cannot open file %s", inFile.c_str());
    }
    else
    {
        bool isFirstLine = true;
        std::string line;
        while (std::getline(FH, line))
        {
            std::vector<std::string> parts = Utility::splitString(line, '\t');
            if (isFirstLine)
            {
                if (parts.size() == 5) // symbol, created file time, total OHLC, pre-calculated, digits
                {
                    m_forexInfo.symbol = parts[0];
                    m_forexInfo.totalOHLC = std::stoi(parts[2]);
                    m_forexInfo.digit = std::stoi(parts[4]) < 0 ? 0 : std::stoi(parts[4]);
                    m_forexInfo.shifter = pow(10, m_forexInfo.digit);
                }
                isFirstLine = false;
            }
            else
            {
                if (parts.size() == 8) // time, open, high, low, close, tick_volume, volume, spread
                {
                    if (parts[0].size() < 19)
                    {
                        continue;
                    }
                    m_OHLCs.push_back(MakeOHLC(parts));
                }
            }
        }
        FH.close();
        m_forexInfo.totalOHLC = m_OHLCs.size();
    }
}
DBBuilder::~DBBuilder()
{}

ForexInfo& DBBuilder::GetInfo()
{
    return m_forexInfo;
}

std::vector<OHLC>& DBBuilder::GetOHLCs()
{
    return m_OHLCs;
}

OHLC DBBuilder::MakeOHLC(const std::vector<std::string>& inData)
{
    OHLC result;

    result.time.SetFromString(inData[0], "%Y.%m.%d %H.%M.%S");
    result.open = ShiftByDigit(inData[1]);
    result.high = ShiftByDigit(inData[2]);
    result.low = ShiftByDigit(inData[3]);
    result.close = ShiftByDigit(inData[4]);
    result.tickVolume = std::stoi(inData[5]);
    result.volume = std::stoi(inData[6]);
    result.spread = std::stoi(inData[7]);

    return result;
}

int DBBuilder::ShiftByDigit(const std::string& inValue)
{
    return std::stod(inValue) * m_forexInfo.shifter;
}
