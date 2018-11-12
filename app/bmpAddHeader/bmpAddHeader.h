#ifndef BMPADDHEADER_H
#define BMPADDHEADER_H

#include <string>
#include <vector>

#include "bmpfile.h"

enum BMPType
{
    BMP_RGBA,
    BMP_ARGB,
    BMP_TYPE_END
};

class BMPAddHeader
{
 public:
    BMPAddHeader();
    ~BMPAddHeader();

    void RecreateBMP(const std::string& bmpFile, BMPType bmpType);
    void SaveBMP(const std::string& bmpFile);
 private:
    bmpfile_t *m_bmp;
 private:
    void Create_ARGB(const std::vector<unsigned char>& data);
    void Create_RGBA(const std::vector<unsigned char>& data);
};

#endif
