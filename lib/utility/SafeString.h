#ifndef SAFE_STRING_H
#define SAFE_STRING_H
#include <string>
#include "DefaultMutex.h"

class SafeString
{
 public:
    SafeString();
    ~SafeString();

    void Assigment(const std::string& inData);
    void Append(const std::string& inData);
    size_t GetSize();
    void Clear();
    std::string GetString();
 private:
    DefaultMutex m_mutex;
    std::string m_data;
};

#endif
