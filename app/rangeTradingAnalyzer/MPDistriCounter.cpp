#include "MPDistriCounter.h"
#include "Logger.h"

#include <iomanip>
#include <fstream>
SlidingDB::SlidingDB()
{}

SlidingDB::~SlidingDB()
{}

bool SlidingDB::isDBReady()
{
    return (m_timeRange == m_hashCounterVector.size());
}

int SlidingDB::initDB(size_t startIdx, const std::vector<OHLC>& inData, int timeRange) // return nextIdx
{
    m_timeRange = static_cast<size_t>(timeRange);
    m_hashCounter.clear();
    m_countingResultSlidingDB.clear();
    m_countingResultToday.clear();
    m_hashCounterVector.clear();
    m_hashCounterVector.resize(timeRange);
    int nextIdx = -1;
    nextIdx = startIdx;
    for (size_t i = 0; i < m_timeRange; i++)
    {
        nextIdx = countADay(nextIdx, inData, m_hashCounterVector[i]);
        UpdateSildingDBDistribution(m_hashCounterVector[i], m_countingResultSlidingDB, TOOL::ADD);
    }
    return nextIdx;
}

int SlidingDB::countADay(int startIdx, const std::vector<OHLC>& inData, std::unordered_map<int, int>& targetDB) // return nextIdx
{
    if (startIdx < 0 || startIdx >= static_cast<int>(inData.size()))
        return -1;
    NLTime startTime = inData[startIdx].time;
    NLTime endTime = startTime;
    endTime.SetTime(0, 0, 0);
    endTime.AddDate(0, 0, 1);
    int i = startIdx;
    for (; i < static_cast<int>(inData.size()); i++)
    {
        if (inData[i].time >= endTime)
            return i;
        CountAPrice(inData[i].low, inData[i].high, targetDB);
    }
    return -1;
}

int SlidingDB::countToday(int startIdx, const std::vector<OHLC>& inData)
{
    if (m_hashCounter.size() == 0)
    {
        int nextIdx = countADay(startIdx, inData, m_hashCounter);
        UpdateSildingDBDistribution(m_hashCounter, m_countingResultToday, TOOL::CLR);
        return nextIdx;
    }
    else
    {
        // remove oldest counting data from sliding database
        UpdateSildingDBDistribution(m_hashCounterVector[0], m_countingResultSlidingDB, TOOL::SUB);
        m_hashCounterVector.erase(m_hashCounterVector.begin());
        m_hashCounterVector.push_back(m_hashCounter);

        // count today
        m_hashCounter.clear();
        int nextIdx = countADay(startIdx, inData, m_hashCounter);
        UpdateSildingDBDistribution(m_hashCounter, m_countingResultToday, TOOL::CLR);
        return nextIdx;
    }
}

void SlidingDB::CountAPrice(int lowPrice, int highPrice, std::unordered_map<int, int>& targetDB)
{
    for (int i = lowPrice; i <= highPrice; i++)
    {
        auto it = targetDB.find(i);
        if (it == targetDB.end())
        {
            targetDB.insert(std::make_pair(i, 1));
        }
        else
        {
            it->second++;
        }
    }
}

void SlidingDB::UpdateSildingDBDistribution(const std::unordered_map<int, int>& inCounterDB, std::map<int, int>& outDistribution, TOOL opt)
{
    if (opt == TOOL::CLR)
    {
        outDistribution.clear();
        opt = TOOL::ADD;
    }

    if (opt == TOOL::ADD)
    {
        for (auto it = inCounterDB.begin(); it != inCounterDB.end(); it++)
        {
            auto it2 = outDistribution.find(it->first);
            if (it2 == outDistribution.end())
            {
                outDistribution.insert(std::make_pair(it->first, it->second));
            }
            else
            {
                it2->second += it->second;
            }
        }
    }
    else if (opt == TOOL::SUB)
    {
        for (auto it = inCounterDB.begin(); it != inCounterDB.end(); it++)
        {
            auto it2 = outDistribution.find(it->first);
            if (it2 != outDistribution.end())
            {
                it2->second -= it->second;
            }
        }
    }
}

double SlidingDB::DistributionDiff()
{
    return 0;
}

MPDistriCounter::MPDistriCounter()
{
    m_countingFinished = false;
    m_distributionDiff.clear();
}

MPDistriCounter::~MPDistriCounter()
{}

void MPDistriCounter::PrintResult(const std::string& outputFile, const ForexInfo& forexInfo)
{
    if (m_countingFinished)
    {
        std::ofstream FH(outputFile.c_str());
        for (size_t i = 0; i < m_distributionDiff.size(); i++)
        {
            FH << i << "," << std::fixed << std::setprecision(8) << m_distributionDiff[i] << std::endl;
        }
        FH.close();
        m_distributionDiff.clear();
    }
}

std::string MPDistriCounter::GetOutputFileName(const std::string& inputFile, const NLTime& startTime, const NLTime& endTime, Counter::RangeType rangeType)
{
    std::stringstream ss;
    ss << inputFile << "." << m_startTime.toString("%Y.%m.%d") << "_" << m_endTime.toString("%Y.%m.%d") << "." << RangeType2String(rangeType) << ".dis.csv";
    return ss.str();
}

int MPDistriCounter::DoCountingPost(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType, NLTime endTime)
{
    int nextIdx = -1;
    m_countingFinished = false;
    if (startIdx != 0)
    {
        LOGMSG_DEBUG("startTime-----: %s", inData[startIdx].time.toString("%Y.%m.%d %H.%M.%S").c_str());
        nextIdx = m_slidingDB.countToday(startIdx, inData);
        m_distributionDiff.push_back(m_slidingDB.DistributionDiff());
    }
    else
    {
        LOGMSG_DEBUG("startTime-----: %s", inData[startIdx].time.toString("%Y.%m.%d %H.%M.%S").c_str());
        m_startTime = inData[startIdx].time;
        nextIdx = m_slidingDB.initDB(startIdx, inData, timeRange);
        LOGMSG_DEBUG("endTime-----: %s", inData[nextIdx -1].time.toString("%Y.%m.%d %H.%M.%S").c_str());
        nextIdx = m_slidingDB.countToday(nextIdx, inData);
        LOGMSG_DEBUG("endTime-----: %s", inData[nextIdx -1].time.toString("%Y.%m.%d %H.%M.%S").c_str());
        m_distributionDiff.push_back(m_slidingDB.DistributionDiff());
    }

    if (nextIdx == -1)
    {
        m_countingFinished = true;
        m_endTime = inData.back().time;
    }
    else
    {
        LOGMSG_DEBUG("endTime-----: %s", inData[nextIdx -1].time.toString("%Y.%m.%d %H.%M.%S").c_str());
    }
    return nextIdx;
}
