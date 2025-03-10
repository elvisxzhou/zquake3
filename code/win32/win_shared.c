/*
===========================================================================
Copyright (C) 1999-2005 Id Software, Inc.

This file is part of Quake III Arena source code.

Quake III Arena source code is free software; you can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of the License,
or (at your option) any later version.

Quake III Arena source code is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
===========================================================================
*/

#include "../game/q_shared.h"
#include "../qcommon/qcommon.h"
#include "win_local.h"
#include <lmerr.h>
#include <lmcons.h>
#include <lmwksta.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <direct.h>
#include <io.h>
#include <conio.h>

/*
================
Sys_Milliseconds
================
*/
int			sys_timeBase;
int Sys_Milliseconds (void)
{
	int			sys_curtime;
	static qboolean	initialized = qfalse;

	if (!initialized) {
		sys_timeBase = timeGetTime();
		initialized = qtrue;
	}
	sys_curtime = timeGetTime() - sys_timeBase;

	return sys_curtime;
}

/*
================
Sys_SnapVector
================
*/

void Sys_SnapVector( float *v )
{
#if id386 && defined(_MSC_VER)
	int             i;
	float           f;

	f = *v;
	__asm fld       f;
	__asm fistp     i;

	*v = i;
	v++;
	f = *v;
	__asm fld       f;
	__asm fistp     i;

	*v = i;
	v++;
	f = *v;
	__asm fld       f;
	__asm fistp     i;

	*v = i;
#else
	v[0] = (int)v[0];
	v[1] = (int)v[1];
	v[2] = (int)v[2];
#endif
}


/*
**
** Disable all optimizations temporarily so this code works correctly!
**
*/
// #pragma optimize( "", off )

// /*
// ** --------------------------------------------------------------------------------
// **
// ** PROCESSOR STUFF
// **
// ** --------------------------------------------------------------------------------
// */
// static void CPUID( int func, unsigned regs[4] )
// {
// 	unsigned regEAX, regEBX, regECX, regEDX;

// #ifndef __VECTORC
// 	__asm mov eax, func
// 	__asm __emit 00fh
// 	__asm __emit 0a2h
// 	__asm mov regEAX, eax
// 	__asm mov regEBX, ebx
// 	__asm mov regECX, ecx
// 	__asm mov regEDX, edx

// 	regs[0] = regEAX;
// 	regs[1] = regEBX;
// 	regs[2] = regECX;
// 	regs[3] = regEDX;
// #else
// 	regs[0] = 0;
// 	regs[1] = 0;
// 	regs[2] = 0;
// 	regs[3] = 0;
// #endif
// }

// static int Is3DNOW( void )
// {
// 	unsigned regs[4];
// 	char pstring[16];
// 	char processorString[13];

// 	// get name of processor
// 	CPUID( 0, ( unsigned int * ) pstring );
// 	processorString[0] = pstring[4];
// 	processorString[1] = pstring[5];
// 	processorString[2] = pstring[6];
// 	processorString[3] = pstring[7];
// 	processorString[4] = pstring[12];
// 	processorString[5] = pstring[13];
// 	processorString[6] = pstring[14];
// 	processorString[7] = pstring[15];
// 	processorString[8] = pstring[8];
// 	processorString[9] = pstring[9];
// 	processorString[10] = pstring[10];
// 	processorString[11] = pstring[11];
// 	processorString[12] = 0;

// //  REMOVED because you can have 3DNow! on non-AMD systems
// //	if ( strcmp( processorString, "AuthenticAMD" ) )
// //		return qfalse;

// 	// check AMD-specific functions
// 	CPUID( 0x80000000, regs );
// 	if ( regs[0] < 0x80000000 )
// 		return qfalse;

// 	// bit 31 of EDX denotes 3DNOW! support
// 	CPUID( 0x80000001, regs );
// 	if ( regs[3] & ( 1 << 31 ) )
// 		return qtrue;

// 	return qfalse;
// }

// static int IsKNI( void )
// {
// 	unsigned regs[4];

// 	// get CPU feature bits
// 	CPUID( 1, regs );

// 	// bit 25 of EDX denotes KNI existence
// 	if ( regs[3] & ( 1 << 25 ) )
// 		return qtrue;

// 	return qfalse;
// }

// static int IsMMX( void )
// {
// 	unsigned regs[4];

// 	// get CPU feature bits
// 	CPUID( 1, regs );

// 	// bit 23 of EDX denotes MMX existence
// 	if ( regs[3] & ( 1 << 23 ) )
// 		return qtrue;
// 	return qfalse;
// }

// int Sys_GetProcessorId( void )
// {
// #if defined _M_ALPHA
// 	return CPUID_AXP;
// #elif !defined _M_IX86
// 	return CPUID_GENERIC;
// #else

// 	// verify we're at least a Pentium or 486 w/ CPUID support
// 	if ( !IsPentium() )
// 		return CPUID_INTEL_UNSUPPORTED;

// 	// check for MMX
// 	if ( !IsMMX() )
// 	{
// 		// Pentium or PPro
// 		return CPUID_INTEL_PENTIUM;
// 	}

// 	// see if we're an AMD 3DNOW! processor
// 	if ( Is3DNOW() )
// 	{
// 		return CPUID_AMD_3DNOW;
// 	}

// 	// see if we're an Intel Katmai
// 	if ( IsKNI() )
// 	{
// 		return CPUID_INTEL_KATMAI;
// 	}

// 	// by default we're functionally a vanilla Pentium/MMX or P2/MMX
// 	return CPUID_INTEL_MMX;

// #endif
// }

/*
**
** Re-enable optimizations back to what they were
**
*/
#pragma optimize( "", on )

//============================================

char *Sys_GetCurrentUser( void )
{
	static char s_userName[1024];
	unsigned long size = sizeof( s_userName );


	if ( !GetUserName( s_userName, &size ) )
		strcpy( s_userName, "player" );

	if ( !s_userName[0] )
	{
		strcpy( s_userName, "player" );
	}

	return s_userName;
}

char	*Sys_DefaultHomePath(void) {
	return NULL;
}

char *Sys_DefaultInstallPath(void)
{
	return Sys_Cwd();
}

