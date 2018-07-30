#ifndef SRCOUNTER_H
#define SRCOUNTER_H
#include <string>
#include <vector>
#include <utility>

class SRCounter
{
 private:
    std::string m_dataFile;
    std::string m_resultFile;
    std::vector<std::pair<int, int> > m_countingElement; // price, occurance
    int m_shift;
 public:
    SRCounter();
    ~SRCounter();

    void InitComponent(const std::string& dataFile, const std::string& resultFile);
    void DoCounting();
    void PrintResult();
 private:
    std::vector<int> GetDataFromFile();
    void PrintDistributionFile();
    void PrintOccuranceFile();
    int findShift(int digit);
};

#endif
