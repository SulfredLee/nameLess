#include <iostream>

#include "NLTime.h"

int main(int argc, char* argv[])
{
    NLTime time;
    time.GetCurrentTime();

    std::cout << time.toString("%b %d %H:%M") << std::endl;

    time.AddDate(0, 1, 0);
    std::cout << time.toString("%b %d %H:%M") << std::endl;

    NLTime time002 = time;
    std::cout << time002.toString("%b %d %H:%M") << std::endl;
    time002.AddTime(1, 0, 0);
    std::cout << time002.toString("%b %d %H:%M") << std::endl;
    if (time002 > time)
    {
        std::cout << "time002 is bigger" << std::endl;
    }
    else
    {
        std::cout << "time002 is smaller" << std::endl;
    }

    time002.SetFromString("16: 35: 12", "%H: %M: %S");
    std::cout << time002.toString("%b %d %H:%M") << std::endl;


    NLTime time003("09:30:50", "%H:%M:%S");
    std::cout << time003.toString("%b %d %H:%M") << std::endl;
    return 0;
}
