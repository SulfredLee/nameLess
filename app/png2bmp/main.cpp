#include <iostream>
#include <vector>
#include <string>

#include <stdio.h>
#include <string.h>

#include "png2bmp.h"
#include "Tools.h"

int main(int argc, char* argv[])
{
    if (argc != 3)
    {
        std::cout << "Usage: " << argv[0] << " pngFile bmpFile" << std::endl;
        return -1;
    }
    std::vector<unsigned char> pngImage;
    if (!Utility::ReadFileToArray(argv[1], pngImage))
    {
        std::cout << "Cannot get png file to memory" << std::endl;
        return -1;
    }
    PNG2BMP converter;
    // converter.Convert(argv[1], argv[2]);
    converter.Convert(pngImage, argv[2]);
    return 0;
}
