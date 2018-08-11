#include "DailyTimer.h"

#include <unistd.h>
DailyTimer::~DailyTimer(){
    m_bTimerThreadStop = true;
    m_bTimerThreadExit = true;
    m_TimerThread.join();
}

void DailyTimer::Start(){
    m_bTimerThreadStop = false;
}

void DailyTimer::Stop(){
    m_bTimerThreadStop = true;
}

bool DailyTimer::IsTimeUP(){
    NLTime curTime; curTime.GetCurrentTime();
    return m_DateTime == curTime;
}

void DailyTimer::Main(){
    while (!m_bTimerThreadExit){
        usleep(300000); // sleep 300 MSec
        if (!m_bTimerThreadStop && IsTimeUP()){
            m_DateTime.AddDate(0, 0, 1);
            m_fn();
        }
    }
}
