#ifndef TRADER_H
#define TRADER_H
#include "tool/LinuxThread.h"

class Trader : public LinuxThread
{
 public:
    Trader();
    ~Trader();

    bool InitComponent();
 private:
    // override
    void* Main();
};

#endif
