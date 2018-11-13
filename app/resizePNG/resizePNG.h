#ifndef RESIZE_PNG_H
#define RESIZE_PNG_H

#include "png.h"

#include <string>

class ResizePNG
{
 public:
    ResizePNG();
    ~ResizePNG();

    void ResizeToFont(const std::string& pngFile);
    bool SavePNG(const std::string& outPNGFile);
 private:
    bool ReadPNGFromFile(const std::string& pngFile);
    void ViewPNGFile();
    void FindLeftRight();
    void ResizeRow();
 private:
    // read information
    int m_width;
    int m_height;
    png_byte m_colorType;
    png_byte m_bitDepth;

    png_structp m_pngPtr;
    png_infop m_infoPtr;
    int m_numberOfPasses;
    png_bytep * m_rowPointers;
    // write information
    png_structp m_outPNGPtr;
    png_infop m_outInfoPtr;
    png_bytep * m_outRowPointers;

    int m_outLeft_x;
    int m_outRight_x;

    int m_outWidth;
    int m_outHeight;
};
#endif
