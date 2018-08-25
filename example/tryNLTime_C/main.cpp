#include <iostream>
#include <string>

#include "Logger.h"
#include "NLTime_C.h"

int main(int argc, char* argv[])
{
    NLTime_C* pTime = createNLTime_C();
    SetCurrentTime(pTime);
    char* strTime = NLTime_toString(pTime, "%b %d %H:%M");
    std::cout << "Normal print: " << strTime << std::endl;
    free(strTime);

    NLTime_C* pTime002 = createNLTime_C();
    SetCurrentTime(pTime002);
    strTime = NLTime_toString(pTime002, "%b %d %H:%M");
    std::cout << "Time002: " << strTime << std::endl;
    free(strTime);
    AddTime(pTime, 1, 0, 0);
    strTime = NLTime_toString(pTime, "%b %d %H:%M");
    std::cout << "Time: " << strTime << std::endl;
    if (CompareNLTime_isBigger(pTime002, pTime))
    {
        std::cout << "time002 is bigger" << std::endl;
    }
    else if (CompareNLTime_isEqual(pTime002, pTime))
    {
        std::cout << "They are equal" << std::endl;
    }
    else
    {
        std::cout << "time002 is smaller" << std::endl;
    }

    return 0;
}
