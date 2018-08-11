#ifndef APP_H
#define APP_H
#include <string>
class app
{
 public:
    app(){}
    virtual ~app(){}

    virtual void InitComponent(const std::string& dataFile, const std::string& resultFile) = 0;
    virtual void Main() = 0;
    virtual void PrintResult() = 0;
};
#endif
