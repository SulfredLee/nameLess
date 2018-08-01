#include <iostream>
#include <string>
#include <vector>

#include "Logger.h"
#include "InputParser.h"
#include "dbBuilder.h"

int main(int argc, char* argv[])
{
    Logger::LoggerConfig config = Logger::GetInstance().GetConfig();
    config.logLevel = Logger::LogLevel::DEBUG;
    Logger::GetInstance().InitComponent(config);

    InputParser parser(argc, argv);
    std::string inputFile = parser.getCmdOption("-f");
    if (inputFile == "")
    {
        LOGMSG_ERROR("Usage: %s -f data.csv", argv[0]);
        return 0;
    }

    std::vector<int> duration_Month = {1, 2};
    std::vector<int> duration_Day = {7, 12};

    DBBuilder dbBuilder(inputFile);
    std::vector<OHLC>& OHLCs = dbBuilder.GetOHLCs();
    for (size_t i = 0; i < OHLCs.size(); i++)
    {
        LOGMSG_DEBUG("Time read -----------  %s", OHLCs[i].time.toString("%Y.%m.%d %H.%M.%S").c_str());
    }

    return 0;
}
