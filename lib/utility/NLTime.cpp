#include "NLTime.h"

#include <utility>

NLTime::NLTime()
{
    mktime(&m_time);
}

NLTime::NLTime(int Y, int Mon, int D, int H, int Min, int S)
    : NLTime()
{
    m_time.tm_year = Y;
    m_time.tm_mon = Mon;
    m_time.tm_mday = D;
    m_time.tm_hour = H;
    m_time.tm_min = Min;
    m_time.tm_sec = S;
    mktime(&m_time);
}

NLTime::NLTime(int&& Y, int&& Mon, int&& D, int&& H, int&& Min, int&& S)
    : NLTime()
{
    m_time.tm_year = std::move(Y);
    m_time.tm_mon = std::move(Mon);
    m_time.tm_mday = std::move(D);
    m_time.tm_hour = std::move(H);
    m_time.tm_min = std::move(Min);
    m_time.tm_sec = std::move(S);
    mktime(&m_time);
}

NLTime::NLTime(const std::string& source, const std::string& format)
    : NLTime()
{
    SetFromString(source, format);
}

NLTime::~NLTime()
{}

tm NLTime::GetRawData()
{
    return m_time;
}

tm const * const NLTime::GetRawDataPointer()
{
    return &m_time;
}

time_t NLTime::GetTimeT()
{
    return mktime(&m_time);
}

time_t NLTime::GetTimeT() const
{
    return mktime(&m_time);
}

void NLTime::GetCurrentTime()
{
    time_t rawTime;
    time(&rawTime);
    m_time = *localtime(&rawTime);
}

void NLTime::GetDate(int& Y, int& Mon, int& D)
{
    Y = m_time.tm_year;
    Mon = m_time.tm_mon;
    D = m_time.tm_mday;
}

void NLTime::GetTime(int& H, int& Min, int& S)
{
    H = m_time.tm_hour;
    Min = m_time.tm_min;
    S = m_time.tm_sec;
}

void NLTime::SetFromString(const std::string& source, const std::string& format)
{
    strptime(source.c_str(), format.c_str(), &m_time);
    mktime(&m_time);
}

void NLTime::SetDate(int Y, int Mon, int D)
{
    m_time.tm_year = Y;
    m_time.tm_mon = Mon;
    m_time.tm_mday = D;
    mktime(&m_time);
}

void NLTime::SetDate(int&& Y, int&& Mon, int&& D)
{
    m_time.tm_year = std::move(Y);
    m_time.tm_mon = std::move(Mon);
    m_time.tm_mday = std::move(D);
    mktime(&m_time);
}

void NLTime::SetTime(int H, int Min, int S)
{
    m_time.tm_hour = H;
    m_time.tm_min = Min;
    m_time.tm_sec = S;
    mktime(&m_time);
}

void NLTime::SetTime(int&& H, int&& Min, int&& S)
{
    m_time.tm_hour = std::move(H);
    m_time.tm_min = std::move(Min);
    m_time.tm_sec = std::move(S);
    mktime(&m_time);
}

void NLTime::AddDate(int Y, int Mon, int D)
{
    m_time.tm_year += Y;
    m_time.tm_mon += Mon;
    m_time.tm_mday += D;
    mktime(&m_time);
}

void NLTime::AddTime(int H, int Min, int S)
{
    m_time.tm_hour += H;
    m_time.tm_min += Min;
    m_time.tm_sec += S;
    mktime(&m_time);
}

std::string NLTime::toString(const std::string& format)
{
    char buff[1024];
    strftime(buff, sizeof(buff), format.c_str(), &m_time);
    return std::string(buff);
}

NLTime& NLTime::operator+= (const NLTime& that)
{
    m_time.tm_year += that.m_time.tm_year;
    m_time.tm_mon += that.m_time.tm_mon;
    m_time.tm_mday += that.m_time.tm_mday;
    m_time.tm_hour += that.m_time.tm_hour;
    m_time.tm_min += that.m_time.tm_min;
    m_time.tm_sec += that.m_time.tm_sec;
    mktime(&m_time);
    return *this;
}

bool operator== (const NLTime& lhs, const NLTime& rhs)
{
    return difftime(lhs.GetTimeT(), rhs.GetTimeT()) == 0 ? true : false;
}

bool operator!= (const NLTime& lhs, const NLTime& rhs)
{
    return !(lhs == rhs);
}

bool operator< (const NLTime& lhs, const NLTime& rhs)
{
    return difftime(lhs.GetTimeT(), rhs.GetTimeT()) < 0 ? true : false;
}

bool operator> (const NLTime& lhs, const NLTime& rhs)
{
    return rhs < lhs;
}

bool operator>= (const NLTime& lhs, const NLTime& rhs)
{
    return !(lhs < rhs);
}

bool operator<= (const NLTime& lhs, const NLTime& rhs)
{
    return !(rhs < lhs);
}

NLTime operator+ (const NLTime& lhs, const NLTime& rhs)
{
    NLTime temp = lhs;
    return temp += rhs;
}

NLTime&& operator+ (const NLTime& lhs, NLTime&& rhs)
{
    return std::move(rhs += lhs);
}

NLTime&& operator+ (NLTime&& lhs, const NLTime& rhs)
{
    return std::move(lhs += rhs);
}

NLTime&& operator+ (NLTime&& lhs, NLTime&& rhs)
{
    return std::move(lhs += rhs);
}
