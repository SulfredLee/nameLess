#ifndef STEPCOUNTER_H
#define STEPCOUNTER_H
#include <string>
#include <vector>
#include <utility>
#include <unordered_map>

#include <time.h>
class StepCounter
{
 private:
    std::string m_dataFile;
    std::string m_resultFile;
    std::vector<std::pair<int, int> > m_countingElement; // price, occurance
    std::unordered_map<int, int> m_firstCountingElement; // key: price, value: occurance
    int m_shift; // m_shift = pow(10, digit);
    int m_duration;
    struct tm m_startMonth;
    struct tm m_endMonth;
 public:
    StepCounter();
    ~StepCounter();

    void InitComponent(const std::string& dataFile, const std::string& resultFile, const std::string& month);
    void DoCounting();
 private:
    void PrintResult();
    void CountOneLowHighPair(const int low, const int high);
    int findShift(int digit);
    void updateDurationAndPrintResult(const std::string& timeFromFile);
    struct tm getMonth(const std::string& timeFromFile);
    int getMonth(struct tm& timeFromStruct);
    void addMonth(struct tm& toTime, const struct tm& fromTime, int month);
};

#endif
