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

    bool AddImageData(const std::vector<unsigned char>& imageData);
    bool AddImageData(const std::string& imageFile);
    unsigned char* GetData();
    size_t GetDataLen();
 private:
    std::vector<unsigned char> m_imageData;
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
