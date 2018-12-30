#include "Tools.h"

#include <sstream>
#include <algorithm>

#include <stdio.h>

bool Utility::is_number(const std::string& s)
{
    return !s.empty() && std::find_if(s.begin(), s.end(), [](char c){return !std::isdigit(c);}) == s.end();
}

std::vector<std::string> Utility::splitString(const std::string& s, const char delim)
{
    std::vector<std::string> elems;
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, delim))
    {
        elems.push_back(item);
    }
    return elems;
}

bool Utility::is_big_endian()
{
    union
    {
        uint32_t i;
        char c[4];
    } bint = {0x01020304};

    return bint.c[0] == 1;
}

int Utility::ReadFileToArray(const std::string& fileName, std::vector<unsigned char>& data)
{
    // Reading size of file
    FILE * file = fopen(fileName.c_str(), "rb");
    if (file == NULL) return 0;
    fseek(file, 0, SEEK_END);
    long int size = ftell(file);
    fclose(file);

    // Reading data to array of unsigned chars
    file = fopen(fileName.c_str(), "rb");
    data.resize(size);
    int bytes_read = fread(&(data[0]), sizeof(unsigned char), size, file);
    fclose(file);
    if (bytes_read != size)
    {
        data.clear();
        return 0;
    }

    return 1;
}

bool Utility::ReplaceSubstring(std::string& str, const std::string& from, const std::string& to)
{
    size_t start_pos = str.find(from);
    if(start_pos == std::string::npos)
        return false;
    str.replace(start_pos, from.length(), to);
    return true;
}

void Utility::ReplaceAllSubstring(std::string& str, const std::string& from, const std::string& to)
{
    if(from.empty())
        return;
    size_t start_pos = 0;
    while((start_pos = str.find(from, start_pos)) != std::string::npos)
    {
        str.replace(start_pos, from.length(), to);
        start_pos += to.length(); // In case 'to' contains 'from', like replacing 'x' with 'yx'
    }
}
