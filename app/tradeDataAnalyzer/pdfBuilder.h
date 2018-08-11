#ifndef PDFBUILDER_H
#define PDFBUILDER_H
#include <vector>
#include <map>

#include "dataStruct.h"
#include "app.h"
struct pdfData
{
public:
    pdfData(double inPrice, int inFrequency)
    {
        price = inPrice;
        frequency = inFrequency;
    }

    double price;
    int frequency;
};

class pdfBuilder : public app
{
 private:
    std::string m_dataFile;
    ForexInfo m_forexInfo;
    std::vector<OHLC> m_tradeData;

    std::string m_resultFile;

    std::vector<pdfData> m_pdf;
 public:
    pdfBuilder();
    ~pdfBuilder();

    void InitComponent(const std::string& dataFile, const std::string& resultFile);
    void Main();
    void PrintResult();
 private:
    void CountARange(int low, int high, std::map<int, int>& countingMap);
    void CountAPrice(int price, std::map<int, int>& countingMap);
};
#endif
