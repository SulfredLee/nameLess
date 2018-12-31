#ifndef TOOLS_H
#define TOOLS_H
#include <string>
#include <vector>
#include <sys/stat.h> // stat
#include <errno.h>    // errno, ENOENT, EEXIST

#if defined(_WIN32)
#include <direct.h>   // _mkdir
#endif

namespace Utility
{
    bool is_number(const std::string& s);
    std::vector<std::string> splitString(const std::string& s, const char delim);
    bool is_big_endian();
    int ReadFileToArray(const std::string& fileName, std::vector<unsigned char>& data);
    bool ReplaceSubstring(std::string& str, const std::string& from, const std::string& to);
    void ReplaceAllSubstring(std::string& str, const std::string& from, const std::string& to);
    std::string GetFolderPath(const std::string& fullPath);
    std::string GetFileName(const std::string& fillPath);
    bool isDirExist(const std::string& path);
    bool makePath(const std::string& path);
};
#endif
