#include <iostream>
#include <string>

#include "Logger.h"
#include "InputParser.h"
#include "pdfBuilder.h"
#include "movingClose.h"
#include "app.h"
int main(int argc, char* argv[])
{
    InputParser parser(argc, argv);
    std::string dataFile = parser.getCmdOption("-f");
    std::string appType = parser.getCmdOption("-t");
    std::string resultFile = parser.getCmdOption("-o");
    if (dataFile == "" || appType == "" || resultFile == "")
    {
        LOGMSG_ERROR("Usage: %s -f data.csv -o outputFile -t parserType", argv[0]);
        return 0;
    }

    app* myApp = nullptr;
    if (appType == "pdfBuilder")
        myApp = new pdfBuilder;
    else if (appType == "movingClose")
        myApp = new MovingClose;

    myApp->InitComponent(dataFile, resultFile);
    myApp->Main();
    myApp->PrintResult();

    if (myApp != nullptr)
        delete myApp;
    return 0;
}
