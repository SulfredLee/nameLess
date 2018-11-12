#ifndef TOOLS_H
#define TOOLS_H
#include <string>
#include <vector>

namespace Utility
{
    bool is_number(const std::string& s);
    std::vector<std::string> splitString(const std::string& s, const char delim);
    bool is_big_endian();
    int ReadFileToArray(const std::string& fileName, std::vector<unsigned char>& data);
};
#endif
