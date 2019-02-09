#include "ErrorHandler.h"
#include "Logger.h"

ErrorHandler::ErrorHandler()
{
    m_videoFileName = "";
    m_audioFileName = "";
    m_subtitleFileName = "";

    m_videoErrorCount = 0;
    m_audioErrorCount = 0;
    m_subtitleErrorCount = 0;

    m_maxErrorCount = 5;
}

ErrorHandler::~ErrorHandler()
{
}

bool ErrorHandler::IsTryAgain(std::shared_ptr<PlayerMsg_DownloadFinish> msg)
{
    switch (msg->GetFileType())
    {
        case PlayerMsg_Type_DownloadVideo:
            return IsTryAgain_Video(msg);
        case PlayerMsg_Type_DownloadAudio:
            return IsTryAgain_Audio(msg);
        case PlayerMsg_Type_DownloadSubtitle:
            return IsTryAgain_Subtitle(msg);
        default:
            break;
    }
    return true;
}

bool ErrorHandler::IsTryAgain_Video(std::shared_ptr<PlayerMsg_DownloadFinish> msg)
{
    DefaultLock lock(&m_mutex);

    if (msg->GetFileName() == m_videoFileName)
    {
        m_videoFileName = msg->GetFileName();
        m_videoErrorCount++;
    }

    if (m_videoErrorCount > m_maxErrorCount)
    {
        LOGMSG_INFO("Tried too many times. %s", msg->GetFileName().c_str());
        m_videoFileName = "";
        m_videoErrorCount = 0;
        return false;
    }
    else
        return true;
}

bool ErrorHandler::IsTryAgain_Audio(std::shared_ptr<PlayerMsg_DownloadFinish> msg)
{
    DefaultLock lock(&m_mutex);

    if (msg->GetFileName() == m_audioFileName)
    {
        m_audioFileName = msg->GetFileName();
        m_audioErrorCount++;
    }

    if (m_audioErrorCount > m_maxErrorCount)
    {
        LOGMSG_INFO("Tried too many times. %s", msg->GetFileName().c_str());
        m_audioFileName = "";
        m_audioErrorCount = 0;
        return false;
    }
    else
        return true;
}

bool ErrorHandler::IsTryAgain_Subtitle(std::shared_ptr<PlayerMsg_DownloadFinish> msg)
{
    DefaultLock lock(&m_mutex);

    if (msg->GetFileName() == m_subtitleFileName)
    {
        m_subtitleFileName = msg->GetFileName();
        m_subtitleErrorCount++;
    }

    if (m_subtitleErrorCount > m_maxErrorCount)
    {
        LOGMSG_INFO("Tried too many times. %s", msg->GetFileName().c_str());
        m_subtitleFileName = "";
        m_subtitleErrorCount = 0;
        return false;
    }
    else
        return true;
}
