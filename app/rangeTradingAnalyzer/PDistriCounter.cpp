#include "PDistriCounter.h"
#include "Logger.h"

#include <iostream>

PDistriCounter::PDistriCounter()
{
}

PDistriCounter::~PDistriCounter()
{
}

int PDistriCounter::DoCountingPost(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType, NLTime endTime)
{
    int nextIdx = -1;
    m_hashCounter.clear();
    size_t i = startIdx;
    for (; i < inData.size() && inData[i].time < endTime; i++)
    {
        CountAPrice(inData[i].low, inData[i].high);
    }

    Convert2Result();

    if (i >= inData.size())
    {
        nextIdx = -1;
    }
    else
    {
        nextIdx = i;
    }
    return nextIdx;
}

void PDistriCounter::CountAPrice(int lowPrice, int highPrice)
{
    for (int i = lowPrice; i <= highPrice; i++)
    {
        auto it = m_hashCounter.find(i);
        if (it == m_hashCounter.end())
        {
            m_hashCounter.insert(std::make_pair(i, 1));
        }
        else
        {
            it->second++;
        }
    }
}

std::string PDistriCounter::GetOutputFileName(const std::string& inputFile, const NLTime& startTime, const NLTime& endTime, Counter::RangeType rangeType)
{
    std::stringstream ss;
    ss << inputFile << "." << startTime.toString("%Y.%m.%d") << "_" << endTime.toString("%Y.%m.%d") << "." << RangeType2String(rangeType) << ".dis.csv";
    return ss.str();
}
