#include "dashSegmentSelector.h"
#include "Logger.h"
#include <algorithm>

dashSegmentSelector::dashSegmentSelector()
{
    m_mpdFile = nullptr;
    InitStatus(m_videoStatus);
    InitStatus(m_audioStatus);
    InitStatus(m_subtitleStatus);
}

dashSegmentSelector::~dashSegmentSelector()
{}

void dashSegmentSelector::InitComponent(cmdReceiver* manager)
{
    segmentSelector::InitComponent(manager);
}

void dashSegmentSelector::ProcessMsg(std::shared_ptr<PlayerMsg_DownloadMPD> msg)
{
    LOGMSG_INFO("Process message %s", msg->GetMsgTypeName().c_str());
    m_mpdFile = msg->GetAndMoveMPDFile();

    // handle download process status
    m_videoStatus.m_numberSegment = 0;
}

void dashSegmentSelector::ProcessMsg(std::shared_ptr<PlayerMsg_Play> msg)
{
    // get current player status
    std::shared_ptr<PlayerMsg_Base> msgBase = m_msgFactory.CreateMsg(PlayerMsg_Type_GetPlayerStage);
    SendToManager(msgBase);
    std::shared_ptr<PlayerMsg_GetPlayerStage> msgGetStage = std::dynamic_pointer_cast<PlayerMsg_GetPlayerStage>(msgBase);
    if (msgGetStage->GetPlayerStage() == PlayerStage_Play)
    {
        HandleVideoSegment();
        HandleAudioSegment();
        HandleSubtitleSegment();
    }
    else
    {
        LOGMSG_ERROR("Cannot play movie. Current player stage is: %u", msgGetStage->GetPlayerStage());
    }
}

void dashSegmentSelector::ProcessMsg(std::shared_ptr<PlayerMsg_Pause> msg)
{
}

void dashSegmentSelector::ProcessMsg(std::shared_ptr<PlayerMsg_Stop> msg)
{
}

void dashSegmentSelector::ProcessMsg(std::shared_ptr<PlayerMsg_DownloadFinish> msg)
{
    switch(msg->GetFileType())
    {
        case PlayerMsg_Type_DownloadVideo:
            {
                m_videoStatus.m_downloadSpeed = msg->GetSpeed();
                m_videoStatus.m_downloadTime = msg->GetDownloadTime();
                if (!m_videoStatus.m_initFileReady)
                    m_videoStatus.m_initFileReady = true;
                else
                    m_videoStatus.m_numberSegment++;

                HandleVideoSegment();
                break;
            }
        case PlayerMsg_Type_DownloadAudio:
        case PlayerMsg_Type_DownloadSubtitle:
        default:
            break;
    }
}

void dashSegmentSelector::InitStatus(dashMediaStatus& status)
{
    status.m_initFileReady = false;
    status.m_downloadSpeed = 0;
    status.m_downloadTime = 0;
    status.m_playTime = 0;
    status.m_numberSegment = 0;
}

void dashSegmentSelector::HandleVideoSegment()
{
    // get target criteria
    uint32_t targetDownloadSize = GetTargetDownloadSize_Video();
    // get url information
    downloadInfo videoDownloadInfo = GetDownloadInfo_Video(targetDownloadSize);
    // generate url
    uint64_t nextDownloadTime;
    std::string targetURL = GetDownloadURL_Video(videoDownloadInfo, nextDownloadTime);

    LOGMSG_INFO("targetURL: %s", targetURL.c_str());

    if (targetURL.length())
    {
        // send download message
        std::shared_ptr<PlayerMsg_DownloadFile> msgDVideo = std::dynamic_pointer_cast<PlayerMsg_DownloadFile>(m_msgFactory.CreateMsg(PlayerMsg_Type_DownloadVideo));
        msgDVideo->SetURL(targetURL);
        msgDVideo->SetDownloadTime(nextDownloadTime);
        SendToManager(std::static_pointer_cast<PlayerMsg_Base>(msgDVideo));
    }
}

void dashSegmentSelector::HandleAudioSegment()
{
    if (m_audioStatus.m_initFileReady)
    {
    }
    else
    {
        // DownloadInitFile_Audio();
    }
}

void dashSegmentSelector::HandleSubtitleSegment()
{
    if (m_subtitleStatus.m_initFileReady)
    {
    }
    else
    {
        // DownloadInitFile_Subtitle();
    }
}

bool dashSegmentSelector::ReplaceSubstring(std::string& str, const std::string& from, const std::string& to)
{
    size_t start_pos = str.find(from);
    if(start_pos == std::string::npos)
        return false;
    str.replace(start_pos, from.length(), to);
    return true;
}

void dashSegmentSelector::ReplaceAllSubstring(std::string& str, const std::string& from, const std::string& to)
{
    if(from.empty())
        return;
    size_t start_pos = 0;
    while((start_pos = str.find(from, start_pos)) != std::string::npos)
    {
        str.replace(start_pos, from.length(), to);
        start_pos += to.length(); // In case 'to' contains 'from', like replacing 'x' with 'yx'
    }
}

uint32_t dashSegmentSelector::GetTargetDownloadSize_Video()
{
    uint32_t downloadSpeed = m_videoStatus.m_downloadSpeed;
    uint64_t downloadTime = m_videoStatus.m_downloadTime;
    uint64_t playTime = m_videoStatus.m_playTime;

    // calculate the current network condition
    uint64_t bufferTime = (downloadTime < playTime) ? 0 : downloadTime - playTime; // bufferTime MSec
    bufferTime /= 1000;
    double availableDownloadTime = bufferTime * 0.7 > 1 ? bufferTime * 0.7 : 1; // assume we can always wait for 1 second
    uint32_t availableDownloadSize = availableDownloadTime * downloadSpeed;

    LOGMSG_INFO("downloadSpeed: %u bufferTime: %lu availableDownloadTime: %f availableDownloadSize: %u", downloadSpeed, bufferTime, availableDownloadTime, availableDownloadSize);
    return availableDownloadSize;
}

downloadInfo dashSegmentSelector::GetDownloadInfo_Video(uint32_t targetDownloadSize)
{
    uint32_t selectedDownloadSize = 0;
    downloadInfo tempInfo; tempInfo.m_bandwidth = 0;
    downloadInfo lowestQualityInfo; lowestQualityInfo.m_bandwidth = 0xFFFFFFFF;
    std::vector<dash::mpd::IPeriod *> periods = m_mpdFile->GetPeriods();
    for (size_t i = 0; i < periods.size(); i++) // loop for every period
    {
        std::vector<dash::mpd::IAdaptationSet *> adaptationsSets = periods[i]->GetAdaptationSets();
        for (size_t j = 0; j < adaptationsSets.size(); j++) // loop for every adaptation set
        {
            dash::mpd::IAdaptationSet* adapPtr = adaptationsSets[j];
            std::string mimeType = adapPtr->GetMimeType();
            std::transform(mimeType.begin(), mimeType.end(), mimeType.begin(), ::tolower); // toupper
            if (mimeType.find("video") != std::string::npos) // found video representation
            {
                std::vector<dash::mpd::IRepresentation *> representations = adaptationsSets[j]->GetRepresentation();
                for (size_t k = 0; k < representations.size(); k++) // loop for every representation
                {
                    dash::mpd::IRepresentation* repPtr = representations[k];
                    dash::mpd::ISegmentTemplate* segmentTemplatePtr = adapPtr->GetSegmentTemplate();

                    if (segmentTemplatePtr)
                    {
                        uint32_t bandwidth = repPtr->GetBandwidth();
                        uint32_t segmentSize = bandwidth * static_cast<double>(segmentTemplatePtr->GetDuration()) / segmentTemplatePtr->GetTimescale();
                        if (selectedDownloadSize < segmentSize && segmentSize < targetDownloadSize) // if bandwidth is sutiable
                        {
                            selectedDownloadSize = segmentSize;
                            tempInfo.m_bandwidth = bandwidth;
                            tempInfo.m_baseURL = adapPtr->GetBaseURLs().size() ? adapPtr->GetBaseURLs()[0]->GetUrl() : std::string();
                            tempInfo.m_media = segmentTemplatePtr->Getmedia();
                            tempInfo.m_startNumber = segmentTemplatePtr->GetStartNumber();
                            tempInfo.m_timescale = segmentTemplatePtr->GetTimescale();
                            tempInfo.m_duration = segmentTemplatePtr->GetDuration();
                            tempInfo.m_initialization = segmentTemplatePtr->Getinitialization();
                            tempInfo.m_lang = "";
                            tempInfo.m_representationID = repPtr->GetId();
                        }
                        if (lowestQualityInfo.m_bandwidth > bandwidth)
                        {
                            lowestQualityInfo.m_bandwidth = bandwidth;
                            lowestQualityInfo.m_baseURL = adapPtr->GetBaseURLs().size() ? adapPtr->GetBaseURLs()[0]->GetUrl() : std::string();
                            lowestQualityInfo.m_media = segmentTemplatePtr->Getmedia();
                            lowestQualityInfo.m_startNumber = segmentTemplatePtr->GetStartNumber();
                            lowestQualityInfo.m_timescale = segmentTemplatePtr->GetTimescale();
                            lowestQualityInfo.m_duration = segmentTemplatePtr->GetDuration();
                            lowestQualityInfo.m_initialization = segmentTemplatePtr->Getinitialization();
                            lowestQualityInfo.m_lang = "";
                            lowestQualityInfo.m_representationID = repPtr->GetId();
                        }
                    }
                }
            }
        }
    }

    if (tempInfo.m_bandwidth == 0)
    {
        tempInfo = lowestQualityInfo;
    }
    LOGMSG_INFO("selected bandwidth: %u", tempInfo.m_bandwidth);

    return tempInfo;
}

std::string dashSegmentSelector::GetDownloadURL_Video(const downloadInfo& videoDownloadInfo, uint64_t& nextDownloadTime)
{
    if (m_videoStatus.m_downloadInfo.m_representationID != videoDownloadInfo.m_representationID)
    {
        m_videoStatus.m_downloadInfo = videoDownloadInfo;
        m_videoStatus.m_initFileReady = false;
    }

    if (m_videoStatus.m_initFileReady)
    {
        return GetSegmentURL_Video(videoDownloadInfo, nextDownloadTime);
    }
    else
    {
        nextDownloadTime = m_videoStatus.m_downloadTime;
        return GetInitFileURL_Video(videoDownloadInfo);
    }
}

std::string dashSegmentSelector::GetInitFileURL_Video(const downloadInfo& targetInfo)
{
    std::stringstream ss;
    dash::mpd::IBaseUrl* baseURL = m_mpdFile->GetMPDPathBaseUrl();
    ss << baseURL->GetUrl() << "/";

    ss << targetInfo.m_baseURL;
    if (targetInfo.m_initialization.find("$RepresentationID$") != std::string::npos)
    {
        std::string initStr = targetInfo.m_initialization;
        ReplaceAllSubstring(initStr, "$RepresentationID$", targetInfo.m_representationID);
        ss << initStr;

        return ss.str();
    }
    else
    {
        return std::string();
    }
}

std::string dashSegmentSelector::GetSegmentURL_Video(const downloadInfo& videoDownloadInfo, uint64_t& nextDownloadTime)
{
    std::stringstream ss;
    dash::mpd::IBaseUrl* baseURL = m_mpdFile->GetMPDPathBaseUrl();
    ss << baseURL->GetUrl() << "/";

    ss << videoDownloadInfo.m_baseURL;
    if (videoDownloadInfo.m_media.find("$RepresentationID$") != std::string::npos)
    {
        std::string mediaStr = videoDownloadInfo.m_media;
        ReplaceAllSubstring(mediaStr, "$RepresentationID$", videoDownloadInfo.m_representationID);

        size_t found = mediaStr.find("$Number");
        if (found != std::string::npos)
        {
            // get next segment number
            uint32_t nextSegment = m_videoStatus.m_downloadTime / GetSegmentDurationMSec(videoDownloadInfo);
            nextSegment++;
            if (videoDownloadInfo.m_startNumber > nextSegment)
                nextSegment = videoDownloadInfo.m_startNumber;
            // get next download time
            nextDownloadTime = nextSegment * GetSegmentDurationMSec(videoDownloadInfo);
            // get the string format
            size_t numberFormatStart = found + 7;
            size_t endDollar = mediaStr.find("$", numberFormatStart);
            std::string numberFormat = mediaStr.substr(numberFormatStart, endDollar - numberFormatStart);
            char numberStr[20];
            sprintf(numberStr, numberFormat.c_str(), nextSegment);
            // replace the string
            ReplaceAllSubstring(mediaStr, "$Number" + numberFormat + "$", numberStr);
            LOGMSG_DEBUG("sulfred debug %s numberFormat: %s numberStr: %s nextSegment: %u", mediaStr.c_str(), numberFormat.c_str(), numberStr, nextSegment);
        }
        else
        {
        }
        ss << mediaStr;

        return ss.str();
    }
    else
    {
        return std::string();
    }
}

uint32_t dashSegmentSelector::GetSegmentDurationMSec(const downloadInfo& videoDownloadInfo)
{
    return (static_cast<double>(videoDownloadInfo.m_duration) / videoDownloadInfo.m_timescale) * 1000;
}
