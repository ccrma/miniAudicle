//
//  util_rterror.h
//  chuck
//
//  Created by Spencer Salazar on 4/16/23.
//

#pragma once

#include <string>
#include "RtAudio.h"

void rtaudio_error(RtAudioErrorType type, const std::string &errorText);
void rtaudio_error_clear();
bool rtaudio_has_error();
void rtaudio_error_print(bool clearError);

