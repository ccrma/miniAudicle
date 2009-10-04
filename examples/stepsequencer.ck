// stepsequencer.ck
// simple kick/snare/hihat step sequencer
// requires hihat.wav, snare.wav, kick.wav in current working directory
// (can be found in examples/data)
// spencer salazar - ssalazar@cs.princeton.edu

// iterator
int i;

// view
MAUI_View view;

// initial parameters
75 => int button_height => int button_width;
16 => int num_steps;
120 => float bpm;

// seconds per step (assuming 4 beats per measure)
1/bpm * 60 * 4 / num_steps => float sps;

// GUI elements
MAUI_Button hihat_button[num_steps];
MAUI_Button snare_button[num_steps];
MAUI_Button kick_button[num_steps];
MAUI_LED led[num_steps];

// set view size
view.size( button_width * num_steps, button_height * 4 );

for( 0 => i; i < num_steps; i++ )
{
	// initialize kick row
	kick_button[i].toggleType();
	kick_button[i].size( button_height, button_width );
	kick_button[i].position( i * kick_button[i].width(), 0 );

	// initialize snare row
	snare_button[i].toggleType();
	snare_button[i].size( button_height, button_width );
	snare_button[i].position( i * snare_button[i].width(), kick_button[i].y() + kick_button[i].height() );

	// initialize hihat row
	hihat_button[i].toggleType();
	hihat_button[i].size( button_height, button_width );
	hihat_button[i].position( i * hihat_button[i].width(), snare_button[i].y() + snare_button[i].height() );

	// initialize led row
	led[i].size( button_height, button_width );
	led[i].color( MAUI_LED.green );
	led[i].position( i * led[i].width(), hihat_button[i].y() + hihat_button[i].height() );

	// add to view
	view.addElement( kick_button[i] );
	view.addElement( snare_button[i] );
	view.addElement( hihat_button[i] );
	view.addElement( led[i] );
}

// display the view
view.display();

// initialize kick sample
sndbuf kick => dac;
"kick.wav" => kick.read;
kick.samples() - 1 => kick.pos;

// initialize snare sample
sndbuf snare => dac;
"snare.wav" => snare.read;
snare.samples() - 1 => snare.pos;

// initialize hihat sample
sndbuf hihat => dac;
"hihat.wav" => hihat.read;
hihat.samples() - 1 => hihat.pos;

// give GUI a chance to load
.5::second => now;

// loop
while( true )
{
	for( 0 => i; i < num_steps; i++ )
	{
		// check current kick step
		if( kick_button[i].state() )
			0 => kick.pos;

		// check current snare step
		if( snare_button[i].state() )
			0 => snare.pos;

		// check current hihat step
		if( hihat_button[i].state() )
			0 => hihat.pos;

		// light the LED for this step
		led[i].light();
		
		// advance time
		sps::second => now;

		// unlight
		led[i].unlight();
	}
}


