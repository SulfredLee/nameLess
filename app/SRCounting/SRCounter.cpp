#include "SRCounter.h"
#include "Logger.h"
#include "Tools.h"

#include <fstream>
#include <vector>
#include <algorithm>

bool priceCompare(const std::pair<int, int>& firstElem, const std::pair<int, int>& secondElem)
{
    return firstElem.first < secondElem.first;
}

bool occuranceCompare(const std::pair<int, int>& firstElem, const std::pair<int, int>& secondElem)
{
    return firstElem.second > secondElem.second;
}

SRCounter::SRCounter()
{
}

SRCounter::~SRCounter()
{
}

void SRCounter::InitComponent(const std::string& dataFile, const std::string& resultFile)
{
    m_dataFile = dataFile;
    m_resultFile = resultFile;
}

void SRCounter::DoCounting()
{
    std::vector<int> openCloseArray = GetDataFromFile();
    if (openCloseArray.size() == 0)
    {
        return;
    }
    // do counting
    int prePrice = openCloseArray[0];
    int count = 1;
    for (size_t i = 1; i < openCloseArray.size(); i++)
    {
        if (openCloseArray[i] != prePrice)
        {
            m_countingElement.push_back(std::make_pair(prePrice, count));
            prePrice = openCloseArray[i];
            count = 0;
        }
        count++;
    }
    if (count > 0)
    {
        m_countingElement.push_back(std::make_pair(prePrice, count));
    }
}

void SRCounter::PrintResult()
{
    PrintDistributionFile();
    PrintOccuranceFile();
}

std::vector<int> SRCounter::GetDataFromFile()
{
    std::ifstream FH(m_dataFile.c_str());
    if (!FH.is_open())
    {
        LOGMSG_ERROR("Cannot open file %s", m_dataFile.c_str());
        return std::vector<int>();
    }
    std::string line;
    bool isFirstLine = true;
    std::vector<int> openCloseArray;
    m_shift = 0;
    int curIndex = 0;
    while (std::getline(FH, line))
    {
        std::vector<std::string> parts = Utility::splitString(line, '\t');
        if (isFirstLine) // skip the first row
        {
            if (parts.size() == 5) // symbol, created file time, total OHLC, pre-calculated, digits
            {
                int numOHLC = std::stoi(parts[2]);
                openCloseArray.clear();
                m_dataFile.clear();
                openCloseArray.resize(numOHLC * 2);
                m_dataFile.resize(numOHLC);

                m_shift = findShift(std::stoi(parts[4]));
            }
            isFirstLine = false;
        }
        else
        {
            if (parts.size() == 8) // time, open, high, low, close, tick_volume, volume, spread
            {
                openCloseArray[curIndex++] = static_cast<int>(std::stod(parts[2]) * m_shift); // get high
                openCloseArray[curIndex++] = static_cast<int>(std::stod(parts[3]) * m_shift); // get low
            }
        }
    }
    FH.close();
    std::sort(openCloseArray.begin(), openCloseArray.end());
    return openCloseArray;
}

void SRCounter::PrintDistributionFile()
{
    std::sort(m_countingElement.begin(), m_countingElement.end(), priceCompare);
    std::string resultDistributionFile = m_resultFile + ".dis.txt";
    std::ofstream FH(resultDistributionFile.c_str());
    for (size_t i = 0; i < m_countingElement.size(); i++)
    {
        FH << m_countingElement[i].first / static_cast<double>(m_shift) << "," << m_countingElement[i].second << std::endl;
    }
    FH.close();
}

void SRCounter::PrintOccuranceFile()
{
    std::sort(m_countingElement.begin(), m_countingElement.end(), occuranceCompare);
    std::string resultOccuranceFile = m_resultFile + ".occ.txt";
    std::ofstream FH(resultOccuranceFile.c_str());
    for (size_t i = 0; i < m_countingElement.size(); i++)
    {
        FH << m_countingElement[i].first / static_cast<double>(m_shift) << "," << m_countingElement[i].second << std::endl;
    }
    FH.close();
}

int SRCounter::findShift(int digit)
{
    if (digit < 0)
        return 1;
    return pow(10, digit);
}
