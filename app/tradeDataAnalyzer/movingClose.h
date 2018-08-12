#ifndef MOVINGCLOSE_H
#define MOVINGCLOSE_H
#include <vector>
#include <map>

#include "dataStruct.h"
#include "app.h"
class MovingClose : public app
{
 private:
    std::string m_dataFile;
    std::string m_movingAverageFile;
    std::string m_slopePDFFile;
    std::string m_diffPDFFile;
    std::vector<OHLC> m_tradeData;
    std::vector<double> m_mvAvg;
    std::map<double, int> m_slopePDF; // key: slope, value: count
    std::map<int, int> m_diffPDF; // key: diff, value: count

    size_t m_correctCount;
    size_t m_wrongCount;
    size_t m_totalCount;

    size_t m_period; // unit is minute
 public:
    MovingClose();
    ~MovingClose();

    void InitComponent(const std::string& dataFile, const std::string& resultFile);
    void Main();
    void PrintResult();
 private:
    int periodDirection(size_t periodStart, size_t periodEnd);
    int currentDirection(size_t Idx);
    bool isBigChange(size_t periodStart, size_t periodEnd);
    void MakeMovingAverage();
    double MakeOneMV(size_t periodStart, size_t periodEnd);
    void MakeMVSlopePDF();
    void MakeMVDiffPDF();
    void PrintMVSlopePDF();
    void PrintMovingAverage();
    void PrintdiffPDF();
};
#endif
