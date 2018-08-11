#ifndef DAILYTIMER_H
#define DAILYTIMER_H

#include <thread>
#include <memory>
#include <functional>
#include <atomic>

#include <string>
#include <sstream>

#include "NLTime.h"

class DailyTimer{
public:
    template <class Fn, class... Args>
        DailyTimer(const NLTime& DateTimeIN, Fn&& fn, Args&&... args);
    ~DailyTimer();

    void Start();
    void Stop();
private:
    bool IsTimeUP();
    void Main();
private:
    std::thread m_TimerThread;
    std::atomic<bool> m_bTimerThreadExit;
    std::atomic<bool> m_bTimerThreadStop;
    std::function<void()> m_fn;
    NLTime m_DateTime;
};

template <class Fn, class... Args>
    DailyTimer::DailyTimer(const NLTime& DateTimeIN, Fn&& fn, Args&&... args)
    : m_DateTime(DateTimeIN)
    , m_fn(std::bind(std::forward<Fn>(fn), std::forward<Args>(args)...)){
        m_bTimerThreadStop = false;
        m_bTimerThreadExit = false;
        m_TimerThread = std::thread(&DailyTimer::Main, this);
}
#endif
