/*----------------------------------------------------------------------------
miniAudicle
GUI to chuck audio programming environment

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
// file: mAVMMonitor.cpp
// desc: Virtual Machine monitor
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#include "chuck_def.h"

#include "wx/wx.h"
#include "wx/config.h"
#include "wx/sizer.h"

#include "mAParentFrame.h"
#include "mAVMMonitor.h"
#include "mAEvents.h"

#include "miniAudicle.h"

#include <cmath>

#ifdef __LINUX__
mAVMMonitor::mAVMMonitor( miniAudicle * ma, wxWindow * parent, 
    wxWindowID id, const wxString & title, const wxPoint & pos,
    const wxSize & size, long style )
    : wxFrame( parent, id, title, pos, size, style ) 
#else
mAVMMonitor::mAVMMonitor( miniAudicle * ma, wxMDIParentFrame * parent, 
    wxWindowID id, const wxString & title, const wxPoint & pos,
    const wxSize & size, long style )
    : wxMDIChildFrame( parent, id, title, pos, size, style ) 
#endif /* __LINUX__ */
{
    this->ma = ma;
    docid = ma->allocate_document_id();

#ifdef __WINDOWS_DS__
    /* the default background is white, which looks bad */
    SetOwnBackgroundColour( wxSystemSettings::GetColour( wxSYS_COLOUR_BTNFACE ) );
#endif

#ifdef __LINUX__
    /* defaults for GTK-version floating VM monitor */
    Maximize( false );
    SetSize( wxSize( 270, 350 ) );
    SetMinSize( wxSize( 270, 312 ) );
    SetPosition( wxPoint( 976, 260 ) );
#endif

    refresh_rate = 10;
    vm_stall_count = 0;
    vm_max_stalls = 1 * refresh_rate;

    wxBoxSizer * sizer = new wxBoxSizer( wxVERTICAL );

    time_counter = new wxStaticText( this, wxID_ANY, _T( "running time: " ),
        wxDefaultPosition, wxDefaultSize, wxALIGN_LEFT );
    sizer->Add( time_counter, 0, wxALL | wxALIGN_LEFT, 10 );

    shred_count = new wxStaticText( this, wxID_ANY, _T( "shreds: " ),
        wxDefaultPosition, wxDefaultSize, wxALIGN_LEFT );
    sizer->Add( shred_count, 0, wxLEFT | wxRIGHT | wxALIGN_LEFT, 10 );

    grid = new wxGrid( this, wxID_ANY, wxDefaultPosition, 
        wxSize( 250, 300 ), wxSUNKEN_BORDER );
    sizer->Add( grid, 2, wxALL | wxALIGN_CENTER | wxEXPAND, 10 );

    vm_start = new wxButton( this, mAID_TOGGLE_VM, _T( "Start Virtual Machine" ) );
    sizer->Add( vm_start, 0, wxBOTTOM | wxALIGN_CENTER, 10 );

    grid->CreateGrid( 0, 4 );

    grid->SetRowLabelSize( 0 );
    grid->SetColLabelSize( 20 );
    grid->SetMinSize( wxSize( 250, 200 ) );

    grid->SetColLabelValue( 0, _T( "shred" ) );
    grid->SetColSize( 0, 38 );
    wxGridCellAttr * gca = new wxGridCellAttr();
    gca->SetReadOnly( true );
    gca->SetAlignment( wxALIGN_RIGHT, wxALIGN_BOTTOM );
    grid->SetColAttr( 0, gca );
    
    grid->SetColLabelValue( 1, _T( "name" ) );
#ifdef __LINUX__
    grid->SetColSize( 1, 134 );
#else
    grid->SetColSize( 1, 114 );
#endif /* __LINUX__ */

    gca = new wxGridCellAttr();
    gca->SetReadOnly( true );
    gca->SetAlignment( wxALIGN_LEFT, wxALIGN_BOTTOM );
    grid->SetColAttr( 1, gca );

    grid->SetColLabelValue( 2, _T( "time" ) );
    grid->SetColSize( 2, 38 );
    gca = new wxGridCellAttr();
    gca->SetReadOnly( true );
    gca->SetAlignment( wxALIGN_RIGHT, wxALIGN_BOTTOM );
    grid->SetColAttr( 2, gca );

    grid->SetColLabelValue( 3, _T( "-" ) );
    grid->SetColSize( 3, 20 );
    gca = new wxGridCellAttr();
    gca->SetReadOnly( true );
    gca->SetAlignment( wxALIGN_CENTRE, wxALIGN_CENTRE );
    grid->SetColAttr( 3, gca );
    
    timer = new wxTimer( this, mAID_VMM_TIMER );
    Connect( mAID_VMM_TIMER, wxEVT_TIMER, 
        wxTimerEventHandler( mAVMMonitor::OnTimer ) );

    Connect( wxID_ANY, wxEVT_GRID_CELL_LEFT_CLICK,
        wxGridEventHandler( mAVMMonitor::OnGridClick ) );

    Connect( wxID_ANY, wxEVT_GRID_CELL_LEFT_DCLICK,
        wxGridEventHandler( mAVMMonitor::OnGridClick ) );

    Connect( wxEVT_SIZE, wxSizeEventHandler( mAVMMonitor::OnResize ) );

    Connect( wxEVT_CLOSE_WINDOW, wxCloseEventHandler( mAVMMonitor::OnClose ) );

    SetTitle( _T( "Virtual Machine" ) );
    SetSizer( sizer );

    Show( true );
}

mAVMMonitor::~mAVMMonitor()
{
    ma->free_document_id( docid );
    
    wxConfigBase * config = wxConfigBase::Get();

    int x, y;

    config->Write( _T( "/GUI/VMMonitor/maximize" ), IsMaximized() );

    if( !IsMaximized() )
    {
        GetSize( &x, &y );
        config->Write( _T( "/GUI/VMMonitor/width" ), x );
        config->Write( _T( "/GUI/VMMonitor/height" ), y );

        GetPosition( &x, &y );
        config->Write( _T( "/GUI/VMMonitor/x" ), x );
        config->Write( _T( "/GUI/VMMonitor/y" ), y );
    }

    Disconnect( wxEVT_TIMER );
    Disconnect( wxEVT_SIZE );
    Disconnect( wxEVT_GRID_CELL_LEFT_CLICK );
    Disconnect( wxEVT_GRID_CELL_LEFT_DCLICK );

    SAFE_DELETE( timer );
    SAFE_DELETE( grid );
    SAFE_DELETE( vm_start );
    SAFE_DELETE( shred_count );
    SAFE_DELETE( time_counter );
}

void mAVMMonitor::OnVMStart()
{
    wxConfigBase * config = wxConfigBase::Get();

    vm_stall_count = 0;
    vm_max_stalls = ( int ) ( config->Read( mAPreferencesVMStallTimeout, 3.0 ) * refresh_rate ); 

    timer->Start( 1000 / refresh_rate );
    vm_start->SetLabel( _T( "Stop Virtual Machine" ) );

#ifdef __WINDOWS_DS__
    vm_start->Enable( false );
#endif
}

void mAVMMonitor::OnVMStop()
{
    timer->Stop();
    vm_start->SetLabel( _T( "Start Virtual Machine" ) );
    shred_count->SetLabel( _T( "shreds:" ) );
    time_counter->SetLabel( _T( "running time:" ) );
}

void mAVMMonitor::OnTimer( wxTimerEvent & event )
{
    static time_t last_now = 0 - 1;
    static t_CKTIME last_now_system = 0;
    static int last_num_shreds = -1;

    ma->status( &status );
    wxString temp;
    time_t age, now;
    int num_rows = grid->GetNumberRows();
    int num_shreds = status.list.size();

    if( /*status.now_system > status.srate &&*/( status.now_system - last_now_system ) < 0.5 )
    {
        vm_stall_count++;

        if( vm_stall_count >= vm_max_stalls && !wxGetApp().IsInLockdown() )
        {
            wxGetApp().SetLockdown( TRUE );
        }
    }

    else
    {
        if( wxGetApp().IsInLockdown() )
            wxGetApp().SetLockdown( FALSE );
        vm_stall_count = 0;
    }

    last_now_system = status.now_system;

    while( num_rows < num_shreds )
    {
        num_rows++;
        grid->InsertRows();
    }

    while( num_rows > num_shreds )
    {
        num_rows--;
        grid->DeleteRows();
    }

    now = ( time_t ) ( status.now_system / status.srate );
    if( now != last_now )
    {
        time_counter->SetLabel( wxString::Format( _T( "running time: %u:%02u" ),
                                                  now / 60, now % 60 ) );
        last_now = now;
    }

    if( num_shreds != last_num_shreds )
    {
        shred_count->SetLabel( wxString::Format( _T( "shreds: %u"), num_shreds ) );
        last_num_shreds = num_shreds;
    }

    for( int i = 0; i < num_shreds; i++ )
    {
        temp = wxString::Format( _T( "%u" ), status.list[i]->xid );
        grid->SetCellValue( i, 0, temp );
        //wxString shred_name( status.list[i]->name.c_str(), wxConvUTF8 );
        grid->SetCellValue( i, 1, 
            wxString( status.list[i]->name.c_str(), wxConvUTF8 ) );

        age = ( time_t ) ( ( status.now_system - status.list[i]->start ) / status.srate );
        temp = wxString::Format( _T( "%u:%02u" ), age / 60, age % 60 );
        grid->SetCellValue( i, 2, temp );

        grid->SetCellValue( i, 3, _T( "-" ) );
    }

    grid->ClearSelection();
    grid->Refresh();
}

void mAVMMonitor::OnGridClick( wxGridEvent & event )
{
    if( event.GetCol() == 3 )
    {
        std::vector< Chuck_VM_Shred * >::size_type n = event.GetRow();
        if( n <= status.list.size() )
        {
            string result;
            ma->remove_shred( docid, status.list[event.GetRow()]->xid, result );
        }
    }
}

void mAVMMonitor::OnResize( wxSizeEvent & event )
{
#ifdef __LINUX__
    
#endif /* __LINUX__ */

    event.Skip();
}

void mAVMMonitor::OnClose( wxCloseEvent & event )
{
    if( event.CanVeto() )
    {
        event.Veto();
        Hide();
    }
    else
        Destroy();
}




