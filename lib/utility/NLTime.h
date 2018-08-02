#ifndef NLTIME_H
#define NLTIME_H
#include <string>

#include <time.h>
class NLTime
{
 private:
    mutable struct tm m_time;
 public:
    NLTime();
    NLTime(int Y, int Mon, int D, int H, int Min, int S);
    NLTime(int&& Y, int&& Mon, int&& D, int&& H, int&& Min, int&& S);
    NLTime(const std::string& source, const std::string& format);
    ~NLTime();

    struct tm GetRawData();
    struct tm const * const GetRawDataPointer();
    time_t GetTimeT();
    time_t GetTimeT() const;
    void GetCurrentTime();
    void GetDate(int& Y, int& Mon, int& D);
    void GetTime(int& H, int& Min, int& S);
    void GetDate(int& Y, int& Mon, int& D) const;
    void GetTime(int& H, int& Min, int& S) const;

    void SetFromString(const std::string& source, const std::string& format);

    void SetDate(int Y, int Mon, int D);
    void SetTime(int H, int Min, int S);

    void AddDate(int Y, int Mon, int D);
    void AddTime(int H, int Min, int S);

    std::string toString(const std::string& format);
    std::string toString(const std::string& format) const;

    // there has no meaning for += operator, implement for demo only
    NLTime& operator+= (const NLTime& that);
};
bool operator== (const NLTime& lhs, const NLTime& rhs);
bool operator!= (const NLTime& lhs, const NLTime& rhs);
bool operator< (const NLTime& lhs, const NLTime& rhs);
bool operator> (const NLTime& lhs, const NLTime& rhs);
bool operator>= (const NLTime& lhs, const NLTime& rhs);
bool operator<= (const NLTime& lhs, const NLTime& rhs);

// there has no meaning for += operator, implement for demo only
NLTime operator+ (const NLTime& lhs, const NLTime& rhs);
NLTime&& operator+ (const NLTime& lhs, NLTime&& rhs);
NLTime&& operator+ (NLTime&& lhs, const NLTime& rhs);
NLTime&& operator+ (NLTime&& lhs, NLTime&& rhs);
#endif
