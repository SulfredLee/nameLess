#include "Counter.h"
#include "Logger.h"

std::string RangeType2String(Counter::RangeType rangeType)
{
    switch (rangeType)
    {
        case Counter::RangeType::MONTH: return "Mon";
        case Counter::RangeType::DAY: return "Day";
        case Counter::RangeType::HOUR: return "Hour";
        case Counter::RangeType::MINUTE: return "Min";
        default: return"";
    }
}

bool priceCompare(const ResultData& firstElem, const ResultData& secondElem)
{
    return firstElem.price < secondElem.price;
}

bool occurrenceCompare(const ResultData& firstElem, const ResultData& secondElem)
{
    return firstElem.occurrence > secondElem.occurrence;
}

int Counter::DoCounting(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType)
{
    if (startIdx >= inData.size())
    {
        return -1;
    }
    int Y, Mon, D, H, Min, S;
    NLTime endTime = inData[startIdx].time;
    endTime.GetDate(Y, Mon, D);
    endTime.GetTime(H, Min, S);
    switch (rangeType)
    {
        case Counter::RangeType::MONTH:
            endTime.SetDate(Y, Mon, 1);
            endTime.SetTime(0, 0, 0);
            endTime.AddDate(0, timeRange, 0);
            break;
        case Counter::RangeType::DAY:
            endTime.SetTime(0, 0, 0);
            endTime.AddDate(0, 0, timeRange);
            break;
        case Counter::RangeType::HOUR:
            endTime.SetTime(H, 0, 0);
            endTime.AddTime(timeRange, 0, 0);
            break;
        case Counter::RangeType::MINUTE:
            endTime.SetTime(H, Min, 0);
            endTime.AddTime(0, timeRange, 0);
            break;
        default: break;
    }
    LOGMSG_DEBUG("startTime: %s", inData[startIdx].time.toString("%Y.%m.%d %H.%M.%S").c_str());
    LOGMSG_DEBUG("endTime: %s", endTime.toString("%Y.%m.%d %H.%M.%S").c_str());
    return DoCountingPost(startIdx, inData, timeRange, rangeType, endTime);
}

void Counter::Convert2Result()
{
    m_countingResult.clear();
    for (auto it = m_hashCounter.begin(); it != m_hashCounter.end(); it++)
    {
        m_countingResult.push_back(ResultData(it->first, it->second));
    }
    std::sort(m_countingResult.begin(), m_countingResult.end(), priceCompare);
}
