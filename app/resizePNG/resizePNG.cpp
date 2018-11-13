#include "resizePNG.h"

#include <stdio.h>
#include <string.h>

ResizePNG::ResizePNG()
{
}

ResizePNG::~ResizePNG()
{
    for (int y = 0; y < m_height; y++)
    {
        delete[] m_rowPointers[y];
    }
    delete[] m_rowPointers;
    png_destroy_read_struct(&m_pngPtr, &m_infoPtr, NULL);

    for (int y = 0; y < m_outHeight; y++)
    {
        delete[] m_outRowPointers[y];
    }
    delete[] m_outRowPointers;
    png_destroy_write_struct(&m_outPNGPtr, &m_outInfoPtr);
}

void ResizePNG::ResizeToFont(const std::string& pngFile)
{
    ReadPNGFromFile(pngFile);
    // ViewPNGFile();
    FindLeftRight();
    ResizeRow();
}

bool ResizePNG::SavePNG(const std::string& outPNGFile)
{
    FILE* fp = fopen(outPNGFile.c_str(), "wb");
    if (fp == NULL)
    {
        fprintf(stderr, "[%s:%d] File %s could not be opened for writing\n", __func__, __LINE__, outPNGFile.c_str());
        return false;
    }

    m_outPNGPtr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!m_outPNGPtr)
    {
        fprintf(stderr, "[%s:%d] png_create_write_struct failed\n", __func__, __LINE__);
        return false;
    }

    m_outInfoPtr = png_create_info_struct(m_outPNGPtr);
    if (!m_outInfoPtr)
    {
        fprintf(stderr, "[%s:%d] png_create_info_struct failed\n", __func__, __LINE__);
        return false;
    }

    if (setjmp(png_jmpbuf(m_outPNGPtr)))
    {
        png_destroy_write_struct(&m_outPNGPtr, &m_outInfoPtr);
        fprintf(stderr, "[%s:%d] Error during init_io\n", __func__, __LINE__);
        return false;
    }

    png_set_IHDR(
                 m_outPNGPtr,
                 m_outInfoPtr,
                 m_outWidth, m_outHeight,
                 8,
                 PNG_COLOR_TYPE_RGBA,
                 PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT,
                 PNG_FILTER_TYPE_DEFAULT
                 );
    png_init_io(m_outPNGPtr, fp);

    png_write_info(m_outPNGPtr, m_outInfoPtr);

    png_write_image(m_outPNGPtr, m_outRowPointers);

    png_write_end(m_outPNGPtr, NULL);
    fclose(fp);
}

bool ResizePNG::ReadPNGFromFile(const std::string& pngFile)
{
    png_byte header[8]; // 8 is the maximum size that can be checked

    /* open file and test for it being a png */
    FILE* fp = fopen(pngFile.c_str(), "rb");
    if (fp == NULL)
    {
        fprintf(stderr, "[%s:%d] File %s could not be opened for reading\n", __func__, __LINE__, pngFile.c_str());
        return false;
    }
    size_t result = fread(header, 1, 8, fp);
    if (result != 8)
    {
        fprintf(stderr, "[%s:%d] Reading error\n", __func__, __LINE__);
        return false;
    }
    if (png_sig_cmp(header, 0, 8))
    {
        fprintf(stderr, "[%s:%d] File %s is not recognized as a PNG file\n", __func__, __LINE__, pngFile.c_str());
        return false;
    }


    /* initialize stuff */
    m_pngPtr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

    if (!m_pngPtr)
    {
        fprintf(stderr, "[%s:%d] png_create_read_struct failed\n", __func__, __LINE__);
        return false;
    }

    m_infoPtr = png_create_info_struct(m_pngPtr);
    if (!m_infoPtr)
    {
        fprintf(stderr, "[%s:%d] png_create_read_struct failed\n", __func__, __LINE__);
        return false;
    }

    if (setjmp(png_jmpbuf(m_pngPtr)))
    {
        png_destroy_read_struct(&m_pngPtr, &m_infoPtr, NULL);
        fprintf(stderr, "[%s:%d] Error during init_io\n", __func__, __LINE__);
        return false;
    }

    png_init_io(m_pngPtr, fp);
    png_set_sig_bytes(m_pngPtr, 8);

    png_read_info(m_pngPtr, m_infoPtr);

    m_width = png_get_image_width(m_pngPtr, m_infoPtr);
    m_height = png_get_image_height(m_pngPtr, m_infoPtr);
    m_colorType = png_get_color_type(m_pngPtr, m_infoPtr);
    m_bitDepth = png_get_bit_depth(m_pngPtr, m_infoPtr);
    fprintf(stderr, "[%s:%d] PNG: %d x %d, color type = %d, bit depth = %d\n", __func__, __LINE__, m_width, m_height, m_colorType, m_bitDepth);

    m_numberOfPasses = png_set_interlace_handling(m_pngPtr);
    png_read_update_info(m_pngPtr, m_infoPtr);

    m_rowPointers = (png_bytep*) new png_byte[(sizeof(png_bytep) * m_height)];
    for (int y = 0; y < m_height; y++)
        m_rowPointers[y] = (png_byte*) new png_byte[(png_get_rowbytes(m_pngPtr, m_infoPtr))];

    png_read_image(m_pngPtr, m_rowPointers);

    fclose(fp);
    return true;
}

void ResizePNG::ViewPNGFile()
{
    for (int y = 0; y < m_height; y++)
    {
        png_byte* row = m_rowPointers[y];
        for (int x = 0; x < m_width; x++)
        {
            if (m_colorType == PNG_COLOR_TYPE_RGB_ALPHA)
            {
                png_byte* ptr = &(row[x * 4]);
                fprintf(stderr, "%02X ", ptr[3]);
            }
            else if (m_colorType == PNG_COLOR_TYPE_RGB)
            {
                png_byte* ptr = &(row[x * 3]);
                fprintf(stderr, "%02X ", 255);
            }
        }
        fprintf(stderr, "\n");
    }
}

void ResizePNG::FindLeftRight()
{
    if (m_colorType == PNG_COLOR_TYPE_RGB)
    {
        m_outLeft_x = 0;
        m_outRight_x = m_width;
        return;
    }

    m_outLeft_x = m_width;
    m_outRight_x = 0;
    for (int y = 0; y < m_height; y++)
    {
        png_byte* row = m_rowPointers[y];
        // find Left x
        for (int x = 0; x < m_width; x++)
        {
            if (m_colorType == PNG_COLOR_TYPE_RGB_ALPHA)
            {
                png_byte* ptr = &(row[x * 4]);
                if (ptr[3] > 0 && x < m_outLeft_x)
                {
                    m_outLeft_x = x;
                    break;
                }
            }
        }
        // find Right x
        for (int x = m_width - 1; x >= 0; x--)
        {
            if (m_colorType == PNG_COLOR_TYPE_RGB_ALPHA)
            {
                png_byte* ptr = &(row[x * 4]);
                if (ptr[3] > 0 && x > m_outRight_x)
                {
                    m_outRight_x = x;
                    break;
                }
            }
        }
    }
}

void ResizePNG::ResizeRow()
{
    m_outWidth = m_outRight_x - m_outLeft_x + 1;
    m_outHeight = m_height;

    m_outRowPointers = (png_bytep*) new png_byte[(sizeof(png_bytep) * m_outHeight)];
    for (int y = 0; y < m_outHeight; y++)
        m_outRowPointers[y] = (png_byte*) new png_byte[m_outWidth * 4];

    for (int y = 0; y < m_outHeight; y++)
    {
        png_byte* row = m_rowPointers[y];
        png_byte* outRow = m_outRowPointers[y];
        for (int x = 0; x < m_outWidth; x++)
        {
             png_byte* ptr = &(row[(x + m_outLeft_x) * 4]);
             png_byte* outPtr = &(outRow[x * 4]);
             outPtr[0] = ptr[0];
             outPtr[1] = ptr[1];
             outPtr[2] = ptr[2];
             outPtr[3] = ptr[3];
        }
    }
}
