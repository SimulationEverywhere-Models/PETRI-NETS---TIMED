/*******************************************************************
*
*  DESCRIPTION: Petri Net Transition DEVS Atomic Model
*
*  This is the implementation of the Petri Net transition atomic 
*  model.  The model has five inputs and five output ports defined
*  as follows:
*
*  <in1>: This input port is used to be notified of the number of
*  tokens contained in the place(s) which have their output
*  connected to this input.  Places which connect to this port
*  do so because the connection consists of a single connecting 
*  arc.  That is, if the transition fires, only one token will
*  be removed from the input place(s).
*
*  <in2>: This input port serves the same function as the <in1>
*  port except that the connection consists of a double connecting
*  arc which implies the input place(s) will loose two tokens if the 
*  transition fires.
*
*  <in3>: This input port serves the same function as the <in1>
*  port except that the connection consists of a triple connecting
*  arc which implies the input place(s) will loose three tokens if the 
*  transition fires.
*
*  <in4>: This input port serves the same function as the <in1>
*  port except that the connection consists of a quadruple connecting
*  arc which implies the input place(s) will loose four tokens if the 
*  transition fires.
*
*  <in0>: This input port serves the same function as the <in1>
*  port except that the connection consists of an inhibitor
*  arc.  That is, the input place must contained zero token for the 
*  transition to fire and when it does, no token is removed from
*  the place.
*
*  <out1>: This output is used to feed 1 token to all the places
*  which have their <in> port connected to this port.
*
*  <out2>: This output is used to feed 2 token to all the places
*  which have their <in> port connected to this port.
*
*  <out3>: This output is used to feed 3 token to all the places
*  which have their <in> port connected to this port.
*
*  <out4>: This output is used to feed 4 token to all the places
*  which have their <in> port connected to this port.
*
*  <fired>: This output is used to remove tokens from the input
*  places which have their <fired> input port connected to this
*  port.
*
*  AUTHOR: Christian Jacques
*
*  EMAIL: chris.jacques@videotron.ca
*
*  DATE: 19 November 2001
*
*******************************************************************/

/** include files **/
#include "pnTrans.h"  	// class PnTrans 
#include "message.h"    // class ExternalMessage, InternalMessage
#include "mainsimu.h"   // MainSimulator::Instance().getParameter( ... )
#include "time.h"	// class Time
#include "realfunc.h"   // trunc()
#include "real.h"   	// class Real
#include "except.h"   	// for exceptions
#include <C:\cygwin\usr\include\time.h>	// time()
#include <stdlib.h>	// srand(), rand()

static unsigned int inPlaces;	// This variable indicates the maximum 
				// number of inputs places this transition 
				// can deal with.

/** public functions **/

/*******************************************************************
* Function Name: PnTrans constructor
* Description: This routine constructs the PnTrans model.  In 
* addition to creating the ports, it allocates the memory to
* store the array of input places used by the transition.  Also,
* the number of input places is initialized to zero.
********************************************************************/
PnTrans::PnTrans( const string &name )
: Atomic( name )
, in0( addInputPort( "in0" ) )
, in1( addInputPort( "in1" ) )
, in2( addInputPort( "in2" ) )
, in3( addInputPort( "in3" ) )
, in4( addInputPort( "in4" ) )
, out1( addOutputPort( "out1" ) )
, out2( addOutputPort( "out2" ) )
, out3( addOutputPort( "out3" ) )
, out4( addOutputPort( "out4" ) )
, fired( addOutputPort( "fired" ) )
{

	if( MainSimulator::Instance().existsParameter( description(), 
	    "inputplaces" ))
	   inPlaces = str2Int( MainSimulator::Instance().getParameter \
	    ( description(), "inputplaces" ) );
	else
	   // The default is to allocate for ten input places
	   // (for this transition alone) which should be 
	   // more than enough.
	   inPlaces = 10;

	pArrayStart = new( inputPlaceInfo[inPlaces] );

	numOfInputs = 0;
}

/*******************************************************************
* Function Name: PnPlace init function
* Description: This routine is invoked when simulation starts.
* It schedules a transition firing in a random amount of time.
* This is necessary in case the transition is a source.  That is,
* it is always enabled.  If it is not, external messages will
* come in from input places at simulation time 0 such that this 
* scheduled internal event will never occur.
********************************************************************/
Model &PnTrans::initFunction()
{
	holdIn( active, (float) this->randNumGet() );

	return *this ;
}

/*******************************************************************
* Function Name: externalFunction
* Description: This method handles external events coming from 
* any one of the fice input ports.  The format of the messages
* received is "XYYY" where X is the the model ID of the place
* which sent the message.  YYY is the number of tokens contained
* in that place.  For example, 12007 means that the place whose ID
* is 12 contains 7 tokens.  This routine uses the ID  to keep track 
* of all the places which feed tokens to this transition.
********************************************************************/
Model &PnTrans::externalFunction( const ExternalMessage &msg )
{
	Real 		placeId;	// Place the message came from
	unsigned int 	numOfTokens;	// Number of tokens in that place
	unsigned int 	arcWidth;	// Width of arc connecting input place
					// to this transition
	bool 		placeIdMatch;	// Flag indicating if placeId match occured
	unsigned int 	i;		// array index

	placeIdMatch = false;
	transEnabled = true;

	// The width of the connecting arc depends on the port 
	// tokens are received from.
	if( msg.port() == in0 ) {arcWidth = 0;}
	else if( msg.port() == in1 ) {arcWidth = 1;}
	else if( msg.port() == in2 ) {arcWidth = 2;}
	else if( msg.port() == in3 ) {arcWidth = 3;}
	else if( msg.port() == in4 ) {arcWidth = 4;}

	// Determine which input place sent the message and how many tokens 
	// are contained in that place.
	placeId = trunc( msg.value() / 1000 );
	numOfTokens = (int) msg.value() %  1000;

	// Set pInArray to point to the start of the array of input 
	// places.
	pInArray = pArrayStart;

	// Check to see if the place the message comes from is already
	// in the input place array
	for( i = 0; i < numOfInputs; i++ )
	    {
	    if( (!placeIdMatch) && (pInArray->placeId == \
		(int) placeId.value()) )
		{
		// We have a match.  Determine if the transition
		// is potentially enabled because of this
		// message.
		if( (arcWidth != 0) && (numOfTokens >= arcWidth) )
		    pInArray->enabled = true;
		else if( (arcWidth == 0) && (numOfTokens == 0) )
		    pInArray->enabled = true;
		else
		    pInArray->enabled = false;
			   	
		placeIdMatch = true;
		}

	    // Determine if the transition is enabled.  Note that
	    // there is a case where transEnabled is set to true
	    // but should not:  When this is the first time a message
	    // is received from placeId and all other input places in 
	    // the array of input places have enough tokens to make 
	    // the transition enabled.  This situation is dealt with below.
	    transEnabled = transEnabled && pInArray->enabled;

	    ++pInArray;

	    } // End of for loop

	// If there was no match for placeId it is because this is the
	// first message received from that place. Therefore store 
	// placeId in the array of input places along with the
	// arc width and determine if the transition is potentially
	// enabled from that place.
	if( !placeIdMatch )	
	    {
	    // Check to make sure we have space left in the array
	    // before adding the new placeId.
	    if( numOfInputs == inPlaces )
	    	{
		// Throw an exception 
		++numOfInputs;
		MException e( string("inputplaces parameter (") + inPlaces + \
		    ") is too small to handle all the places (" + numOfInputs + \
		    ") connected to transition " + description() + \
		    ".  Please specify a larger inputplaces parameter");
		e.addLocation( MEXCEPTION_LOCATION() );
		throw e;
		}

	    pInArray->placeId = (int) placeId.value();
	    pInArray->arcWidth = arcWidth;

	    if( (arcWidth != 0) && (numOfTokens >= arcWidth) )
		pInArray->enabled = true;
	    else if( (arcWidth == 0) && (numOfTokens == 0) )
		pInArray->enabled = true;
	    else
		{
		pInArray->enabled = false;
		transEnabled = false;
		}
	    numOfInputs++;
	    }

	// If the transition is enabled, schedule an internal
	// event to fire the transition some time in the future.
	// Because this transition schedules its firing independantly
	// of the other transitions that may be in the system, it may
	// fire at the same time as others.  However, because of
	// the select function of the DEVS formalism, the firings
	// would be processed as discrete events therefore it would
	// not be a problem.  The only odd thing would be that the 
	// log and output files would show more than one firing at 
	// the same time index.
	if( transEnabled )
	    {
	    holdIn( active, (float) this->randNumGet() );
	    }
	else
	    passivate();


	return *this;
}

/*******************************************************************
* Function Name: internalFunction
* Description: This method implements the internal transition
* function of the model.  It is activated only when the transition
* fires.  In the case of a transition with input places, the model
* simply passivates, waiting for those places to re-advertise
* the number of tokens they contain.  In the case of a source
* transition, which are always enabled, the next firing is 
* scheduled. 
********************************************************************/
Model &PnTrans::internalFunction( const InternalMessage & )
{
	// Check to see if this is a source transition.  If it
	// is, schedule the next firing.
	if( numOfInputs == 0 )
	    {
	    holdIn( active, (float) this->randNumGet() );
	    }
	else 
	    // Wait for the input places to let the transition know 
	    // the number of tokens they contain.
	    passivate();

	return *this;
}

/*******************************************************************
* Function Name: outputFunction
* Description: This routine is activated when the transition fires.
* It deposits tokens in the places which have their <in> port 
* connected to the <out1>, <out2>, <out3> and <out4> output ports
* of this model.  The number of tokens deposited in the output places 
* depends on the port they are connected to.  The ones connected to 
* <out1> receive one token, the ones connected to <out2> receive two 
* tokens and so on.  The messages sent out of those ports simply 
* contain the number of tokens to be deposited.  The routine also
* indicates that it fired by sending a message to all of its inputs
* places which are connected to the <fired> output port.  The
* transition knows exactly who the inputs places are because
* it keeps track of them using their ID.  The format of the message
* sent on the <fired> port is "XYYY" where X is the place to which
* the message is destined and YYY is the number of tokens the place
* must subtract from its contents.
********************************************************************/
Model &PnTrans::outputFunction( const InternalMessage &msg )
{
	unsigned int i;		// array index

	// Set pInArray to the start of the array of input places.
	pInArray = pArrayStart;	
	
	// Deposit tokens in all output places
    	sendOutput( msg.time(), out1, 1 );
    	sendOutput( msg.time(), out2, 2 );
    	sendOutput( msg.time(), out3, 3 );
    	sendOutput( msg.time(), out4, 4 );

	// Remove tokens from all input places
	for( i = 0; i < numOfInputs; i++ )
	    {
	    sendOutput( msg.time(), fired, 
			pInArray->placeId * 1000 + pInArray->arcWidth );
	    ++pInArray;
	    }

	// Even source transitions send a "fired" message to
	// indicate the firing. 
	if( numOfInputs == 0 )
	    sendOutput( msg.time(), fired, 0 );


    	return *this ;
}

/*******************************************************************
* Function Name: randNumGet
* Description: This routine returns a random number between one
* and 60.  It is used by the transition to schedule its firings.
********************************************************************/
unsigned int PnTrans::randNumGet( void )
{
	unsigned int value = 0;

	// Seed the random number generator the first time this 
	// method is called.
	if (!randGenSeeded)
	    {
	    time_t seed;	// Seed for the random number generator

	    // Use real time clock to generate seeds
	    time( &seed );

	    // Seed the random number generator
	    srand( seed );

	    randGenSeeded = true;
	    }

	// Now generate the random number
	while ( (value < 1) || (value > 60) )
	    {
	    value = (unsigned int) rand() % 100;
	    }

	return( value );

}
