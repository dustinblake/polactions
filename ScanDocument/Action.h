/*
	This file is part of the PolActions collection of Automator actions.
	Copyright (C) 2008-2009 Pierre-Olivier Latour <info@pol-online.net>
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AvailabilityMacros.h>

#if defined(MAC_OS_X_VERSION_10_6) && (MAC_OS_X_VERSION_MAX_REQUIRED <= MAC_OS_X_VERSION_10_6)
#define IMAGE_CAPTURE_CORE_AVAILABLE 1
#endif

#import <Cocoa/Cocoa.h>
#import <Automator/Automator.h>
#ifdef IMAGE_CAPTURE_CORE_AVAILABLE
#import <ImageCaptureCore/ImageCaptureCore.h>
#endif

@interface ScanDocument : AMBundleAction
{
@private
	id							_result;
#ifdef IMAGE_CAPTURE_CORE_AVAILABLE
	ICDeviceBrowser*			_browser;
	ICScannerDevice*			_scanner;
#endif
}
@end
