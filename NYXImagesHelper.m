//
//  NYXImagesHelper.m
//  NYXImagesKit
//
//  Created by Matthias Tretter on 02/06/11.
//  Originally Created by @Nyx0uf on 02/05/11.
//  Copyright 2012 Benjamin Godard. All rights reserved.
//  www.cococabyss.com
//


#import "NYXImagesHelper.h"


static CGColorSpaceRef __rgbColorSpace = NULL;


CGContextRef NYXCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow)
{
	/// Use the generic RGB color space
	/// We avoid the NULL check because CGColorSpaceRelease() NULL check the value anyway, and worst case scenario = fail to create context
	/// Create the bitmap context, we want pre-multiplied ARGB, 8-bits per component
	CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, NYXGetRGBColorSpace(), kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);

	return bmContext;
}

// The following function was taken from the increadibly awesome HockeyKit
// Created by Peter Steinberger on 10.01.11.
// Copyright 2012 Peter Steinberger. All rights reserved.
CGImageRef NYXCreateGradientImage(const size_t pixelsWide, const size_t pixelsHigh, const CGFloat fromAlpha, const CGFloat toAlpha)
{
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 0, colorSpace, kCGImageAlphaNone);

	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {toAlpha, 1.0f, fromAlpha, 1.0f};

	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);

	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientEndPoint = CGPointZero;
	CGPoint gradientStartPoint = (CGPoint){.x = 0.0f, .y = pixelsHigh};

	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);

	// convert the context into a CGImageRef and release the context
	CGImageRef theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);

	// return the imageref containing the gradient
    return theCGImage;
}

CGColorSpaceRef NYXGetRGBColorSpace(void)
{
	if (!__rgbColorSpace)
	{
		__rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	}
	return __rgbColorSpace;
}