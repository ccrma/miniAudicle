/*----------------------------------------------------------------------------
miniAudicle
Cocoa GUI to chuck audio programming environment

Copyright (c) 2005 Spencer Salazar.  All rights reserved.
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
// file: miniaudicle.h
// desc: ...
//
// author: Spencer Salazar (ssalazar@princeton.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#ifndef __MINIAUDICLE_H__
#define __MINIAUDICLE_H__

#include "chuck_compile.h"
#include "util_thread.h"
#ifndef __CHIP_MODE__
#include "RtAudio/RtAudio.h"
#endif // __CHIP_MODE__

#include <map>
#include <string>
#include <vector>
#include <queue>

using namespace std;

struct miniAudicle_Code
{
    string code_text;
    string name;
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

class miniAudicle
{
public:
    miniAudicle();
    ~miniAudicle();
    
    t_OTF_RESULT run_code( string & code, string & name, 
                           vector< string > & args, t_CKUINT docid, 
                           t_CKUINT & shred_id, string & out );
    t_OTF_RESULT replace_code( string & code, string & name, 
                               vector< string > & args, t_CKUINT docid, 
                               t_CKUINT & shred_id, string & out );
    t_OTF_RESULT remove_code( t_CKUINT docid, t_CKUINT & shred_id, 
                              string & out );
    t_OTF_RESULT remove_shred( t_CKUINT docid, t_CKINT shred_id, string & out );
    t_OTF_RESULT removeall( t_CKUINT docid, string & out );
    t_OTF_RESULT removelast( t_CKUINT docid, string & out );
    t_OTF_RESULT status( Chuck_VM_Status * status);
    t_OTF_RESULT handle_reply( t_CKUINT docid, string & out );
    
    t_CKINT abort_current_shred();
    
    t_CKBOOL process_reply();
    t_CKBOOL get_last_result( t_CKUINT docid, t_OTF_RESULT * result, 
                              string * out, int * line_num  );
    
    t_CKUINT allocate_document_id();
    void free_document_id( t_CKUINT docid );
    
    t_CKUINT shred_count();

    t_CKBOOL start_vm();
    t_CKBOOL stop_vm();
    t_CKBOOL is_on();
    
    t_CKBOOL get_new_class_names( vector< string > & v);

    t_CKBOOL highlight_line( string & line, 
                             miniAudicle_SyntaxHighlighting * sh );

    t_CKBOOL probe();
#ifndef __CHIP_MODE__
    const vector< RtAudio::DeviceInfo > & get_interfaces();
#endif // __CHIP_MODE__

    int get_log_level();
    t_CKBOOL set_log_level( int l );
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
    t_CKBOOL set_library_paths( list< string > & paths );
    t_CKBOOL get_library_paths( list< string > & paths );
    t_CKBOOL set_named_chugins( list< string > & chugins );
    t_CKBOOL get_named_chugins( list< string > & chugins );
    
protected:
    map< t_CKUINT, vector< t_CKUINT > * > documents; // maps documents to shreds

    struct _doc_shred { t_CKUINT docid; vector< t_CKUINT >::size_type index; };
    map< t_CKUINT, _doc_shred > shreds; 
    // maps shreds to documents and an index in the document's corresponding shred vector
    // i.e. documents[shreds[shred_id].docid]->at( shreds[shred_id].index ) == shred_id
    
    struct _doc_otf_result { t_OTF_RESULT result; string output; int line; };
    map< t_CKUINT, _doc_otf_result > last_result; // last error string for a given docid
    queue< t_CKUINT > otf_docids; // FIFO of docids that correspond to pending OTF message replys
    t_CKUINT vm_sleep_time; // length of time (microseconds) to sleep-wait for a vm reply
    t_CKUINT vm_sleep_max; // max number of times to sleep-wait for a vm reply
    
    t_CKUINT vm_status_timeouts;
    t_CKUINT vm_status_timeouts_max;
    
    t_CKUINT next_document_id;
    
    t_CKBOOL vm_on;
    
    CHUCK_THREAD vm_tid;
    CHUCK_THREAD otf_tid;
    
    Chuck_VM * vm;
    Chuck_Compiler * compiler;
    
    Chuck_VM_Status ** status_bufs;
    size_t num_status_bufs;
    size_t status_bufs_read, status_bufs_write;
    
#ifndef __CHIP_MODE__
    vector< RtAudio::DeviceInfo > interfaces;
    vector< RtAudio::DeviceInfo >::size_type default_input;
    vector< RtAudio::DeviceInfo >::size_type default_output;
#endif // __CHIP_MODE__
    
    map< string, t_CKINT > * class_names;

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
        list< string > library_paths;
        list< string > named_chugins;
    } vm_options;
};

#endif // __MINIAUDICLE__H__


