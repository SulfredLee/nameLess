#ifndef LINUX_THREAD_H
#define LINUX_THREAD_H
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

class linuxThread
{
 public:
    linuxThread();
    virtual ~linuxThread();
 protected:
    virtual void* Main() = 0;

    bool startThread();
    void stopThread();
    bool isThreadRunning();
 private:
    static void* MainProxy(void* context);

 protected:
    pthread_t m_thread;
 private:
    bool m_run;
};

#endif