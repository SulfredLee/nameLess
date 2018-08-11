#include "common.h"
#include "Tools.h"
#include "Logger.h"

#include <fstream>
#include <sstream>
static OHLC MakeOHLC(const std::vector<std::string>& inData, int digits);
static int GetDigits(const std::string& inNum);
static int NormalizeDouble(const double& inNum, int digits);
static int shifter[] = {1
                        , 10
                        , 100
                        , 1000
                        , 10000
                        , 100000
                        , 1000000
                        , 10000000
                        , 100000000
                        , 1000000000};

std::vector<OHLC> Common::GetOHLCFrom(const std::string& dataFile)
{
    std::vector<OHLC> result;
    std::ifstream FH(dataFile.c_str());

    std::string line;
    bool isFirstLine = true;
    int digits = 0;
    std::getline(FH, line);
    int count = 0;
    while (std::getline(FH, line))
    {
        count++;
        std::vector<std::string> parts = Utility::splitString(line, '\t');
        if (parts.size() == 9)
        {
            parts[0] += " " + parts[1];
            parts.erase(parts.begin() + 1);
        }

        if (parts.size() == 8)
        {
            if (isFirstLine)
            {
                digits = GetDigits(parts[1]);
                isFirstLine = false;
            }
            result.push_back(MakeOHLC(parts, digits));
        }
    }

    FH.close();
    return result;
}

int GetDigits(const std::string& inNum)
{
    size_t found = inNum.find(".") + 1; // + 1 is converting form index to length
    return inNum.size() - found;
}

int NormalizeDouble(const double& inNum, int digits)
{
    int shifterLen = sizeof(shifter) / sizeof(int);
    if (digits >= shifterLen)
        return static_cast<int>(inNum);
    else
        return static_cast<int>(inNum * shifter[digits]);
}

double Common::DenormalizeDouble(int inNum, int digits)
{
    int shifterLen = sizeof(shifter) / sizeof(int);
    if (digits >= shifterLen)
        return static_cast<double>(inNum);
    else
        return static_cast<double>(inNum) / shifter[digits];
}

OHLC MakeOHLC(const std::vector<std::string>& inData, int digits)
{
    OHLC result;

    if (inData[0].size() == 10)
    {
        result.time.SetFromString(inData[0], "%Y.%m.%d");
        result.time.SetTime(0, 0, 0);
    }
    else
        result.time.SetFromString(inData[0], "%Y.%m.%d %H.%M.%S");
    result.open = NormalizeDouble(std::stod(inData[1]), digits);
    result.high = NormalizeDouble(std::stod(inData[2]), digits);
    result.low = NormalizeDouble(std::stod(inData[3]), digits);
    result.close = NormalizeDouble(std::stod(inData[4]), digits);
    result.tickVolume = std::stoi(inData[5]);
    result.volume = std::stoi(inData[6]);
    result.spread = std::stoi(inData[7]);
    result.digits = digits;

    return result;
}

std::string Common::OHLCToString(const OHLC& inOHLC)
{
    std::stringstream ss;
    ss << "Time: " << inOHLC.time.toString("%Y.%m.%d %H.%M.%S");
    ss << ",open: " << inOHLC.open;
    ss << ",high: " << inOHLC.high;
    ss << ",low: " << inOHLC.low;
    ss << ",close: " << inOHLC.close;
    ss << ",tickVolume: " << inOHLC.tickVolume;
    ss << ",volume: " << inOHLC.volume;
    ss << ",spread: " << inOHLC.spread;
    ss << ",digits: " << inOHLC.digits;
    return ss.str();
}
