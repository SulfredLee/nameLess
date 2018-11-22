#include "png2bmp.h"

#include <stdio.h>
#include <string.h>

// private
static void ReadDataFromInputStream(png_structp png_ptr, png_bytep data, size_t length);
static void PNGErrorFn(png_structp png_ptr, png_const_charp error_msg);
static void PNGWarningFn(png_structp png_ptr, png_const_charp warning_msg);

PNGInputStream::PNGInputStream()
{
    m_nextByte = 0;
}

PNGInputStream::~PNGInputStream()
{
}

bool PNGInputStream::AddImageData(const std::vector<unsigned char>& imageData, size_t signatureLen)
{
    m_imageData.clear();
    m_imageData = imageData;
    if (signatureLen <= 8) // we add this handling based on libpng 1.6.35
        m_nextByte = signatureLen;
    return true;
}

bool PNGInputStream::AddImageData(const std::string& imageFile, size_t signatureLen)
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

    if (signatureLen <= 8) // we add this handling based on libpng 1.6.35
        m_nextByte = signatureLen;
    return true;
}

size_t PNGInputStream::Read(png_bytep data, size_t length)
{
    if (length + m_nextByte < m_imageData.size())
    {
        memcpy(data, (char*)&(m_imageData[m_nextByte]), length);
        m_nextByte += length;
        return length;
    }
    else
    {
        fprintf(stderr, "[%s:%d] request data is too long: %lu, we only have: %lu", __func__, __LINE__, length + m_nextByte, m_imageData.size());
        return 0;
    }
}

PNG2BMP::PNG2BMP()
{
    m_rowPointers = NULL;
}

PNG2BMP::~PNG2BMP()
{
    for (int y = 0; y < m_height; y++)
    {
        if (m_rowPointers[y])
            delete[] m_rowPointers[y];
    }
    if (m_rowPointers)
        delete[] m_rowPointers;
    png_destroy_read_struct(&m_pngPtr, &m_infoPtr, NULL);
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
    std::vector<unsigned char> bmpImage;
    Convert(pngImage, bmpImage);

    m_bmp = bmp_create(m_width, m_height, 32);
    // copy data to bmp structure
    for (int y = 0; y < m_height; y++)
    {
        for (int x = 0; x < m_width; x++)
        {
            int z = (y * m_width * 4) + (x * 4);
            rgb_pixel_t pixel;
            pixel.red = bmpImage[z];
            pixel.green = bmpImage[z + 1];
            pixel.blue = bmpImage[z + 2];
            pixel.alpha = bmpImage[z + 3];
            bmp_set_pixel(m_bmp, x, y, pixel);
        }
    }
    bmp_save(m_bmp, bmpFile.c_str());
    bmp_destroy(m_bmp);

    return true;
}

bool PNG2BMP::Convert(const std::vector<unsigned char>& pngImage, std::vector<unsigned char>& bmpImage)
{
    if (!ReadPNGFromMemory(pngImage))
    {
        fprintf(stderr, "[%s:%d] Fail ReadPNGFromMemory\n", __func__, __LINE__);
        return false;
    }

    PNG2BMPMemory(bmpImage);
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
    inputStream.AddImageData(pngImage, 8);
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

    // png_voidp error_ptr = png_get_error_ptr(png_ptr);
    // if (!error_ptr)
    // {
    //     fprintf(stderr, "[%s:%d] png_get_error_ptr failed\n", __func__, __LINE__);
    //     return false;
    // }
    // png_set_error_fn(m_pngPtr, error_ptr, PNGErrorFn, PNGWarningFn);

    m_infoPtr = png_create_info_struct(m_pngPtr);
    if (!m_infoPtr)
    {
        fprintf(stderr, "[%s:%d] png_create_read_struct failed\n", __func__, __LINE__);
        return false;
    }

    /* read file */
    if (setjmp(png_jmpbuf(m_pngPtr)))
    {
        png_destroy_read_struct(&m_pngPtr, &m_infoPtr, NULL);
        fprintf(stderr, "[%s:%d] Error during read_image\n", __func__, __LINE__);
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


    m_rowPointers = (png_bytep*) new png_byte[(sizeof(png_bytep) * m_height)];
    for (int y = 0; y < m_height; y++)
        m_rowPointers[y] = (png_byte*) new png_byte[(png_get_rowbytes(m_pngPtr, m_infoPtr))];

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
        size_t check = inputStream.Read(data, length);
        if (check != length)
        {
            fprintf(stderr, "[%s:%d] Length miss match, return: %lu, request: %lu\n", __func__, __LINE__, check, length);
        }
    }
}

void PNG2BMP::PNG2BMPMemory(std::vector<unsigned char>& bmpImage)
{
    bmpImage.clear();
    bmpImage.resize(m_width * m_height * 4);

    for (int y = 0; y < m_height; y++)
    {
        png_byte* row = m_rowPointers[y];
        for (int x = 0; x < m_width; x++)
        {
            int z = (y * m_width * 4) + (x * 4);
            if (m_colorType == PNG_COLOR_TYPE_RGB_ALPHA)
            {
                png_byte* ptr = &(row[x * 4]);
                bmpImage[z] = ptr[0]; // red
                bmpImage[z + 1] = ptr[1]; // green
                bmpImage[z + 2] = ptr[2]; // blue
                bmpImage[z + 3] = ptr[3]; // alpha
            }
            else if (m_colorType == PNG_COLOR_TYPE_RGB)
            {
                png_byte* ptr = &(row[x * 3]);
                bmpImage[z] = ptr[0]; // red
                bmpImage[z + 1] = ptr[1]; // green
                bmpImage[z + 2] = ptr[2]; // blue
                bmpImage[z + 3] = 255; // alpha
            }
        }
    }
}

void PNG2BMP::PrintRGBPixel(const rgb_pixel_t& pixel)
{
    fprintf(stderr, "[%s:%d] sulfred debug red: %X green: %X blue: %X alpha: %X\n", __func__, __LINE__, pixel.red, pixel.green, pixel.blue, pixel.alpha);
}

void PNG2BMP::PrintPNGPixel(png_byte const * const pixel)
{
    fprintf(stderr, "[%s:%d] sulfred debug red: %X green: %X blue: %X alpha: %X\n", __func__, __LINE__, pixel[0], pixel[1], pixel[2], pixel[3]);
}

void PNGErrorFn(png_structp png_ptr, png_const_charp error_msg)
{
    fprintf(stderr, "[%s:%d] sulfred debug\n", __func__, __LINE__);
}

void PNGWarningFn(png_structp png_ptr, png_const_charp warning_msg)
{
    fprintf(stderr, "[%s:%d] sulfred debug\n", __func__, __LINE__);
}
