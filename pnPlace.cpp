/*******************************************************************
*
*  DESCRIPTION: Petri Net Place DEVS Atomic Model
*
*  This is the implementation of the Petri Net place atomic model.
*  The model has two inputs and one output ports defined as follows:
*
*  <in>: This input is used to receive tokens from zero or more
*  Petri Net transitions.  Whenever a message is received on this port,
*  the place increments the number of tokens it contains by the value
*  specified in the message.  Therefore the model supports multiple
*  arcs.
*
*  <fired>: This input is used to be notified when a transition fires.
*  It is meant to be connected to the <fired> output port of every 
*  transition which receives tokens from this place.  Whenever a message
*  is received on this port, the place decrements the number of tokens 
*  it contains by the value specified in the message.
*
*  <out>: This output is used by the place to advertise the number of tokens
*  it contains so transitions that are connected to it can determine if
*  they are enabled.
*
*  AUTHOR: Christian Jacques
*
*  EMAIL: chris.jacques@videotron.ca
*
*  DATE: 19 November 2001
*
*******************************************************************/

/** include files **/
#include "pnPlace.h"  	// class PnPlace 
#include "message.h"    // class ExternalMessage, InternalMessage
#include "mainsimu.h"   // MainSimulator::Instance().getParameter()
#include "model.h"   	// Model::id()
#include "strutil.h"   	// str2Int()
#include "realfunc.h"  	// trunc()
#include "except.h"  	// for exception
#include "process.h"  	// class Processor

/** public functions **/

/*******************************************************************
* Function Name: PnPlace constructor
* Description: This routine constructs the PnPlace model.
* In addition to creating the ports of the model, this routine
* initializes the number of tokens that are contained in the 
* place.  This value comes from the "tokens" parameter specified
* in the .ma file.  If the parameter is not specified, the place 
* is assumed to be empty.
********************************************************************/
PnPlace::PnPlace( const string &name )
: Atomic( name )
, in( addInputPort( "in" ) )
, out( addOutputPort( "out" ) )
{

	if( MainSimulator::Instance().existsParameter( description(), 
	    "tokens" ))
	   numOfTokens = str2Int( MainSimulator::Instance().getParameter \
	    ( description(), "tokens" ) );
	else
	   numOfTokens = 0;

}

/*******************************************************************
* Function Name: PnPlace init function
* Description: This routine is invoked when simulation starts.
* At the beginning of the simulation the place must advertise the
* number of tokens it contains so transitions that are connected
* to it can determine if they are enabled or not.  Furthermore,
* the model ID of the place is saved.  This is used by the
* external and output functions. 
********************************************************************/
Model &PnPlace::initFunction()
{

	// Get the id of this model.  This call cannot be made in 
	// the constructor because the id is not set by the simulator
	// yet.
	placeId = Model::id();

	// Advertise the number of tokens contained in this place
	holdIn( active, Time::Zero );

	return *this ;
}

/*******************************************************************
* Function Name: externalFunction
* Description: This method handles external events coming from any
* of the two input ports: <in> and <fired>.  The value of the 
* messages coming in the <in> port is simply the number of tokens
* the place needs to add to its current content.  This is the port
* transitions send messages to to deposit tokens in the place.
* The <fired> port receives messages telling the place to reduce its 
* token count by a given amount.  The messages coming into this port 
* actually contain two pieces of information.  The first one being
* the number of tokens to subtract the second being the ID of the
* place to which the message is destined.  The format is "XYYY" 
* where X is the model ID of the place and YYY is the number 
* of tokens.  For example, 5003 is a message meaning that the place
* whose ID is 5 must subtract 3 tokens.  Therefore, the maximum
* number of tokens a place can advertize is 999.  However, internally
* the proper number of tokens is kept.
********************************************************************/
Model &PnPlace::externalFunction( const ExternalMessage &msg )
{
	Real destId;	// Place the message is for.
 
	if( msg.port() == in )
	   {
	   // Check who the message is for
	   destId = trunc( msg.value() / 1000 );
		
	   if( (ModelId) destId.value() == placeId )
		{
		// Message is specifically for this place. 
		// Decrement the number of tokens.  It is an 
		// error condition to attempt to remove more 
		// tokens then there are in the place.
		if( numOfTokens >= ((int) msg.value() % 1000) )
		    {
	   	    numOfTokens -= (int) msg.value() % 1000;
		    }
		else  // Throw an exception
		    {
		    MException e( string("An attempt was made to remove " \
		    "more tokens (") + ((int) msg.value() % 1000) + ") than " \
		    "the number of tokens (" \
		    + numOfTokens + ")contained in place " \
		    + description() + \
		    ".  Please ensure the in port of the place is " \
		    "connected to the proper transition(s)");
		    e.addLocation( MEXCEPTION_LOCATION() );
		    throw e;
		    }
		} 
	   else if( (ModelId) destId.value() == 0 )
		{
		// This is a generic message.  A transition wants to
		// deposit tokens
		numOfTokens += (int) msg.value();
		}
	}
	// Immediately tell all transitions receiving tokens 
	// from this place there is a new number of tokens
	holdIn( active, Time::Zero );

	return *this;
}

/*******************************************************************
* Function Name: internalFunction
* Description: This method always passivates the model because 
* after activating the output function, the place waits forever
* for a transition to deposit or remove tokens from its contents.
********************************************************************/
Model &PnPlace::internalFunction( const InternalMessage & )
{
	passivate();

	return *this;
}

/*******************************************************************
* Function Name: outputFunction
* Description: This routines outputs the number of tokens contained
* in the place on the output port <out>.  The format of the message
* is "XYYY" where X is the model ID of this place and YYY is the
* number of tokens it contains.  For example, 2011 means the ID of
* this place is 2 and it contains 11 tokens.  The maximum number
* of tokens that can be advertised is 999.
********************************************************************/
Model &PnPlace::outputFunction( const InternalMessage &msg )
{
	// If there are more than 999 tokens, advertise that 
	// there are only 999.  This should not affect the
	// state of the transtion(s) which depend on this place
	// to be enabled.
	sendOutput( msg.time(), out, placeId * 1000 + \
		  ( numOfTokens > 999 ? 999 : numOfTokens ) );

	return *this ;
}
