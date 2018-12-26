#include "PlayerMsg_DownloadFile.h"

PlayerMsg_DownloadFile::PlayerMsg_DownloadFile()
{}

PlayerMsg_DownloadFile::~PlayerMsg_DownloadFile()
{}

// override
PlayerMsg_Type PlayerMsg_DownloadFile::GetMsgType()
{
    return PlayerMsg_Type_DownloadFile;
}

// override
std::string PlayerMsg_DownloadFile::GetMsgTypeName()
{
    return "PlayerMsg_Type_DownloadFile";
}

// override
int PlayerMsg_DownloadFile::GetMsgSize() // only report message size when message has media data
{
    return m_file.size();
}

void PlayerMsg_DownloadFile::SetURL(std::string url)
{
    m_url = url;
}

void PlayerMsg_DownloadFile::SetFile(unsigned char* data, size_t dataLength)
{
    m_file.clear();
    m_file.insert(m_file.end(), data, data + dataLength);
}

std::string PlayerMsg_DownloadFile::GetURL()
{
    return m_url;
}

std::vector<unsigned char> PlayerMsg_DownloadFile::GetFile()
{
    return m_file;
}

size_t PlayerMsg_DownloadFile::GetFileLength()
{
    return m_file.size();
}