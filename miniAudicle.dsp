# Microsoft Developer Studio Project File - Name="miniAudicle" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=miniAudicle - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "miniAudicle.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "miniAudicle.mak" CFG="miniAudicle - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "miniAudicle - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "miniAudicle - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "miniAudicle - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GR /GX /O2 /I ".\\" /I "wxw\\" /I "..\..\chuck_dev\v2" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "__WINDOWS_DS__" /D "__PLATFORM_WIN32__" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 wxmsw26_adv.lib wxmsw26_stc.lib wxmsw26_core.lib wxbase26.lib wxtiff.lib wxjpeg.lib wxpng.lib wxzlib.lib comctl32.lib rpcrt4.lib wsock32.lib oleacc.lib dinput.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dsound.lib dxguid.lib wsock32.lib winmm.lib /nologo /subsystem:windows /machine:I386

!ELSEIF  "$(CFG)" == "miniAudicle - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GR /GX /ZI /Od /I ".\\" /I "wxw\\" /I "..\..\chuck_dev\v2" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "__WINDOWS_DS__" /D "__PLATFORM_WIN32__" /FR /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 wxmsw26d_adv.lib wxmsw26d_stc.lib wxmsw26d_core.lib wxbase26d.lib wxtiff.lib wxjpeg.lib wxpng.lib wxzlib.lib comctl32.lib rpcrt4.lib wsock32.lib oleacc.lib dinput.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dsound.lib dxguid.lib wsock32.lib winmm.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "miniAudicle - Win32 Release"
# Name "miniAudicle - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "ChucK Source"

# PROP Default_Filter "cpp c"
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_absyn.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_bbq.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_compile.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_console.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_dl.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_emit.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_errmsg.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_frame.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_globals.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_instr.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_lang.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_oo.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_otf.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_parse.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_scan.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_shell.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_stats.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_symbol.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_table.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_type.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_ugen.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_utils.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_vm.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_win32.c
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\digiio_rtaudio.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\hidio_sdl.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\midiio_rtmidi.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\rtaudio.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\rtmidi.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\uana_extract.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\uana_xform.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_filter.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_osc.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_stk.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_xxx.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_machine.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_math.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_opsc.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_std.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_buffers.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_console.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_hid.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_math.c
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_network.c
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_opsc.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_raw.c
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_sndfile.c
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_string.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_thread.cpp
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_xforms.c
# End Source File
# End Group
# Begin Source File

SOURCE=.\wxw\mAConfig.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mAConsoleMonitor.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mADocument.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mAMenuBar.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mAParentFrame.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mAPreferencesWindow.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mAUIElements.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mAView.cpp
# End Source File
# Begin Source File

SOURCE=.\wxw\mAVMMonitor.cpp
# End Source File
# Begin Source File

SOURCE=.\miniAudicle.cpp
# End Source File
# Begin Source File

SOURCE=.\miniAudicle_import.cpp
# End Source File
# Begin Source File

SOURCE=.\miniAudicle_ui_elements.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Group "ChucK Headers"

# PROP Default_Filter "h"
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck.tab.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_absyn.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_bbq.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_compile.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_console.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_def.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_dl.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_emit.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_errmsg.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_frame.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_globals.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_instr.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_lang.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_oo.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_otf.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_parse.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_scan.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_shell.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_stats.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_symbol.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_table.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_type.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_ugen.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_utils.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_vm.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\chuck_win32.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\digiio_rtaudio.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\hidio_sdl.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\midiio_alsa.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\midiio_oss.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\midiio_osx.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\midiio_rtmidi.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\midiio_win32.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\rtaudio.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\rterror.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\rtmidi.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\skini.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\skiniio_skini.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\uana_extract.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\uana_xform.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_filter.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_osc.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_stk.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ugen_xxx.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_machine.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_math.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_net.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_opsc.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\ulib_std.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_buffers.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_console.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_hid.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_math.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_network.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_opsc.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_raw.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_sndfile.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_string.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_thread.h
# End Source File
# Begin Source File

SOURCE=..\..\chuck_dev\v2\util_xforms.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\wxw\mAConfig.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mAConsoleMonitor.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mADocument.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mAEvents.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mAMenuBar.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mAParentFrame.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mAPreferencesWindow.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mAView.h
# End Source File
# Begin Source File

SOURCE=.\wxw\mAVMMonitor.h
# End Source File
# Begin Source File

SOURCE=.\miniAudicle.h
# End Source File
# Begin Source File

SOURCE=.\miniAudicle_import.h
# End Source File
# Begin Source File

SOURCE=.\miniAudicle_ui_elements.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\wxw\icons\miniAudicle.rc
# End Source File
# End Group
# End Target
# End Project
