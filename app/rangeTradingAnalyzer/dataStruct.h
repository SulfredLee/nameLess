#ifndef DATASTRUCT_H
#define DATASTRUCT_H
#include <string>

#include "NLTime.h"
struct ForexInfo
{
    std::string symbol;
    int totalOHLC;
    int digit;
};

struct OHLC
{
    NLTime time;
    int open;
    int high;
    int low;
    int close;
    int tickVolume;
    int volume;
    int spread;
};
#endif
