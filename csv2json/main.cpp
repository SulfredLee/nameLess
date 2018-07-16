#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <chrono>
#include <algorithm>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

bool is_number(const std::string& s)
{
    return !s.empty() && std::find_if(s.begin(), s.end(), [](char c){return !std::isdigit(c);}) == s.end();
}
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
int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        std::cout << "Usage: csv2json inputFile.csv outputFile.json" << std::endl;
        return 0;
    }
    std::string inputFile = argv[1];
    std::string outputFile = argv[2];
    std::ifstream FH(inputFile);
    if (!FH.is_open())
    {
        std::cout << "Cannot open file " << inputFile << std::endl;
        return 0;
    }
    int64_t newNow = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    std::string strLine;
    boost::property_tree::ptree root;
    boost::property_tree::ptree words_node;
    int countWord = 0;
    while (std::getline(FH, strLine))
    {
        std::vector<std::string> parts = splitString(strLine, '\t');
        boost::property_tree::ptree word_node;
        std::transform(parts[0].begin(), parts[0].end(), parts[0].begin(), std::ptr_fun(tolower));
        word_node.put("category", parts[0]);
        word_node.put("next_time", (int64_t)stoll(parts[1]));
        word_node.put("error_count", stoi(parts[2]));
        word_node.put("correct_count", stoi(parts[3]));
        word_node.put("eng_word", parts[4]);
        std::string chiWord = "(" + parts[5] + ") " + parts[6];
        word_node.put("chi_word", chiWord);

        // handle error timestamp array
        boost::property_tree::ptree error_timestamps;
        if (parts.size() > 7 && is_number(parts[7]))
        {
            for (size_t i = 7; i < parts.size(); i++)
            {
                if (parts[i] != "" && is_number(parts[i]))
                {
                    boost::property_tree::ptree error_timestamp;
                    error_timestamp.put("", (int64_t)stoll(parts[i]));
                    error_timestamps.push_back(std::make_pair("", error_timestamp));
                }
            }
        }
        else
        {
            boost::property_tree::ptree error_timestamp;
            error_timestamp.put("", (int64_t)newNow);
            error_timestamps.push_back(std::make_pair("", error_timestamp));
        }
        word_node.add_child("error_timestamps", error_timestamps);

        // save word structure
        words_node.push_back(std::make_pair("", word_node));
    }
    FH.close();
    root.add_child("Words", words_node);


    std::ofstream oFH(outputFile);
    if (oFH.is_open())
    {
        boost::property_tree::write_json(oFH, root);
    }
    oFH.close();

    return 0;
}
