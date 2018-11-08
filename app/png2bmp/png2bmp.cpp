#include "png2bmp.h"

#include <stdio.h>
#include <string.h>

// private
static void ReadDataFromInputStream(png_structp png_ptr, png_bytep data, size_t length);

PNGInputStream::PNGInputStream()
{
}

PNGInputStream::~PNGInputStream()
{
}

bool PNGInputStream::AddImageData(const std::vector<unsigned char>& imageData)
{
    m_imageData.clear();
    m_imageData = imageData;
    return true;
}

bool PNGInputStream::AddImageData(const std::string& imageFile)
{
    // Reading size of file
    FILE * file = fopen(imageFile.c_str(), "rb");
    if (file == NULL) return false;
    fseek(file, 0, SEEK_END);
    long int size = ftell(file);
    fclose(file);
    // Reading data to array of unsigned chars
    file = fopen(imageFile.c_str(), "rb");
    m_imageData.resize(size);
    int bytes_read = fread((char*)&(m_imageData[0]), sizeof(unsigned char), size, file);
    fclose(file);

    if (bytes_read != size) return false;

    return true;
}

unsigned char* PNGInputStream::GetData()
{
    return &(m_imageData[0]);
}

size_t PNGInputStream::GetDataLen()
{
    return m_imageData.size();
}

PNG2BMP::PNG2BMP()
{
}

PNG2BMP::~PNG2BMP()
{
    for (int y = 0; y < m_height; y++)
        free(m_rowPointers[y]);
    free(m_rowPointers);
}

bool PNG2BMP::Convert(const std::string& pngFile, const std::string& bmpFile)
{
    if (!ReadPNGFromFile(pngFile))
    {
        fprintf(stderr, "[%s:%d] Fail to read png file %s\n", __func__, __LINE__, pngFile.c_str());
        return false;
    }

    m_bmp = bmp_create(m_width, m_height, 32);

    ProcessFile();

    bmp_save(m_bmp, bmpFile.c_str());
    bmp_destroy(m_bmp);

    return true;
}

bool PNG2BMP::Convert(const std::vector<unsigned char>& pngImage, const std::string& bmpFile)
{
    if (!ReadPNGFromMemory(pngImage))
    {
        fprintf(stderr, "[%s:%d] Fail ReadPNGFromMemory\n", __func__, __LINE__);
        return false;
    }

    m_bmp = bmp_create(m_width, m_height, 32);

    ProcessFile();

    bmp_save(m_bmp, bmpFile.c_str());
    bmp_destroy(m_bmp);

    return true;
}

bool PNG2BMP::Convert(const std::vector<unsigned char>& pngImage, std::vector<unsigned char>& bmpImage)
{
    return true;
}

bool PNG2BMP::ReadPNGFromFile(const std::string& pngFile)
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


    /* read file */
    if (setjmp(png_jmpbuf(m_pngPtr)))
    {
        fprintf(stderr, "[%s:%d] Error during read_image\n", __func__, __LINE__);
        return false;
    }

    m_rowPointers = (png_bytep*) malloc(sizeof(png_bytep) * m_height);
    for (int y = 0; y < m_height; y++)
        m_rowPointers[y] = (png_byte*) malloc(png_get_rowbytes(m_pngPtr, m_infoPtr));

    png_read_image(m_pngPtr, m_rowPointers);

    fclose(fp);
    return true;
}

bool PNG2BMP::ProcessFile()
{
    for (int y = 0; y < m_height; y++)
    {
        png_byte* row = m_rowPointers[y];
        for (int x = 0; x < m_width; x++)
        {
            if (m_colorType == PNG_COLOR_TYPE_RGB_ALPHA)
            {
                png_byte* ptr = &(row[x * 4]);
                rgb_pixel_t pixel;
                pixel.red = ptr[0];
                pixel.green = ptr[1];
                pixel.blue = ptr[2];
                pixel.alpha = ptr[3];
                bmp_set_pixel(m_bmp, x, y, pixel);
            }
            else if (m_colorType == PNG_COLOR_TYPE_RGB)
            {
                png_byte* ptr = &(row[x * 3]);
                rgb_pixel_t pixel;
                pixel.red = ptr[0];
                pixel.green = ptr[1];
                pixel.blue = ptr[2];
                pixel.alpha = 255;
                bmp_set_pixel(m_bmp, x, y, pixel);
            }
        }
    }
    return true;
}

bool PNG2BMP::ReadPNGFromMemory(const std::vector<unsigned char>& pngImage)
{
    PNGInputStream inputStream;
    inputStream.AddImageData(pngImage);
    png_byte header[8]; // 8 is the maximum size that can be checked

    memcpy((char*)&(header[0]), (char*)&(pngImage[0]), 8);
    if (png_sig_cmp(header, 0, 8))
    {
        fprintf(stderr, "[%s:%d] pngImage is not recognized as a PNG file\n", __func__, __LINE__);
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

    png_set_read_fn(m_pngPtr, (void*)&inputStream, ReadDataFromInputStream);
    png_set_sig_bytes(m_pngPtr, 8);

    png_read_info(m_pngPtr, m_infoPtr);

    m_width = png_get_image_width(m_pngPtr, m_infoPtr);
    m_height = png_get_image_height(m_pngPtr, m_infoPtr);
    m_colorType = png_get_color_type(m_pngPtr, m_infoPtr);
    m_bitDepth = png_get_bit_depth(m_pngPtr, m_infoPtr);
    fprintf(stderr, "[%s:%d] PNG: %d x %d, color type = %d, bit depth = %d\n", __func__, __LINE__, m_width, m_height, m_colorType, m_bitDepth);

    m_numberOfPasses = png_set_interlace_handling(m_pngPtr);
    png_read_update_info(m_pngPtr, m_infoPtr);


    /* read file */
    if (setjmp(png_jmpbuf(m_pngPtr)))
    {
        fprintf(stderr, "[%s:%d] Error during read_image\n", __func__, __LINE__);
        return false;
    }

    m_rowPointers = (png_bytep*) malloc(sizeof(png_bytep) * m_height);
    for (int y = 0; y < m_height; y++)
        m_rowPointers[y] = (png_byte*) malloc(png_get_rowbytes(m_pngPtr, m_infoPtr));

    png_read_image(m_pngPtr, m_rowPointers);

    return true;
}

void ReadDataFromInputStream(png_structp png_ptr, png_bytep data, size_t length)
{
    png_voidp io_ptr;

    io_ptr = png_get_io_ptr(png_ptr);
    if (io_ptr != NULL)
    {
        PNGInputStream& inputStream = *(PNGInputStream*)io_ptr;
        if (length <= inputStream.GetDataLen())
        {
            memcpy((char*)data, inputStream.GetData(), length);
        }
        else
        {
            fprintf(stderr, "[%s:%d] Length miss match, pngLen: %lu, inpug image length: %lu\n", __func__, __LINE__, length, inputStream.GetDataLen());
        }
    }
}
