#include <iostream>

#include "resizePNG.h"

int main (int argc, char* argv[])
{
    if (argc != 3)
    {
        std::cout << "Usage: " << argv[0] << " pngFile outPNGFile" << std::endl;
        return -1;
    }
    ResizePNG resizePNG;
    resizePNG.ResizeToFont(argv[1]);
    resizePNG.SavePNG(argv[2]);
    return 0;
}
