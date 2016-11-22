/** Function to compute the foreground probability in each superpixel
%
%    Copyright (C) 2015  Tianfei Zhou
%
%    You can redistribute and/or modify this software for non-commercial use
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    For commercial use, contact the author for licensing options.
%
%    Contact: tfzhou@bit.edu.cn */

/** Expected inputs:
			1 - Superpixel label map: a HxW uint16 matrix specifying
				the superpixel each pixel belongs to
			2 - prob map: a HxW double matrix containing specifying
				whether a pixel is in (true) or out (false)
		Optional inputs:
			3 - Number of superpixels

		Outputs:
			1 - Superpixel prob: an Nx1 array of type single, containing
				the sum of the pixel values in each superpixel. N corresponds
				to the number of 
*/

#include <matrix.h>
#include <mex.h>

void mexFunction( int nlhs, mxArray *plhs[], int nrhs,
	const mxArray *prhs[] )
{
	switch( nrhs )
	{
		case 2:
			if( mxGetClassID( prhs[ 0 ] ) != mxUINT16_CLASS )
				mexErrMsgTxt( "Superpixel label map must be of type uint16" );
			if( mxGetClassID( prhs[ 1 ] ) != mxDOUBLE_CLASS )
				mexErrMsgTxt( "Foreground probability map must be of type double" );
			break;
		case 3:
			if( mxGetClassID( prhs[ 0 ] ) != mxUINT16_CLASS )
				mexErrMsgTxt( "Super pixel label map must be of type uint16" );
			if( mxGetClassID( prhs[ 1 ] ) != mxLOGICAL_CLASS )
				mexErrMsgTxt( "Foreground probability map must be of type uint16" );
			if( mxGetClassID( prhs[ 2 ] ) != mxUINT16_CLASS )
				mexErrMsgTxt( "Number of superpixels must be of type uint16" );
			break;
		default:
			mexErrMsgTxt( "Invalid number of input arguments" );
	}

	switch( nlhs )
	{
		case 0:
			break;
		case 1:
			break;
		case 2:
			break;
		default:
			mexErrMsgTxt( "Invalid number of output arguments" );
	}

	if( mxGetNumberOfDimensions( prhs[ 0 ] ) != 2 )
		mexErrMsgTxt( "Superpixel label map must be 2-dimensional" );
		
	if( mxGetNumberOfDimensions( prhs[ 1 ] ) != 2 )
		mexErrMsgTxt( "Foreground probability map must be 2-dimensional" );

	int height = mxGetM( (mxArray *)prhs[ 0 ] );
	int width = mxGetN( (mxArray *)prhs[ 0 ] );
	//mexPrintf( "Matrix size: ( %i, %i )\n", height, width );
	
	unsigned short *superpixels = ( unsigned short * )mxGetData( prhs[ 0 ] );
	double *fgProbMap = ( double * )mxGetData( prhs[ 1 ] );
	
	/** Get the number of superpixels */
	unsigned short labels;
	if( nrhs == 3 )
	{
		/** If number of superpixels is given, just use that */
		labels = ( ( unsigned short * )( mxGetData( prhs[ 2 ] ) ) )[ 0 ];
	}
	else
	{
		/** If number of superpixels is not given, find the largest label */
		labels = 0;
		int point;
		for( int i = 0; i < height; i++ )
		{
			for( int j = 0; j < width; j++ )
			{
				point = j * height + i;
				if( superpixels[ point ] > labels )
					labels = superpixels[ point ];
			}
		}
	}
	
	/** Create the output (superpixel metric) matrix */
	mxArray *output = mxCreateNumericMatrix( labels, 1, mxSINGLE_CLASS, mxREAL );
	float *outData = ( float * )mxGetData( output );

	mxArray *spixelSizeMxArray = mxCreateNumericMatrix( labels, 1, mxUINT32_CLASS, mxREAL );
	unsigned int *spixelSize = ( unsigned int * )mxGetData( spixelSizeMxArray );
	
	
	/** Compute the superpixel metric matrix */
	int point;
	for( int i = 0; i < height; i++ )
	{
		for( int j = 0; j < width; j++ )
		{
			point = j * height + i;
      
      outData[ superpixels[ point ] - 1 ] += fgProbMap[ point ];
      
			spixelSize[ superpixels[ point ] - 1 ]++;
		}
	}

	for( int label = 0; label < labels; label++ )
	{
		if( spixelSize[ label ] > 0 )
			outData[ label ] = outData[ label ] / float( spixelSize[ label ] );
	}

	plhs[ 0 ] = output;

	if( nlhs == 2 )
		plhs[ 1 ] = spixelSizeMxArray;

}
