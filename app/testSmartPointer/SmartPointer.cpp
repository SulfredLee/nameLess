#include "SmartPointer.h"
#include <iostream>

ReferenceCount::ReferenceCount()
{
    m_count = 0;
}

ReferenceCount::~ReferenceCount()
{
}

void ReferenceCount::AddRef()
{
    DefaultLock lock(&m_mutex);
    m_count++;
    // std::cout << __FUNCTION__ << " m_count: " << m_count << std::endl;
}

int ReferenceCount::Release()
{
    DefaultLock lock(&m_mutex);
    // std::cout << __FUNCTION__ << " m_count: " << m_count << std::endl;
    if (m_count > 0)
    {
        return --m_count;
    }
    else
    {
        m_count = 0;
        return m_count;
    }
}
