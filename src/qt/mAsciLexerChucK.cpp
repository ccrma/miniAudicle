/*----------------------------------------------------------------------------
miniAudicle
GUI to ChucK audio programming environment

Copyright (c) 2005-2013 Spencer Salazar.  All rights reserved.
http://chuck.cs.princeton.edu/
http://soundlab.cs.princeton.edu/

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
U.S.A.
-----------------------------------------------------------------------------*/

#include "mAsciLexerChucK.h"
#include "mAPreferencesWindow.h"

#include "ZSettings.h"

mAsciLexerChucK::mAsciLexerChucK() : QsciLexerJava()
{
    preferencesChanged();
}

void mAsciLexerChucK::preferencesChanged()
{
    ZSettings settings;
        
    setPaper(QColor(settings.get(mAPreferencesSyntaxColoringBackground).toUInt()));    
    setColor(QColor(settings.get(mAPreferencesSyntaxColoringNormalText).toUInt()));
    
    if(settings.get(mAPreferencesSyntaxColoringEnabled).toBool())
    {
        setColor(QColor(settings.get(mAPreferencesSyntaxColoringKeywords).toUInt()), QsciLexerCPP::Keyword);
        setColor(QColor(settings.get(mAPreferencesSyntaxColoringClasses).toUInt()), QsciLexerCPP::KeywordSet2);
        setColor(QColor(settings.get(mAPreferencesSyntaxColoringUGens).toUInt()), QsciLexerCPP::GlobalClass);
        setColor(QColor(settings.get(mAPreferencesSyntaxColoringComments).toUInt()), QsciLexerCPP::Comment);
        setColor(QColor(settings.get(mAPreferencesSyntaxColoringComments).toUInt()), QsciLexerCPP::CommentLine);
        setColor(QColor(settings.get(mAPreferencesSyntaxColoringStrings).toUInt()), QsciLexerCPP::DoubleQuotedString);
        setColor(QColor(settings.get(mAPreferencesSyntaxColoringNumbers).toUInt()), QsciLexerCPP::Number);
    }
    
    setFont(QFont(settings.get(mAPreferencesFontName).toString(), 
                  settings.get(mAPreferencesFontSize).toInt()));
}


const char *mAsciLexerChucK::keywords(int set) const
{
    if(set == 1)
        return "int float time dur polar complex vec3 vec4 void same if else while do "
               "until for break continue return switch repeat "
               "class extends public static pure this "
               "super interface implements protected global auto "
               "private function fun spork const new now "
               "true false maybe null NULL me pi samp ms "
               "second minute hour day week dac adc blackhole chout cherr "
               "@operator @import @construct @destruct @doc";
    if(set == 2) // class names
        return "Object "
                "string "
                "UAnaBlob "
                "Shred "
                "Thread "
                "Class "
                "Event "
                "IO "
                "FileIO "
                "SerialIO "
                "StdOut "
                "StdErr "
                "Windowing "
                "Machine "
                "Std "
                "KBHit "
                "ConsoleInput "
                "StringTokenizer "
                "RegEx "
                "Math "
                "OscSend "
                "OscEvent "
                "OscRecv "
                "MidiMsg "
                "MidiIn "
                "MidiOut "
                "MidiRW "
                "MidiMsgIn "
                "MidiMsgOut "
                "MidiFileIn "
                "HidMsg "
                "Hid ";

    if(set == 4) // ugens
        return "UGen "
                "UAna "
                "Osc "
                "Phasor "
                "SinOsc "
                "TriOsc "
                "SawOsc "
                "PulseOsc "
                "SqrOsc "
                "GenX "
                "Gen5 "
                "Gen7 "
                "Pan2 "
                "Gen9 "
                "Gen10 "
                "Gen17 "
                "CurveTable "
                "WarpTable "
                "Chubgraph "
                "Chugen "
                "UGen_Stereo "
                "UGen_Multi "
                "DAC "
                "ADC "
                "Mix2 "
                "Gain "
                "Noise "
                "CNoise "
                "Impulse "
                "Step "
                "HalfRect "
                "FullRect "
                "DelayP "
                "SndBuf "
                "SndBuf2 "
                "Dyno "
                "LiSa "
                "FilterBasic "
                "BPF "
                "BRF "
                "LPF "
                "HPF "
                "ResonZ "
                "BiQuad "
                "Teabox "
                "StkInstrument "
                "BandedWG "
                "BlowBotl "
                "BlowHole "
                "Bowed "
                "Brass "
                "Clarinet "
                "Flute "
                "Mandolin "
                "ModalBar "
                "Moog "
                "Saxofony "
                "Shakers "
                "Sitar "
                "StifKarp "
                "VoicForm "
                "FM "
                "BeeThree "
                "FMVoices "
                "HevyMetl "
                "PercFlut "
                "Rhodey "
                "TubeBell "
                "Wurley "
                "Delay "
                "DelayA "
                "DelayL "
                "Echo "
                "Envelope "
                "ADSR "
                "FilterStk "
                "OnePole "
                "TwoPole "
                "OneZero "
                "TwoZero "
                "PoleZero "
                "JCRev "
                "NRev "
                "PRCRev "
                "Chorus "
                "Modulate "
                "PitShift "
                "SubNoise "
                "WvIn "
                "WaveLoop "
                "WvOut "
                "WvOut2 "
                "BLT "
                "BlitSquare "
                "Blit "
                "BlitSaw "
                "JetTabl "
                "Mesh2D "
                "FFT "
                "IFFT "
                "Flip "
                "pilF "
                "DCT "
                "IDCT "
                "FeatureCollector "
                "Centroid "
                "Flux "
                "MFCC "
                "RMS "
                "RollOff "
                "AutoCorr "
                "XCorr "
                "ZeroX ";


    return 0;
}
