#include "MSecTimer.h"

#include <unistd.h>
MSecTimer::~MSecTimer(){
    m_bTimerThreadStop = true;
    m_bTimerThreadExit = true;
    m_TimerThread.join();
}

void MSecTimer::Start(){
    m_bTimerThreadStop = false;
}

void MSecTimer::Stop(){
    m_bTimerThreadStop = true;
}

void MSecTimer::Main(){
    int sleepDurationMSec = m_unDuration * 1000;
	clock_t begin_time = clock();
    while (!m_bTimerThreadExit)
    {
        usleep(sleepDurationMSec);
        if (!m_bTimerThreadStop)
        {
            m_fn();
        }
    }
}
