#ifndef TOOLS_H
#define TOOLS_H
#include <string>
#include <vector>

namespace utility
{
    bool is_number(const std::string& s);

    std::vector<std::string> splitString(const std::string& s, const char& delim);
};
#endif
