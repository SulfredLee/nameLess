#ifndef PNG2BMP_H
#define PNG2BMP_H
#include <vector>
#include <string>

#include "png.h"
#include "bmpfile.h"

class PNGInputStream
{
 public:
    PNGInputStream();
    ~PNGInputStream();

    bool AddImageData(const std::vector<unsigned char>& imageData, size_t signatureLen);
    bool AddImageData(const std::string& imageFile, size_t signatureLen);
    size_t Read(png_bytep data, size_t length);
 private:
    std::vector<unsigned char> m_imageData;
    size_t m_nextByte;
};

class PNG2BMP
{
 public:
    PNG2BMP();
    ~PNG2BMP();

    bool Convert(const std::string& pngFile, const std::string& bmpFile);
    bool Convert(const std::vector<unsigned char>& pngImage, const std::string& bmpFile);
    bool Convert(const std::vector<unsigned char>& pngImage, std::vector<unsigned char>& bmpImage);
 private:
    bool ReadPNGFromFile(const std::string& pngFile);
    bool ReadPNGFromMemory(const std::vector<unsigned char>& pngImage);
    bool ProcessFile();
    void PNG2BMPMemory(std::vector<unsigned char>& bmpImage);
    void PrintRGBPixel(const rgb_pixel_t& pixel);
    void PrintPNGPixel(png_byte const * const pixel);

 private:
    int m_width;
    int m_height;
    png_byte m_colorType;
    png_byte m_bitDepth;

    png_structp m_pngPtr;
    png_infop m_infoPtr;
    int m_numberOfPasses;
    png_bytep * m_rowPointers;

    bmpfile_t *m_bmp;
};
#endif
