#include <iostream>
#include <vector>
#include <string>

#include <stdio.h>
#include <string.h>

#include "png2bmp.h"

bool GetPNGFromFile(const std::string& pngFile, std::vector<unsigned char>& pngImage)
{
    // Reading size of file
    FILE * file = fopen(pngFile.c_str(), "rb");
    if (file == NULL) return false;
    fseek(file, 0, SEEK_END);
    long int size = ftell(file);
    fclose(file);
    // Reading data to array of unsigned chars
    file = fopen(pngFile.c_str(), "rb");
    pngImage.resize(size);
    int bytes_read = fread((char*)&(pngImage[0]), sizeof(unsigned char), size, file);
    fclose(file);

    if (bytes_read != size) return false;

    return true;
}

int main(int argc, char* argv[])
{
    if (argc != 3)
    {
        std::cout << "Usage: " << argv[0] << " pngFile bmpFile" << std::endl;
        return -1;
    }
    std::vector<unsigned char> pngImage;
    if (!GetPNGFromFile(argv[1], pngImage))
    {
        std::cout << "Cannot get png file to memory" << std::endl;
        return -1;
    }
    PNG2BMP converter;
    // converter.Convert(argv[1], argv[2]);
    converter.Convert(pngImage, argv[2]);
    return 0;
}
