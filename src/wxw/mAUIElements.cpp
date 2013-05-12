/*----------------------------------------------------------------------------
miniAudicle
GUI to chuck audio programming environment

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
// file: mAUIElements.cpp
// desc: for supporting UI controls created and used in ChucK code
//       wxWidgets specific code
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

//#define __TRACE__

#include "mAUIElements.h"
#include "mAParentFrame.h"
#include "miniAudicle_ui_elements.h"

#include "wx/wx.h"
#include "wx/event.h"
#include "wx/window.h"

#include "wx/slider.h"
#include "wx/button.h"
#include "wx/tglbtn.h"

#include "icons/led-off.xpm"
#include "icons/led-red.xpm"
#include "icons/led-green.xpm"
#include "icons/led-blue.xpm"

#include "miniAudicle_debug.h"

using namespace std;

//namespace miniAudicle
//{
namespace UI
{

DECLARE_EVENT_TYPE( mAEVT_UI_INIT, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_INIT )
DECLARE_EVENT_TYPE( mAEVT_UI_DISPLAY, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_DISPLAY )
DECLARE_EVENT_TYPE( mAEVT_UI_HIDE, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_HIDE )
DECLARE_EVENT_TYPE( mAEVT_UI_DESTROY, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_DESTROY )
DECLARE_EVENT_TYPE( mAEVT_UI_SIZE, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_SIZE )
DECLARE_EVENT_TYPE( mAEVT_UI_POSITION, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_POSITION )
DECLARE_EVENT_TYPE( mAEVT_UI_NAME, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_NAME )
DECLARE_EVENT_TYPE( mAEVT_UI_SETPARENT, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_SETPARENT )

class mAUIElement : public wxEvtHandler
{
public:
    mAUIElement() : wxEvtHandler()
    {
        trace_location();
        master_view = NULL;
        owner = NULL;

        Connect( mAEVT_UI_INIT, wxCommandEventHandler( mAUIElement::Init ) );
        Connect( mAEVT_UI_DISPLAY, wxCommandEventHandler( mAUIElement::Display ) );
        Connect( mAEVT_UI_HIDE, wxCommandEventHandler( mAUIElement::Hide ) );
        Connect( mAEVT_UI_DESTROY, wxCommandEventHandler( mAUIElement::Destroy ) );
        Connect( mAEVT_UI_SIZE, wxCommandEventHandler( mAUIElement::SetSize ) );
        Connect( mAEVT_UI_POSITION, wxCommandEventHandler( mAUIElement::SetPosition ) );
        Connect( mAEVT_UI_NAME, wxCommandEventHandler( mAUIElement::SetName ) );
        Connect( mAEVT_UI_SETPARENT, wxCommandEventHandler( mAUIElement::SetParent ) );
    }
    
    virtual void Link( Element * e )
    {
        owner = e;
    }

    virtual void Init( wxCommandEvent & event )
    {
        trace_location();
    }

    virtual void Display( wxCommandEvent & event )
    {
        trace_location();
        if( master_view )
        {
            master_view->Show();
            if( master_view->IsTopLevel() )
                master_view->Raise();
        }
    }

    virtual void Hide( wxCommandEvent & event )
    {
        if( master_view )
            master_view->Hide();
    }

    virtual void Destroy( wxCommandEvent & event )
    {
        owner = NULL;
        
        if( master_view )
        {
            master_view->Hide();
            master_view->Destroy();
            master_view = NULL;
        }
        
        Disconnect();
        
        delete this;
// TODO: set up an event that this function can post so that the mAApp will delete this
    }

    virtual void SetSize( wxCommandEvent & event )
    {
        if( master_view )
            master_view->SetClientSize( ( int ) owner->get_width(), ( int ) owner->get_height() );
    }

    virtual void SetPosition( wxCommandEvent & event )
    {
        if( master_view )
        {
            int x = ( int ) owner->get_x(), y = ( int ) owner->get_y();
            master_view->Move( x, y );
            if( x == -1 )
            {
                if( y == -1 )
                    master_view->Center( wxHORIZONTAL | wxVERTICAL );
                else
                    master_view->Center( wxHORIZONTAL );
            }
            else if( y == -1 )
                master_view->Center( wxVERTICAL );
        }
    }

    virtual void SetName( wxCommandEvent & event )
    {
        if( master_view )
            master_view->SetLabel( wxString( owner->get_name().c_str(), wxConvUTF8 ) );
    }

    virtual void SetParent( wxCommandEvent & event ) = 0;
    virtual void RemoveParent( wxCommandEvent & event ) = 0;

protected:
    Element * owner;
    wxWindow * master_view;
};

t_CKBOOL Element::display()
{
    pi_display();
    
    wxCommandEvent event( mAEVT_UI_DISPLAY );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL Element::hide()
{
    pi_hide();
    
    wxCommandEvent event( mAEVT_UI_HIDE);
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL Element::destroy()
{
    pi_destroy();
    
    wxCommandEvent event( mAEVT_UI_DESTROY );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL Element::set_name( string & name )
{    
    pi_set_name( name );
    
    wxCommandEvent event( mAEVT_UI_NAME );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL Element::set_parent( View * p )
{
    pi_set_parent( p );
    
    wxCommandEvent event( mAEVT_UI_SETPARENT );
    event.SetClientData( p->native_view );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL Element::remove_parent( View * p )
{
    pi_remove_parent( p );
    
    return TRUE;
}

t_CKBOOL Element::set_size( t_CKFLOAT w, t_CKFLOAT h )
{
    pi_set_size( w, h );
    
    wxCommandEvent event( mAEVT_UI_SIZE );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL Element::set_position( t_CKFLOAT x, t_CKFLOAT y )
{
    pi_set_position( x, y );
    
    wxCommandEvent event( mAEVT_UI_POSITION );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

class mAUIView : public mAUIElement
{
public:
    mAUIView() : mAUIElement()
    {
        trace_location();
        frame = NULL;
    }

    virtual void Init( wxCommandEvent & event )
    {
        trace_location();
        frame = wxGetApp().CreateChildFrame();
        master_view = frame;
#ifdef __WINDOWS_DS__
        /* the default background is white, which looks bad */
        frame->SetOwnBackgroundColour( wxSystemSettings::GetColour( wxSYS_COLOUR_BTNFACE ) );
#endif
        frame->Hide();
        
        content = new wxWindow( frame, wxID_ANY );
        
        SetSize( event );
        SetPosition( event );
        SetName( event );

        frame->PushEventHandler( this );
        Connect( wxEVT_CLOSE_WINDOW, wxCloseEventHandler( mAUIView::OnCloseFrame ) );
    }

    virtual void Display( wxCommandEvent & event )
    {
        trace_location();
        if( frame )
        {
            frame->Show();
            frame->Raise();
        }
    }

    virtual void Destroy( wxCommandEvent & event )
    {
        if( frame )
        {
            wxGetApp().RemoveMenuBar( ( mAMenuBar * ) frame->GetMenuBar() );
            frame->Destroy();
            frame = NULL;
        }
        
        mAUIElement::Destroy( event );
    }

    virtual wxWindow * GetFrame()
    {
        return frame;
    }

    virtual void SetParent( wxCommandEvent & event ){ }
    virtual void RemoveParent( wxCommandEvent & event ){ }

    virtual void OnCloseFrame( wxCloseEvent & event )
    {
        if( event.CanVeto() )
        {
            event.Veto();
            frame->Hide();
        }

        else
        {
            wxGetApp().RemoveMenuBar( ( mAMenuBar * ) frame->GetMenuBar() );
            frame->Destroy();
        }
    }

protected:
    mAFrameType * frame;
    wxWindow * content;
};

t_CKBOOL View::init()
{
    native_element = native_view = new mAUIView;
    native_view->Link( this );

    // defaults
    x = -1; // center
    y = -1; // center
    w = 200;
    h = 200;
    name = "";

    wxCommandEvent event( mAEVT_UI_INIT );
    native_view->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL View::display()
{
    wxCommandEvent event( mAEVT_UI_DISPLAY );
    native_view->AddPendingEvent( event );

    return TRUE;
}

t_CKBOOL View::hide()
{    
    wxCommandEvent event( mAEVT_UI_HIDE );
    native_view->AddPendingEvent( event );

    return TRUE;
}

t_CKBOOL View::destroy()
{    
    wxCommandEvent event( mAEVT_UI_DESTROY );
    native_view->AddPendingEvent( event );

    return TRUE;
}

t_CKBOOL View::set_parent( View * p )
{
    return TRUE;
}

t_CKBOOL View::add_element( Element * e )
{
    if( e == NULL )
        return FALSE;
    
    elements.push_back( e );
    e->set_parent( this );
    
    return TRUE;
}

t_CKBOOL View::remove_element( Element * e )
{
    if( e == NULL )
        return FALSE;
    
    std::vector< Element * >::size_type i, len = elements.size();
    
    for( i = 0; i < len; i++ )
    {
        if( elements[i] == e )
        {
            elements[i]->remove_parent( this );
            elements[i] = NULL;
        }
    }
    
    return TRUE;
}

/* in wxWidgets, sliders can only take integral values. to simulate a 
   continuous slider, we set the range to be higher than the possible 
   width of the slider, and then scale it to the user's requested range.  */
#define mASLIDER_MAX 32767 // slider minimum is 0

DECLARE_EVENT_TYPE( mAEVT_UI_RANGE, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_RANGE )
DECLARE_EVENT_TYPE( mAEVT_UI_VALUE, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_VALUE )

class mAUISlider : public mAUIElement
{
public:
    mAUISlider() : mAUIElement()
    {
        slider = NULL;
        s_owner = NULL;
        label = NULL;
        value = NULL;

        Connect( mAEVT_UI_RANGE, wxCommandEventHandler( mAUISlider::SetRange ) );
        Connect( mAEVT_UI_VALUE, wxCommandEventHandler( mAUISlider::SetValue ) );
    }

    virtual void Link( Slider * s )
    {
        owner = s_owner = s;
    }

    virtual void Destroy( wxCommandEvent & event )
    {
        mAUIElement::Destroy( event );
        slider = NULL;
        label = NULL;
        value = NULL;
    }
    
    virtual void SetSize( wxCommandEvent & event )
    {
        if( master_view && slider && label && value )
        {
            master_view->SetSize( ( int ) owner->get_width(), ( int ) owner->get_height() );
            
            slider->Move( ( int ) owner->get_left_margin(), ( int ) ( owner->get_top_margin() + 
                Slider::default_text_height + Slider::default_inner_margin ) );
            slider->SetSize( ( int ) ( owner->get_width() - owner->get_left_margin() - owner->get_right_margin() ),
                             ( int ) ( owner->get_height() - owner->get_top_margin() - owner->get_bottom_margin() -
                             Slider::default_inner_margin - Slider::default_text_height ) );
            
            label->Move( ( int ) owner->get_left_margin(), ( int ) owner->get_top_margin() );
            label->SetSize( ( int ) ( owner->get_width() - owner->get_left_margin() - owner->get_right_margin() ),
                            ( int ) ( owner->get_height() - owner->get_top_margin() - owner->get_bottom_margin() -
                            Slider::default_inner_margin - Slider::default_slider_height ) );
            
            value->SetBestFittingSize( wxSize( -1 , 
                ( int ) ( owner->get_height() - owner->get_top_margin() - owner->get_bottom_margin() -
                Slider::default_inner_margin - Slider::default_slider_height ) ) );
            value->Move( ( int ) ( owner->get_width() - owner->get_right_margin() - value->GetClientSize().GetWidth() ), 
                         ( int ) owner->get_top_margin() );
        }
    }

    virtual void SetName( wxCommandEvent & event )
    {
        if( label )
            label->SetLabel( wxString( owner->get_name().c_str(), wxConvUTF8 ) );
    }

    virtual void SetParent( wxCommandEvent & event )
    {
        wxWindow * parent = ( ( mAUIView * )event.GetClientData() )->GetFrame();
        if( parent == NULL )
        /* when a default parent is used, View::init and Element::set_parent are 
           both called in quick succession.  For some reason, wxWidgets does 
           not seem to guarantee that the resulting mAEVT_UI_INIT and SETPARENT
           are dispatched in the same order that they are posted.  Thus, we have
           to check the value of mAView::GetFrame, and if it is NULL, 
           continually repost the mAEVT_UI_SETPARENT until it is not NULL.  */
        {
            AddPendingEvent( event );
            return;
        }
        
        master_view = new wxWindow( parent, wxID_ANY );
        slider = new wxSlider( master_view, wxID_ANY, 0, 0, mASLIDER_MAX );
        label = new wxStaticText( master_view, wxID_ANY, _T( " " ), 
            wxDefaultPosition, wxDefaultSize, wxST_NO_AUTORESIZE | wxALIGN_LEFT );
        value = new wxStaticText( master_view, wxID_ANY, _T( "0" ), 
            wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT );

        SetSize( event );
        SetPosition( event );
        SetName( event );
        SetRange( event );
        SetValue( event );

        slider->PushEventHandler( this );
        Connect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( mAUISlider::SliderChanged ) );
#if ( wxABI_VERSION >= 20601 ) || !defined( wxABI_VERSION )
        Connect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( mAUISlider::SliderChanged ) );
#endif
    }

    virtual void RemoveParent( wxCommandEvent & event )
    {
        
    }

    virtual void SetRange( wxCommandEvent & event )
    {
        min = s_owner->get_min();
        max = s_owner->get_max();
    }

    virtual void SetValue( wxCommandEvent & event )
    {
        if( slider && value )
        {
            slider->SetValue( ( int ) ( mASLIDER_MAX * ( s_owner->get_value() - min ) / ( max - min ) ) );
            Update( event );
        }
    }

    virtual void Update( wxCommandEvent & event )
    {
        if( value )
        {
            value->SetLabel( wxString::Format( _T( "%f" ), s_owner->get_value() ) );
            SetSize( event );
        }
    }

    virtual void SliderChanged( wxScrollEvent & event )
    {
        t_CKFLOAT scaled_value = ( ( ( t_CKFLOAT ) slider->GetValue() ) / mASLIDER_MAX ) * ( max - min ) + min;
        
        s_owner->slider_changed( scaled_value );
        
        Update( event );
    }

protected:
    wxSlider * slider;
    wxStaticText * label;
    wxStaticText * value;
    Slider * s_owner;

    t_CKFLOAT min;
    t_CKFLOAT max;
};

const t_CKUINT Slider::default_margin = 18;
const t_CKUINT Slider::default_width = 202;
const t_CKUINT Slider::default_slider_height = 21;
const t_CKUINT Slider::default_inner_margin = 5;
const t_CKUINT Slider::default_text_height = 17;

t_CKBOOL Slider::init()
{
    native_element = native_slider = new mAUISlider;
    native_slider->Link( this );

    // defaults
    x = -1; // center
    y = -1; // center
    w = default_width + default_margin * 2;
    h = default_slider_height + default_inner_margin + 
        default_text_height + default_margin * 2;
    lmargin = default_margin;
    rmargin = default_margin;
    tmargin = default_margin - 2;
    bmargin = default_margin - 2;
    name = "";
    e = NULL;

    value = 0;
    min = 0;
    max = 1;

    wxCommandEvent event( mAEVT_UI_INIT );
    native_slider->AddPendingEvent( event );
    
    return TRUE;
}

t_CKDOUBLE Slider::get_value()
{
    return value;
}

t_CKBOOL Slider::set_value( t_CKDOUBLE v )
{
    if( v >= max )
        value = max;
    else if( v <= min )
        value = min;
    else
        value = v;

    wxCommandEvent event( mAEVT_UI_VALUE );
    native_slider->AddPendingEvent( event );

    return TRUE;
}

t_CKBOOL Slider::set_range( t_CKDOUBLE low, t_CKDOUBLE high )
{
    min = low;
    max = high;

    wxCommandEvent event( mAEVT_UI_RANGE );
    native_slider->AddPendingEvent( event );

    set_value( get_value() );

    return TRUE;
}

t_CKDOUBLE Slider::get_max()
{
    return max;
}

t_CKDOUBLE Slider::get_min()
{
    return min;
}

t_CKBOOL Slider::set_precision( t_CKUINT precision )
{
    this->precision = precision;
    
    // refresh
    set_value( get_value() );
    
    return TRUE;
}

t_CKUINT Slider::get_precision()
{
    return precision;
}

t_CKBOOL Slider::set_display_format( Slider::display_format f )
{
    this->df = f;
    
    // refresh
    set_value( get_value() );
    
    return TRUE;
}

Slider::display_format Slider::get_display_format()
{
    return df;
}

t_CKBOOL Slider::set_orientation( orientation o )
{
    if( o == horizontal || o == vertical )
    {
        m_orientation = o;
        
//        [native_slider performSelectorOnMainThread:@selector(setOrientation)
//                                        withObject:nil
//                                     waitUntilDone:NO];
        
        return TRUE;
    }
    
    return FALSE;
}

Slider::orientation Slider::get_orientation()
{
    return m_orientation;
}

void Slider::slider_changed( t_CKFLOAT v )
{
    value = v;

    if( e != NULL )
        e->queue_broadcast();
}

DECLARE_EVENT_TYPE( mAEVT_UI_STATE, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_STATE )
DECLARE_EVENT_TYPE( mAEVT_UI_ACTIONTYPE, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_ACTIONTYPE )

class mAUIButton : public mAUIElement
{
public:
    mAUIButton() : mAUIElement()
    {
        button = NULL;
        toggle = NULL;
        push = NULL;
        b_owner = NULL;
        
        Connect( mAEVT_UI_ACTIONTYPE, 
                 wxCommandEventHandler( mAUIButton::SetActionType ) );
        Connect( wxEVT_LEFT_DOWN, 
                 wxMouseEventHandler( mAUIButton::OnMouse ) );
        Connect( wxEVT_LEFT_UP, 
                 wxMouseEventHandler( mAUIButton::OnMouse ) );
    }
    
    virtual void Link( Button * b )
    {
        owner = b_owner = b;
    }
    
    virtual void SetPosition( wxCommandEvent & event )
    {
        if( master_view )
        {
            int x = ( int ) owner->get_x(), y = ( int ) owner->get_y();
            
/*            if( master_view->GetParent()->GetChildren().GetCount > 1 )
            {
                if( x != -1 )
                    x += owner->get_left_margin();
                if( y != -1 )
                    y += owner->get_top_margin();
            }*/
            
            master_view->Move( x + ( x == -1 ? 0 : owner->get_left_margin() ),
                               y + ( y == -1 ? 0 : owner->get_top_margin() ) );
            if( x == -1 )
            {
                if( y == -1 )
                    master_view->Center( wxHORIZONTAL | wxVERTICAL );
                else
                    master_view->Center( wxHORIZONTAL );
            }
            else if( y == -1 )
                master_view->Center( wxVERTICAL );
        }
    }
    
    virtual void SetSize( wxCommandEvent & event )
    {
        if( master_view && button )
        {
            //master_view->SetSize( ( int ) owner->get_width(), ( int ) owner->get_height() );
            master_view->SetSize( ( int ) ( owner->get_width() - owner->get_left_margin() - owner->get_right_margin() ),
                                  ( int ) ( owner->get_height() - owner->get_top_margin() - owner->get_bottom_margin() ) );
            
            //button->Move( ( int ) owner->get_left_margin(), ( int ) owner->get_top_margin() );
            button->Move( 0, 0 );
            //button->Center( wxHORIZONTAL | wxVERTICAL );
            button->SetSize( ( int ) ( owner->get_width() - owner->get_left_margin() - owner->get_right_margin() ),
                             ( int ) ( owner->get_height() - owner->get_top_margin() - owner->get_bottom_margin() ) );
        }
    }
    
    virtual void SetName( wxCommandEvent & event )
    {
        if( button )
            button->SetLabel( wxString( owner->get_name().c_str(), wxConvUTF8 ) );
    }
    
    virtual void SetParent( wxCommandEvent & event )
    {
        wxWindow * parent = ( ( mAUIView * ) event.GetClientData() )->GetFrame();
        if( parent == NULL )
            /* when a default parent is used, View::init and Element::set_parent are 
            both called in quick succession.  For some reason, wxWidgets does 
            not seem to guarantee that the resulting mAEVT_UI_INIT and SETPARENT
            are dispatched in the same order that they are posted.  Thus, we have
            to check the value of mAView::GetFrame, and if it is NULL, 
            continually repost the mAEVT_UI_SETPARENT until it is not NULL. */
        {
            /* this should actually cause pending events for other wxEvtHandlers
            to process -- pending events are handled on a per-wxEvtHandler 
            basis */
            wxGetApp().ProcessPendingEvents();
            
            parent = ( ( mAUIView * ) event.GetClientData() )->GetFrame();
            if( parent == NULL )
            {
                AddPendingEvent( event );
                return;
            }
        }
        
        master_view = new wxWindow( parent, wxID_ANY );
        master_view->SetOwnBackgroundColour( *wxBLACK );
        push = new wxButton( master_view, wxID_ANY );
        button = push;
        
        button->PushEventHandler( this );
        
        SetSize( event );
        SetPosition( event );
        SetName( event );
        SetState( event );
        SetActionType( event );
    }
    
    virtual void RemoveParent( wxCommandEvent & event )
    {
        
    }
    
    virtual void SetState( wxCommandEvent & state )
    {
        if( toggle )
            toggle->SetValue( b_owner->get_state() );
    }
    
    virtual void SetActionType( wxCommandEvent & event )
    {
        if( master_view )
        {
            Button::action_type at = b_owner->get_action_type();
            
            // set to push type
            if( at == Button::push_type && !push )
            {
                if( toggle )
                {
                    toggle->Destroy();
                    toggle = NULL;
                }
                
                push = new wxButton( master_view, wxID_ANY );
                button = push;
                button->PushEventHandler( this );
                
                SetSize( event );
                SetPosition( event );
                SetName( event );
                SetState( event );            
            }
            
            // set to toggle type
            else if( at == Button::toggle_type && !toggle )
            {
                if( push )
                {
                    push->Destroy();
                    push = NULL;
                }
                
                toggle = new wxToggleButton( master_view, wxID_ANY, _T( "" ) );
                button = toggle;
                button->PushEventHandler( this );
            
                SetSize( event );
                SetPosition( event );
                SetName( event );
                SetState( event );
            }
        }
    }
    
    virtual void OnMouse( wxMouseEvent & event )
    {
        if( push )
            b_owner->button_changed();
        else if( toggle && event.LeftDown() )
            b_owner->button_changed();
        
        event.Skip();
    }
    
protected:
    wxControl * button;
    wxToggleButton * toggle;
    wxButton * push;
    Button * b_owner;
};

const t_CKUINT Button::default_margin = 18;
const t_CKUINT Button::default_button_width = 55;
const t_CKUINT Button::default_button_height = 55;

t_CKBOOL Button::init()
{
    native_element = native_button = new mAUIButton;
    native_button->Link( this );

    // defaults
    x = -1; // center
    y = -1; // center
    w = default_button_width + default_margin * 2;
    h = default_button_height + default_margin * 2;
    lmargin = default_margin;
    rmargin = default_margin;
    tmargin = default_margin;
    bmargin = default_margin;
    name = "";
    e = NULL;
    
    pushed = 0;
    
    wxCommandEvent event( mAEVT_UI_INIT );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL Button::get_state()
{
    return pushed;
}

t_CKBOOL Button::set_state( t_CKBOOL state )
{
    pushed = state ? 1 : 0;
    
    wxCommandEvent event( mAEVT_UI_STATE );
    native_button->AddPendingEvent( event );
    
    return FALSE;
}

t_CKBOOL Button::set_action_type( action_type t )
{
    at = t;
    wxCommandEvent event( mAEVT_UI_ACTIONTYPE );
    native_button->AddPendingEvent( event );

    return FALSE;
}

Button::action_type Button::get_action_type()
{
    return at;
}

t_CKBOOL Button::unset_image()
{
//    [native_button performSelectorOnMainThread:@selector(setImage:)
//                                    withObject:nil
//                                 waitUntilDone:NO];
    return TRUE;
}

t_CKBOOL Button::set_image( std::string & path )
{
//    NSAutoreleasePool * arpool = [NSAutoreleasePool new];
//    
//    NSImage * i = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:path.c_str()]];
//    
//    if(i == NULL)
//    {
//        return FALSE;
//    }
//    
//    [native_button performSelectorOnMainThread:@selector(setImage:)
//                                    withObject:i
//                                 waitUntilDone:NO];
//    
//    [i release];
//    
//    [arpool release];
    
    return TRUE;
}

void Button::button_changed()
{
    if( e != NULL )
        e->queue_broadcast();
    
    pushed = !pushed;
}

DECLARE_EVENT_TYPE( mAEVT_UI_LIGHT, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_LIGHT )
DECLARE_EVENT_TYPE( mAEVT_UI_UNLIGHT, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_UNLIGHT )
DECLARE_EVENT_TYPE( mAEVT_UI_COLOR, -1 )
DEFINE_EVENT_TYPE( mAEVT_UI_COLOR )

class mAUILED : public mAUIElement
{
public:
    mAUILED() : mAUIElement()
    {
        trace_location();        

        image = NULL;
        l_owner = NULL;
        
        Connect( mAEVT_UI_LIGHT, 
                 wxCommandEventHandler( mAUILED::Light ) );
        Connect( mAEVT_UI_UNLIGHT, 
                 wxCommandEventHandler( mAUILED::Unlight ) );
        Connect( mAEVT_UI_COLOR, 
                 wxCommandEventHandler( mAUILED::SetColor ) );
    }
    
    virtual void Link( LED * l )
    {
        trace_location();
        owner = l_owner = l;
    }
    
    virtual void SetSize( wxCommandEvent & event )
    {
        if( master_view && image )
        {
            master_view->SetSize( owner->get_width(), owner->get_height() );
            
            image->Center( wxHORIZONTAL | wxVERTICAL );
            //image->Move( owner->get_left_margin(), owner->get_top_margin() );
//            image->Move( owner->get_left_margin(), owner->get_top_margin() );
//            image->SetSize( owner->get_width() - owner->get_left_margin() - owner->get_right_margin(),
//                            owner->get_height() - owner->get_top_margin() - owner->get_bottom_margin() );
        }
    }
    
    virtual void SetParent( wxCommandEvent & event )
    {
        trace_location();
        wxWindow * parent = ( ( mAUIView * )event.GetClientData() )->GetFrame();
        if( parent == NULL )
            /* when a default parent is used, View::init and Element::set_parent are 
            both called in quick succession.  For some reason, wxWidgets does 
            not seem to guarantee that the resulting mAEVT_UI_INIT and SETPARENT
            are dispatched in the same order that they are posted.  Thus, we have
            to check the value of mAView::GetFrame, and if it is NULL, 
            continually repost the mAEVT_UI_SETPARENT until it is not NULL.  */
        {
            /* this should actually cause pending events for other wxEvtHandlers
             to process -- pending events are handled on a per-wxEvtHandler 
             basis */
            wxGetApp().ProcessPendingEvents();
            
            parent = ( ( mAUIView * ) event.GetClientData() )->GetFrame();
            if( parent == NULL )
            {
                AddPendingEvent( event );
                return;
            }
        }
        
        if( off_image == NULL )
            off_image = new wxBitmap( led_off_xpm );
        if( red_image == NULL )
            red_image = new wxBitmap( led_red_xpm );
        if( green_image == NULL )
            green_image = new wxBitmap( led_green_xpm );
        if( blue_image == NULL )
            blue_image = new wxBitmap( led_blue_xpm );
        on_image = red_image;
        
        master_view = new wxWindow( parent, wxID_ANY );
        image = new wxStaticBitmap( master_view, wxID_ANY, *off_image );
        
        image->PushEventHandler( this );
        
        SetSize( event );
        SetPosition( event );
        SetName( event );
        SetColor( event );
    }
    
    virtual void RemoveParent( wxCommandEvent & event )
    {
        
    }
    
    virtual void Light( wxCommandEvent & event )
    {
        if( image )
            image->SetBitmap( *on_image );
    }
    
    virtual void Unlight( wxCommandEvent & event )
    {
        if( image )
            image->SetBitmap( *off_image );
    }
    
    virtual void SetColor( wxCommandEvent & event )
    {
        if( l_owner )
        {
            LED::color c = l_owner->get_color();
            if( c == LED::red )
                on_image = red_image;
            else if( c == LED::green )
                on_image = green_image;
            else if( c == LED::blue )
                on_image = blue_image;
        }
    }
    
protected:
    wxStaticBitmap * image;
    static wxBitmap * off_image;
    static wxBitmap * red_image;
    static wxBitmap * green_image;
    static wxBitmap * blue_image;
    wxBitmap * on_image;
    LED * l_owner;
};

wxBitmap * mAUILED::off_image = NULL;
wxBitmap * mAUILED::red_image = NULL;
wxBitmap * mAUILED::green_image = NULL;
wxBitmap * mAUILED::blue_image = NULL;

const t_CKUINT LED::default_margin = 18; 
const t_CKUINT LED::default_led_width = 28;
const t_CKUINT LED::default_led_height = 28;

t_CKBOOL LED::init()
{
    native_element = native_led = new mAUILED;
    native_led->Link( this );
    
    x = -1;
    y = -1;
    w = default_led_width + default_margin * 2;
    h = default_led_height + default_margin * 2;
    lmargin = default_margin;
    rmargin = default_margin;
    tmargin = default_margin;
    bmargin = default_margin;
    name = "";
    e = NULL;
    
    c = red;

    wxCommandEvent event( mAEVT_UI_INIT );
    native_element->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL LED::light()
{
    wxCommandEvent event( mAEVT_UI_LIGHT );
    native_led->AddPendingEvent( event );

    return TRUE;
}

t_CKBOOL LED::unlight()
{
    wxCommandEvent event( mAEVT_UI_UNLIGHT );
    native_led->AddPendingEvent( event );
    
    return TRUE;
}

t_CKBOOL LED::set_color( color c )
{
    unlight();
    
    //if( c != red || c != green || c != blue )
    //    return FALSE;
    
    this->c = c;
    
    wxCommandEvent event( mAEVT_UI_COLOR );
    native_led->AddPendingEvent( event );
        
    return TRUE;
}

LED::color LED::get_color()
{
    return c;
}

const t_CKUINT Text::default_margin = 0;
const t_CKUINT Text::default_text_width = 50;
const t_CKUINT Text::default_text_height = 20;


t_CKBOOL Text::init()
{
    return true;
}

const t_CKUINT Gauge::default_margin = 18;
const t_CKUINT Gauge::default_gauge_width = 40;
const t_CKUINT Gauge::default_gauge_height = 58;

t_CKBOOL Gauge::init()
{
    return TRUE;
}

t_CKBOOL Gauge::set_value( t_CKFLOAT _value ) // between 0 and 1
{
    return TRUE;
}

t_CKFLOAT Gauge::get_value()
{
    return 0;
}



} /* UI */
//} /* miniAudicle */

