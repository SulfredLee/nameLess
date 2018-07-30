#include "StepCounter.h"
#include "Logger.h"
#include "Tools.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <algorithm>
#include <unordered_map>

#include <string.h>
#include <time.h>

bool priceCompare(const std::pair<int, int>& firstElem, const std::pair<int, int>& secondElem)
{
    return firstElem.first < secondElem.first;
}

bool occuranceCompare(const std::pair<int, int>& firstElem, const std::pair<int, int>& secondElem)
{
    return firstElem.second > secondElem.second;
}

StepCounter::StepCounter()
{
    m_countingElement.clear();
}

StepCounter::~StepCounter()
{}

void StepCounter::InitComponent(const std::string& dataFile, const std::string& resultFile, const std::string& month)
{
    m_dataFile = dataFile;
    m_resultFile = resultFile;
    m_duration = std::stoi(month);
    m_shift = 0;
}

void StepCounter::DoCounting()
{
    std::ifstream FH(m_dataFile.c_str());
    if (!FH.is_open())
    {
        LOGMSG_ERROR("Cannot open file %s", m_dataFile.c_str());
        return;
    }
    std::string line;
    bool isFirstLine = true;
    while (std::getline(FH, line))
    {
        std::vector<std::string> parts = Utility::splitString(line, '\t');
        if (isFirstLine) // skip the first row
        {
            if (parts.size() == 5) // symbol, created file time, total OHLC, pre-calculated, digits
            {
                int numOHLC = std::stoi(parts[2]);
                m_dataFile.clear();
                m_dataFile.resize(numOHLC);

                m_shift = findShift(std::stoi(parts[4]));
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
                updateDurationAndPrintResult(parts[0]); // update month range, output result
                CountOneLowHighPair(static_cast<int>(std::stod(parts[3]) * m_shift), static_cast<int>(std::stod(parts[2]) * m_shift));
            }
        }
    }
    FH.close();
}

void StepCounter::PrintResult()
{
    // get counting result to member variable
    for (auto it = m_firstCountingElement.begin(); it != m_firstCountingElement.end(); it++)
    {
        m_countingElement.push_back(std::make_pair(it->first, it->second));
    }
    if (m_countingElement.size() == 0)
    {
        return;
    }
    // sorting price in asceding order
    std::sort(m_countingElement.begin(), m_countingElement.end(), priceCompare);
    std::stringstream resultDistributionFile;
    resultDistributionFile << m_resultFile << "_" << getMonth(m_startMonth) << "_" << getMonth(m_endMonth) << ".dis.txt";
    std::ofstream FH(resultDistributionFile.str().c_str());
    for (size_t i = 0; i < m_countingElement.size(); i++)
    {
        FH << m_countingElement[i].first / static_cast<double>(m_shift) << "," << m_countingElement[i].second << std::endl;
    }
    FH.close();
}

void StepCounter::CountOneLowHighPair(const int low, const int high)
{
    for (int i = low; i <= high; i++)
    {
        auto it = m_firstCountingElement.find(i);
        if (it == m_firstCountingElement.end())
        {
            m_firstCountingElement.insert(std::make_pair(i, 1)); // get first occurance
        }
        else
        {
            it->second++;
        }
    }
}

int StepCounter::findShift(int digit)
{
    if (digit < 0)
        return 1;
    return pow(10, digit);
}

void StepCounter::updateDurationAndPrintResult(const std::string& timeFromFile)
{
    struct tm month = getMonth(timeFromFile);
    if (getMonth(m_startMonth) <= getMonth(month) && getMonth(month) < getMonth(m_endMonth))
    {
        // ready to do counting
    }
    else
    {
        // output result
        PrintResult();
        // clear first counting element
        m_firstCountingElement.clear();
        // update duration
        m_startMonth = month;
        addMonth(m_endMonth, m_startMonth, m_duration);
    }
}

struct tm StepCounter::getMonth(const std::string& timeFromFile) // 2018.05.07 04:00:00
{
    // todo
    int year = std::stoi(timeFromFile.substr(0, 4));
    int month = std::stoi(timeFromFile.substr(5, 2));
    tm result;
    mktime(&result);
    result.tm_year = year;
    result.tm_mon = month;
    mktime(&result);
    return result;
}

int StepCounter::getMonth(struct tm& timeFromStruct)
{
    int year, month;
    year = timeFromStruct.tm_year * 100;
    month = timeFromStruct.tm_mon;
    return year + month;
}

void StepCounter::addMonth(struct tm& toTime, const struct tm& fromTime, int month)
{
    toTime = fromTime;
    toTime.tm_mon = fromTime.tm_mon + month;
    mktime(&toTime);
}
