/*******************************************************************
*
*  DESCRIPTION: Petri Net Transition DEVS Atomic Model Header File 
*
*  AUTHOR: Christian Jacques
*
*  EMAIL: chris.jacques@videotron.ca
*
*  DATE: 19 November 2001
*
*******************************************************************/

#ifndef __PNTRANS_H
#define __PNTRANS_H

#include <list>
#include "atomic.h"     // class Atomic

// structure to store information about input places
struct inputPlaceInfo
    {
    int placeId;
    unsigned int arcWidth;
    bool enabled;
    }; 

// PnTrans class

class PnTrans : public Atomic
{
public:
	// Constructor
	PnTrans( const string &name = "PnTrans" );

	virtual string className() const ;
protected:
	Model &initFunction();
	Model &externalFunction( const ExternalMessage & );
	Model &internalFunction( const InternalMessage & );
	Model &outputFunction( const InternalMessage & );
	unsigned int randNumGet( void );

private:

	// Input port
	const Port &in0;
	const Port &in1;
	const Port &in2;
	const Port &in3;
	const Port &in4;

	// Output port
	Port &out1;
	Port &out2;
	Port &out3;
	Port &out4;
	Port &fired;

	// State variables
	bool transEnabled;	
	unsigned int numOfInputs;
	bool randGenSeeded;

	// Pointers to an array of input places
	inputPlaceInfo * pInArray;
	inputPlaceInfo * pArrayStart;

};	// class PnTrans

// ** inline ** // 
inline
string PnTrans::className() const
{
	return "PnTrans" ;
}

#endif   //__PNTRANS_H
