/*******************************************************************
*
*  DESCRIPTION: Petri Net Place DEVS Atomic Model Header File 
*
*  AUTHOR: Christian Jacques
*
*  EMAIL: chris.jacques@videotron.ca
*
*  DATE: 19 November 2001
*
*******************************************************************/

#ifndef __PNPLACE_H
#define __PNPLACE_H

#include <list>
#include "atomic.h"     // class Atomic
#include "modelid.h"    // definition of ModelId

// PnPlace class

class PnPlace : public Atomic
{
public:
	// Constructor
	PnPlace( const string &name = "PnPlace" );

	virtual string className() const ;
protected:
	Model &initFunction();
	Model &externalFunction( const ExternalMessage & );
	Model &internalFunction( const InternalMessage & );
	Model &outputFunction( const InternalMessage & );

private:

	// input ports
	const Port &in;

	// output port
	Port &out;

	// state variables
	int numOfTokens;	// number of token in the place

	// ID of the place
	ModelId placeId;


};	// class PnPlace

// ** inline ** // 
inline
string PnPlace::className() const
{
	return "PnPlace" ;
}

#endif   //__PNPLACE_H
