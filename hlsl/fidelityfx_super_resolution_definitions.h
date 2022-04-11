#ifndef _FIDELITYFX_SUPER_RESOLUTION_DEFINITIONS_H_
#define _FIDELITYFX_SUPER_RESOLUTION_DEFINITIONS_H_

#ifdef A_GPU
	#ifdef A_CPU
		#error A_CPU and A_GPU can't be defined at the same time!
	#endif

	#ifdef A_HALF
		#include "ffx_a.h"

		#if (AH4 != min16float4) || (AF2 != float2) || (ASW3 != min16int3) || (ASU2 != int2)
			#error Wrong defines for FSR header!
		#endif

		typedef AH4 A4;
		typedef AH3 A3;
		typedef AH2 A2;
		typedef AH1 A1;
		typedef ASW4 AS4;
		typedef ASW3 AS3;
		typedef ASW2 AS2;
		typedef ASW1 AS1;

		#ifdef FSR_EASU
			#define FSR_EASU_H

			A4 FsrEasuR(in float2 p);
			A4 FsrEasuG(in float2 p);
			A4 FsrEasuB(in float2 p);

			AH4 FsrEasuRH(AF2 p) { return FsrEasuR(p); }
			AH4 FsrEasuGH(AF2 p) { return FsrEasuG(p); }
			AH4 FsrEasuBH(AF2 p) { return FsrEasuB(p); }
		#endif

		#ifdef FSR_RCAS
			#define FSR_RCAS_H

			A4 FsrRcasLoad(in AS2 p);
			void FsrRcasInput(inout A1 r, inout A1 g, inout A1 b);

			AH4 FsrRcasLoadH(ASW2 p) { return FsrRcasLoad(p); }
			void FsrRcasInputH(inout AH1 r, inout AH1 g, inout AH1 b) { FsrRcasInput(r, g, b); }
		#endif

		#include "ffx_fsr1.h"

		#ifdef FSR_EASU
			void FsrEasu(out A3 pix, in AU2 ip, in AU4 con0, in AU4 con1, in AU4 con2, in AU4 con3)
			{
				FsrEasuH(pix, ip, con0, con1, con2, con3);
			}
		#endif

		#ifdef FSR_RCAS
			void FsrRcas(out A1 pixR, out A1 pixG, out A1 pixB, in AU2 ip, in AU4 con)
			{
				FsrRcasH(pixR, pixG, pixB, ip, con);
			}
		#endif
	#else
		#include "ffx_a.h"

		#if (AF4 != float4) || (AF2 != float2) || (ASU3 != int3) || (ASU2 != int2)
			#error Wrong defines for FSR header!
		#endif

		typedef AF4 A4;
		typedef AF3 A3;
		typedef AF2 A2;
		typedef AF1 A1;
		typedef ASU4 AS4;
		typedef ASU3 AS3;
		typedef ASU2 AS2;
		typedef ASU1 AS1;

		#ifdef FSR_EASU
			#define FSR_EASU_F

			A4 FsrEasuR(in float2 p);
			A4 FsrEasuG(in float2 p);
			A4 FsrEasuB(in float2 p);

			AF4 FsrEasuRF(AF2 p) { return FsrEasuR(p); }
			AF4 FsrEasuGF(AF2 p) { return FsrEasuG(p); }
			AF4 FsrEasuBF(AF2 p) { return FsrEasuB(p); }
		#endif

		#ifdef FSR_RCAS
			#define FSR_RCAS_F

			A4 FsrRcasLoad(in AS2 p);
			void FsrRcasInput(inout A1 r, inout A1 g, inout A1 b);

			AF4 FsrRcasLoadF(ASU2 p) { return FsrRcasLoad(p); }
			void FsrRcasInputF(inout AF1 r, inout AF1 g, inout AF1 b) { FsrRcasInput(r, g, b); }
		#endif

		#include "ffx_fsr1.h"

		#ifdef FSR_EASU
			void FsrEasu(out A3 pix, in AU2 ip, in AU4 con0, in AU4 con1, in AU4 con2, in AU4 con3)
			{
				FsrEasuF(pix, ip, con0, con1, con2, con3);
			}
		#endif

		#ifdef FSR_RCAS
			void FsrRcas(out A1 pixR, out A1 pixG, out A1 pixB, in AU2 ip, in AU4 con)
			{
				FsrRcasF(pixR, pixG, pixB, ip, con);
			}
		#endif
	#endif
#endif

#ifdef A_CPU
	#ifdef A_GPU
		#error A_CPU and A_GPU can't be defined at the same time!
	#endif

	#include "ffx_a.h"
	#include "ffx_fsr1.h"
#endif

#endif
