#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
#include <regex>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

std::vector<std::string> splitString(const std::string& s, const char& delim)
{
    std::vector<std::string> elems;
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        elems.push_back(item);
    }
    return elems;

}
std::string removeNewLine(std::string str)
{
    str.erase(std::remove(str.begin(), str.end(), '\r'), str.end());
    str.erase(std::remove(str.begin(), str.end(), '\n'), str.end());
    return str;
}
std::string getPartOfSpeech(const std::string& str)
{
    std::regex rgx(".*\((\\w+)\).*");
    std::smatch match;

    if (std::regex_search(str.begin(), str.end(), match, rgx))
        return match[1];
    else
        return std::string();
}
std::string getChi(const std::string& str)
{
    std::vector<std::string> parts = splitString(str, ')');
    return removeNewLine(parts[1]);
}
int main(int argc, char* argv[])
{
    // set delimiter
    char delimiter = '\t';
    if (argc < 2)
    {
        std::cout << "Usage: json2csv inputFile.json outputFile.csv" << std::endl;
        return 0;
    }
    // handle I/O files
    std::string inputFile = argv[1];
    std::string outputFile = argv[2];

    std::ofstream outFH(outputFile, std::ios::out);
    if (!outFH.is_open())
    {
        std::cout << "Cannot open file " << outputFile << std::endl;
        return 0;
    }
    boost::property_tree::ptree root;
    boost::property_tree::read_json(inputFile, root);
    for (boost::property_tree::ptree::value_type &word : root.get_child("Words"))
    {
        std::stringstream ssLine;
        ssLine << word.second.get_child("category").get_value<std::string>();
        ssLine << delimiter << word.second.get_child("next_time").get_value<int64_t>();
        ssLine << delimiter << word.second.get_child("error_count").get_value<int>();
        ssLine << delimiter << word.second.get_child("correct_count").get_value<int>();
        ssLine << delimiter << word.second.get_child("eng_word").get_value<std::string>();
        ssLine << delimiter << getPartOfSpeech(word.second.get_child("chi_word").get_value<std::string>());
        ssLine << delimiter << getChi(word.second.get_child("chi_word").get_value<std::string>());
        // handle error timestamp array
        if (word.second.get_child("error_count").get_value<int>() > 0)
        {
            for (boost::property_tree::ptree::value_type &error_timestamp : word.second.get_child("error_timestamps"))
            {
                ssLine << delimiter << error_timestamp.second.get_value<int64_t>();
            }
        }
        outFH << ssLine.str() << std::endl;
    }
    outFH.close();
    return 0;
}
