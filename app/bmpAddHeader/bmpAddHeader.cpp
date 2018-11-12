#include "bmpAddHeader.h"
#include "Tools.h"

#include <stdio.h>
#include <string.h>

BMPAddHeader::BMPAddHeader()
{
    m_bmp = nullptr;
}

BMPAddHeader::~BMPAddHeader() {}

void BMPAddHeader::RecreateBMP(const std::string& bmpFile, BMPType bmpType)
{
    std::vector<unsigned char> data;
    Utility::ReadFileToArray(bmpFile, data);

    switch (bmpType)
    {
        case BMP_ARGB:
            Create_ARGB(data);
            break;
        case BMP_RGBA:
            Create_RGBA(data);
            break;
        case BMP_TYPE_END:
        default:
            break;
    }
}

void BMPAddHeader::SaveBMP(const std::string& bmpFile)
{
    if (m_bmp)
    {
        bmp_save(m_bmp, bmpFile.c_str());
        bmp_destroy(m_bmp);
    }
}

void BMPAddHeader::Create_ARGB(const std::vector<unsigned char>& data)
{
    int width, height;
    memcpy((char*)&width, (char*)&(data[0]), sizeof(int));
    memcpy((char*)&height, (char*)&(data[sizeof(int)]), sizeof(int));

    m_bmp = bmp_create(width, height, 32);

    for (size_t i = sizeof(int) * 2; i + 4 < data.size(); i += 4)
    {
        rgb_pixel_t pixel;
        pixel.alpha = data[i];
        pixel.red = data[i + 1];
        pixel.green = data[i + 2];
        pixel.blue = data[i + 3];

        // handle x y posiiton
        uint32_t x = i % width;
        uint32_t y = i / width;

        bmp_set_pixel(m_bmp, x, y, pixel);
    }
}

void BMPAddHeader::Create_RGBA(const std::vector<unsigned char>& data)
{
    int width, height;
    memcpy((char*)&width, (char*)&(data[0]), sizeof(int));
    memcpy((char*)&height, (char*)&(data[sizeof(int)]), sizeof(int));

    m_bmp = bmp_create(width, height, 32);

    for (size_t i = sizeof(int) * 2; i + 4 < data.size(); i += 4)
    {
        rgb_pixel_t pixel;
        pixel.red = data[i];
        pixel.green = data[i + 1];
        pixel.blue = data[i + 2];
        pixel.alpha = data[i + 3];

        // handle x y posiiton
        uint32_t x = i % width;
        uint32_t y = i / width;

        bmp_set_pixel(m_bmp, x, y, pixel);
    }
}
