#include "pdfBuilder.h"
#include "common.h"
#include "Logger.h"

#include <map>
#include <fstream>
pdfBuilder::pdfBuilder(){}

pdfBuilder::~pdfBuilder(){}

void pdfBuilder::InitComponent(const std::string& dataFile, const std::string& resultFile)
{
    m_dataFile = dataFile;
    m_resultFile = resultFile;
    m_tradeData = Common::GetOHLCFrom(m_dataFile);
}

void pdfBuilder::Main()
{
    // do counting
    std::map<int, int> countingMap; // key: price, value: frequency
    for (size_t i = 0; i < m_tradeData.size(); i++)
    {
        CountARange(m_tradeData[i].low, m_tradeData[i].high, countingMap);
    }
    LOGMSG_INFO("m_tradeData.size(): %lu", m_tradeData.size());

    // convert to result structure
    for (auto it = countingMap.begin(); it != countingMap.end(); it++)
    {
        m_pdf.push_back(pdfData(it->first, it->second));
    }
}

void pdfBuilder::PrintResult()
{
    std::ofstream FH(m_resultFile.c_str());

    for (size_t i = 0; i < m_pdf.size(); i++)
    {
        FH << Common::DenormalizeDouble(m_pdf[i].price, m_tradeData.front().digits) << "," << m_pdf[i].frequency << std::endl;
    }

    FH.close();
}

void pdfBuilder::CountARange(int low, int high, std::map<int, int>& countingMap)
{
    for (int i = low; i <= high; i++)
    {
        CountAPrice(i, countingMap);
    }
}

void pdfBuilder::CountAPrice(int price, std::map<int, int>& countingMap)
{
    auto it = countingMap.find(price);
    if (it == countingMap.end())
        countingMap.insert(std::make_pair(price, 1));
    else
        it->second++;
}
