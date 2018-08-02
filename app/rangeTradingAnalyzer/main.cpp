#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <memory>

#include "Logger.h"
#include "InputParser.h"
#include "dbBuilder.h"
#include "Counter.h"
#include "SRCounter.h"
#include "ResultPrinter.h"
#include "NLTime.h"

std::string GetOutputFileName(const std::string& inputFile, const NLTime& startTime, const NLTime& endTime, Counter::RangeType rangeType)
{
    std::stringstream ss;
    ss << inputFile << "." << startTime.toString("%Y.%m.%d") << "_" << endTime.toString("%Y.%m.%d") << "." << RangeType2String(rangeType) << ".dis.csv";
    return ss.str();
}

int main(int argc, char* argv[])
{
    Logger::LoggerConfig config = Logger::GetInstance().GetConfig();
    config.logLevel = Logger::LogLevel::DEBUG;
    Logger::GetInstance().InitComponent(config);

    InputParser parser(argc, argv);
    std::string inputFile = parser.getCmdOption("-f");
    std::string counterType = parser.getCmdOption("-t");
    std::string outputFile = parser.getCmdOption("-o");
    if (inputFile == "" || counterType == "" || outputFile == "")
    {
        LOGMSG_ERROR("Usage: %s -f data.csv -o outputFile -t parserType", argv[0]);
        return 0;
    }

    std::vector<int> duration_Month = {1, 2};
    std::vector<int> duration_Day = {7, 12};

    DBBuilder dbBuilder(inputFile);
    std::vector<OHLC>& OHLCs = dbBuilder.GetOHLCs();
    ForexInfo forexInfo = dbBuilder.GetInfo();
    for (size_t i = 0; i < OHLCs.size(); i++)
    {
        // LOGMSG_DEBUG("Time read -----------  %s", OHLCs[i].time.toString("%Y.%m.%d %H.%M.%S").c_str());
    }

    ResultPrinter printer;
    std::vector<std::shared_ptr<Counter> > counters;
    counters.push_back(std::make_shared<SRCounter>());
    for (size_t j = 0; j < counters.size(); j++)
    {
        if (counterType == "SRCounter" || counterType == "PDestriCounter")
        {
            for (size_t i = 0; i < duration_Month.size(); i++)
            {
                int nextIdx = 0;
                int startIdx = 0;
                do
                {
                    nextIdx = counters[j]->DoCounting(startIdx, OHLCs, duration_Month[i], Counter::RangeType::MONTH);
                    LOGMSG_DEBUG("Output File Name: %s", GetOutputFileName(outputFile, OHLCs[startIdx].time, OHLCs[nextIdx - 1].time, Counter::RangeType::MONTH).c_str());
                    printer.Print(GetOutputFileName(outputFile, OHLCs[startIdx].time, OHLCs[nextIdx - 1].time, Counter::RangeType::MONTH), counters[j]->GetResult(), forexInfo);
                    startIdx = nextIdx;
                } while (nextIdx > 0);
            }
        }
        if (counterType == "PDestriCounter")
        {
            for (size_t i = 0; i < duration_Day.size(); i++)
            {
                int nextIdx = 0;
                int startIdx = 0;
                do
                {
                    nextIdx = counters[j]->DoCounting(startIdx, OHLCs, duration_Day[i], Counter::RangeType::DAY);
                    printer.Print(GetOutputFileName(outputFile, OHLCs[startIdx].time, OHLCs[nextIdx - 1].time, Counter::RangeType::DAY), counters[j]->GetResult(), forexInfo);
                    startIdx = nextIdx;
                } while (nextIdx > 0);
            }
        }
    }

    return 0;
}
