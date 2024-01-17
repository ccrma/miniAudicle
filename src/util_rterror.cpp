//
//  util_rterror.cpp
//  chuck
//
//  Created by Spencer Salazar on 4/16/23.
//

#include "util_rterror.h"
#include "chuck_errmsg.h"

static RtAudioErrorType g_lastRtAudioErrorType = RTAUDIO_NO_ERROR;
static std::string g_lastRtAudioErrorText;

void rtaudio_error(RtAudioErrorType type, const std::string &errorText)
{
    g_lastRtAudioErrorType = type;
    g_lastRtAudioErrorText = errorText;
}

void rtaudio_error_clear()
{
    g_lastRtAudioErrorType = RTAUDIO_NO_ERROR;
    g_lastRtAudioErrorText = "";
}

bool rtaudio_has_error()
{
    return g_lastRtAudioErrorType != RTAUDIO_NO_ERROR;
}

void rtaudio_error_print(bool clearError)
{
    EM_log(CK_LOG_HERALD, "RtAudio: error: %s", g_lastRtAudioErrorText.c_str());
    
    if (clearError) rtaudio_error_clear();
}

