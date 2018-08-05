#ifndef MPDISTRICOUNTER_H
#define MPDISTRICOUNTER_H
#include "dataStruct.h"
#include "Counter.h"

#include <map>
class SlidingDB
{
 public:
    enum class TOOL {ADD, SUB, CLR};
 private:
    std::vector<std::unordered_map<int, int> > m_hashCounterVector; // key: price, value: occurrence, this is the sliding database
    std::unordered_map<int, int> m_hashCounter; // this stored current day counting
    std::map<int, int> m_countingResultSlidingDB; // key: price, value: occurrence
    std::map<int, int> m_countingResultToday; // key: price, value: occurrence
    size_t m_timeRange;
 public:
    SlidingDB();
    ~SlidingDB();

    bool isDBReady();
    int initDB(size_t startIdx, const std::vector<OHLC>& inData, int timeRange); // return nextIdx
    int countToday(int startIdx, const std::vector<OHLC>& inData);
    double DistributionDiff();
    const std::map<int, int>& getResultSlidingDB();
    const std::map<int, int>& getResultToday();
 private:
    int countADay(int startIdx, const std::vector<OHLC>& inData, std::unordered_map<int, int>& targetDB); // return nextIdx
    void CountAPrice(int lowPrice, int highPrice, std::unordered_map<int, int>& targetDB);
    void UpdateSildingDBDistribution(const std::unordered_map<int, int>& inCounterDB, std::map<int, int>& outDistribution, TOOL opt);
};

class MPDistriCounter : public Counter
{
 private:
    SlidingDB m_slidingDB;
    bool m_countingFinished;
    std::vector<double> m_distributionDiff;
    NLTime m_startTime;
    NLTime m_endTime;
 public:
    MPDistriCounter();
    ~MPDistriCounter();

    void PrintResult(const std::string& outputFile, const ForexInfo& forexInfo);
    std::string GetOutputFileName(const std::string& inputFile, const NLTime& startTime, const NLTime& endTime, Counter::RangeType rangeType);
 private:
    int DoCountingPost(size_t startIdx, const std::vector<OHLC>& inData, int timeRange, RangeType rangeType, NLTime endTime);
};
#endif
