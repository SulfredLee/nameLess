#include <iostream>
#include <string>
#include <sstream>

#include "bmpAddHeader.h"

int main(int argc, char* argv[])
{
    if (argc != 4)
    {
        std::cout << "Usage: " << argv[0] << " <bmpFile> <bmpType>" << std::endl;
        return 0;
    }
    std::string bmpFile(argv[1]);
    std::stringstream outBMPFile; outBMPFile << bmpFile << ".bmp";
    BMPType bmpType = static_cast<BMPType>(std::stoi(argv[2]));

    BMPAddHeader bmpAddHeader;
    bmpAddHeader.RecreateBMP(bmpFile, bmpType);
    bmpAddHeader.SaveBMP(outBMPFile.str());

    return 0;
}
