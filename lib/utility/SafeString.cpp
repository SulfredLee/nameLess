#include "SafeString.h"

SafeString::SafeString()
{
}

SafeString::~SafeString()
{
}

void SafeString::Assigment(const std::string& inData)
{
    DefaultLock lock(&m_mutex);
    m_data = inData;
}

void SafeString::Append(const std::string& inData)
{
    DefaultLock lock(&m_mutex);
    m_data += inData;
}

size_t SafeString::GetSize()
{
    DefaultLock lock(&m_mutex);
    return m_data.length();
}

void SafeString::Clear()
{
    DefaultLock lock(&m_mutex);
    m_data = "";
}

std::string SafeString::GetString()
{
    DefaultLock lock(&m_mutex);
    return m_data;
}
