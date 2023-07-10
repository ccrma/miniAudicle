/*----------------------------------------------------------------------------
miniAudicle:
  integrated developement environment for ChucK audio programming language

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

//-----------------------------------------------------------------------------
// file: miniAudicle.h
// desc: platform-independent miniAudicle interface
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------
#ifndef __MINIAUDICLE_H__
#define __MINIAUDICLE_H__

#include "chuck_def.h"
#include "chuck_compile.h"
#include "chuck_type.h"
#include "util_thread.h"
#ifndef __CHIP_MODE__
#include "RtAudio/RtAudio.h"
#endif // __CHIP_MODE__

#include <map>
#include <string>
#include <vector>
#include <queue>

// forward reference
class ChucK;


struct miniAudicle_Code
{
    std::string code_text;
    std::string name;
    t_CKUINT shred_id;
    t_CKUINT shred_group_id;
    t_CKBOOL running;
    // void * syntax_highlighting;
};

struct miniAudicle_SyntaxHighlighting
{
    t_CKUINT length;
    t_CKBYTE r;
    t_CKBYTE g;
    t_CKBYTE b;
    miniAudicle_SyntaxHighlighting * next;
};

typedef t_CKUINT t_DOCID;

enum t_OTF_RESULT
{
    OTF_SUCCESS,
    OTF_MINI_ERROR,
    OTF_VM_ERROR,
    OTF_COMPILE_ERROR,
    OTF_VM_TIMEOUT,
    OTF_UNDEFINED
};


//-----------------------------------------------------------------------------
// name: class miniAudicle
// desc: primary interface to miniAudicle systems
//-----------------------------------------------------------------------------
class miniAudicle
{
public:
    miniAudicle();
    ~miniAudicle();
    
    t_OTF_RESULT run_code( std::string & code, std::string & name,
                           std::vector< std::string > & args, std::string & filepath,
                           t_CKUINT docid, t_CKUINT & shred_id, std::string & out );
    t_OTF_RESULT replace_code( std::string & code, std::string & name,
                               std::vector< std::string > & args, std::string & filepath,
                               t_CKUINT docid, t_CKUINT & shred_id, 
                               std::string & out );
    t_OTF_RESULT remove_code( t_CKUINT docid, t_CKUINT & shred_id, 
                              std::string & out );
    t_OTF_RESULT remove_shred( t_CKUINT docid, t_CKINT shred_id, std::string & out );
    t_OTF_RESULT removeall( t_CKUINT docid, std::string & out );
    t_OTF_RESULT removelast( t_CKUINT docid, std::string & out );
    t_OTF_RESULT clearvm( t_CKUINT docid, std::string & out );
    t_OTF_RESULT status( Chuck_VM_Status * status);
    t_OTF_RESULT handle_reply( t_CKUINT docid, std::string & out );
    
    t_CKINT abort_current_shred();
    
    struct _doc_otf_result { t_OTF_RESULT result; t_CKUINT shred_id; std::string output; t_CKINT line; };
    
    t_CKBOOL process_reply();
    t_CKBOOL get_last_result( t_CKUINT docid, t_OTF_RESULT * result,
                              std::string * out, t_CKINT * line_num  );
    t_CKBOOL get_last_result( t_CKUINT docid, _doc_otf_result * result  );
    
    t_CKUINT allocate_document_id();
    void free_document_id( t_CKUINT docid );
    
    t_CKUINT shred_count();

    t_CKBOOL start_vm();
    t_CKBOOL stop_vm();
    t_CKBOOL is_on();
    
    t_CKBOOL get_new_class_names( std::vector< std::string > & v);

    t_CKBOOL highlight_line( std::string & line,
                             miniAudicle_SyntaxHighlighting * sh );

    // probe audio devices | 1.5.0.1 (ge) added driver argument
    // driver names subject to underlying system availability
    // possible names include: "alsa", "pulse", "oss", "jack",
    // "coreaudio", "directsound", "asio", "wasapi"
    // see audio system (e.g., ChucKAudio.cpp) for more information
    t_CKBOOL probe( const char * driver );

    // get the ChucK instance | 1.5.0.6 (ge) added
    // ChucK * chuck() { return m_chuck; }

#ifndef __CHIP_MODE__
    const std::vector< RtAudio::DeviceInfo > & get_interfaces();
#endif // __CHIP_MODE__

    void set_log_level( t_CKINT n );
    t_CKINT get_log_level();
    t_CKBOOL set_num_inputs( t_CKUINT num );
    t_CKUINT get_num_inputs();
    t_CKBOOL set_num_outputs( t_CKUINT num );
    t_CKUINT get_num_outputs();
    t_CKBOOL set_enable_audio( t_CKBOOL en );
    t_CKBOOL get_enable_audio();
    t_CKBOOL set_enable_network_thread( t_CKBOOL en );
    t_CKBOOL get_enable_network_thread();
    t_CKBOOL set_dac( t_CKUINT dac );
    t_CKUINT get_dac();
    t_CKBOOL set_adc( t_CKUINT adc );
    t_CKUINT get_adc();
    t_CKBOOL set_sample_rate( t_CKUINT srate );
    t_CKUINT get_sample_rate();
    t_CKBOOL set_buffer_size( t_CKUINT size );
    t_CKUINT get_buffer_size();
    t_CKBOOL set_blocking( t_CKBOOL block );
    t_CKBOOL get_blocking();
    t_CKBOOL set_enable_std_system( t_CKBOOL enable );
    t_CKBOOL get_enable_std_system();
    t_CKBOOL set_library_paths( std::list< std::string > & paths );
    t_CKBOOL get_library_paths( std::list< std::string > & paths );
    t_CKBOOL set_named_chugins( std::list< std::string > & chugins );
    t_CKBOOL get_named_chugins( std::list< std::string > & chugins );
    t_CKBOOL add_query_func(t_CKBOOL (*func)(Chuck_Env *));
    // 1.5.0.1 (ge) added (see probe() above for more information)
    t_CKBOOL set_driver( const char * driver );
    // 1.5.0.6 (ge) set console column width, in # of characters
    // this helps chuck snippet code when a line of code is too long for the console
    void set_console_column_width_hint( t_CKUINT columnWidth );
    // set the console callback function
    void set_ck_console_callback(void (*callback)(const char *));

protected:
    std::map< t_CKUINT, std::vector< t_CKUINT > * > documents; // maps documents to shreds

    struct _doc_shred { t_CKUINT docid; std::vector< t_CKUINT >::size_type index; };
    std::map< t_CKUINT, _doc_shred > shreds;
    // maps shreds to documents and an index in the document's corresponding shred vector
    // i.e. documents[shreds[shred_id].docid]->at( shreds[shred_id].index ) == shred_id
    
    std::map< t_CKUINT, _doc_otf_result > last_result; // last error string for a given docid
    std::queue< t_CKUINT > otf_docids; // FIFO of docids that correspond to pending OTF message replys
    t_CKUINT vm_sleep_time; // length of time (microseconds) to sleep-wait for a vm reply
    t_CKUINT vm_sleep_max; // max number of times to sleep-wait for a vm reply
    
    t_CKUINT vm_status_timeouts;
    t_CKUINT vm_status_timeouts_max;
    
    t_CKUINT next_document_id;
    
    t_CKBOOL vm_on;
    
    CHUCK_THREAD vm_tid;
    CHUCK_THREAD otf_tid;
    
    ChucK * m_chuck;
    Chuck_VM * vm;
    Chuck_Compiler * compiler;
    
    Chuck_VM_Status ** status_bufs;
    size_t num_status_bufs;
    size_t status_bufs_read, status_bufs_write;
    
#ifndef __CHIP_MODE__
    std::vector< RtAudio::DeviceInfo > interfaces;
    std::vector< RtAudio::DeviceInfo >::size_type default_input;
    std::vector< RtAudio::DeviceInfo >::size_type default_output;
#endif // __CHIP_MODE__

    void (*m_console_callback)(const char *);
    
    std::map< std::string, t_CKINT > * class_names;

    struct _vm_options
    {
        t_CKUINT dac;
        t_CKUINT adc;
        t_CKUINT srate;
        t_CKUINT num_inputs;
        t_CKUINT num_outputs;
        t_CKUINT buffer_size;
        t_CKUINT num_buffers;
        t_CKBOOL enable_audio;
        t_CKBOOL enable_network;
        t_CKBOOL enable_block;
        t_CKBOOL force_srate;
        std::string driver;
        std::list< std::string > library_paths;
        std::list< std::string > named_chugins;
        std::list< t_CKBOOL (*)(Chuck_Env *) > query_funcs;
    } vm_options;
};


// quickly determine if the two vectors are equal
inline int compare_shred_vectors( const std::vector< Chuck_VM_Shred_Status * > & a,
                                  const std::vector< Chuck_VM_Shred_Status * > & b )
{
    std::vector< Chuck_VM_Shred_Status * >::size_type i,
    lenA = a.size(), lenB = b.size();
    
    if( lenA != lenB )
        return 1;
    
    if( lenA == 0 )
        return 0;
    
    Chuck_VM_Shred_Status * cvmssA, * cvmssB;
    
    for( i = 0; i < lenA; i++ )
    {
        cvmssA = a[i];
        cvmssB = b[i];
        
        if( cvmssA->xid != cvmssB->xid ||
           cvmssA->start != cvmssB->start )
        /* a shred is uniquely defined by ( shred id, start time ) */
        {
            return 1;
        }
    }
    
    return 0;
}


#endif // __MINIAUDICLE__H__
