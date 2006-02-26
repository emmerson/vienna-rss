//
//  ImageAndTextCell.m
//  Vienna
//
//  Created by Steve on Sat Jan 24 2004.
//  Copyright (c) 2004-2005 Steve Palmer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ImageAndTextCell.h"
#import "BezierPathExtensions.h"

/* All of this stuff taken from public stuff published
 * by Apple.
 */

@implementation ImageAndTextCell

/* init
 * Initialise a default instance of our cell.
 */
-(id)init
{
	if ((self = [super init]) != nil)
	{
		image = nil;
		errorImage = nil;
		offset = 0;
		hasCount = NO;
		count = 0;
		[self setCountBackgroundColour:[NSColor shadowColor]];
	}
	return self;
}

-copyWithZone:(NSZone *)zone\
{
	ImageAndTextCell *cell = (ImageAndTextCell *)[super copyWithZone:zone];
	cell->image = [image retain];
	cell->errorImage = [errorImage retain];
	cell->offset = offset;
	cell->hasCount = hasCount;
	cell->count = count;
	cell->countBackgroundColour = [countBackgroundColour retain];
	return cell;
}

/* setOffset
 * Sets the new offset at which the cell contents will be drawn.
 */
-(void)setOffset:(int)newOffset
{
	offset = newOffset;
}

/* offset
 * Returns the current cell offset in effect.
 */
-(int)offset
{
	return offset;
}

/* setImage
 * Set the new image for the cell.
 */
-(void)setImage:(NSImage *)anImage
{
	[anImage retain];
	[image release];
	image = anImage;
}

/* image
 * Return the current image.
 */
-(NSImage *)image
{
	return [[image retain] autorelease];
}

/* setErrorImage
 * Sets the error image to be displayed. Nil removes any existing
 * error image.
 */
-(void)setErrorImage:(NSImage *)newErrorImage
{
	[newErrorImage retain];
	[errorImage release];
	errorImage = newErrorImage;
}

/* errorImage
 * Returns the current error image.
 */
-(NSImage *)errorImage
{
	return errorImage;
}

/* setCount
 * Sets the value to be displayed in the count button.
 */
-(void)setCount:(int)newCount
{
	count = newCount;
	hasCount = YES;
}

/* clearCount
 * Removes the count button.
 */
-(void)clearCount
{
	hasCount = NO;
}

/* setCountBackgroundColour
 * Sets the colour used for the count button background.
 */
-(void)setCountBackgroundColour:(NSColor *)newColour
{
	[newColour retain];
	[countBackgroundColour release];
	countBackgroundColour = newColour;
}

/* drawWithFrame
 * Draw the cell complete the image and count button if specified.
 */
-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	int drawingOffset = (offset * 10);
	int cellContentWidth;

	cellContentWidth = [self cellSizeForBounds:cellFrame].width;
	if (image != nil)
		cellContentWidth += [image size].width + 3;
	if (drawingOffset + cellContentWidth > cellFrame.size.width)
	{
		drawingOffset = cellFrame.size.width - cellContentWidth;
		if (drawingOffset < 0)
			drawingOffset = 0;
	}
	cellFrame.origin.x += drawingOffset;

	// If the cell has an image, draw the image and then reduce
	// cellFrame to move the text to the right of the image.
	if (image != nil)
	{
		NSSize imageSize;
		NSRect imageFrame;

		imageSize = [image size];
		NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
		if ([self drawsBackground])
		{
			[[self backgroundColor] set];
			NSRectFill(imageFrame);
		}
		imageFrame.origin.x += 3;
		imageFrame.size = imageSize;
		
		if ([controlView isFlipped])
			imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
		else
			imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
		
		[image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
	}

	// If we have an error image, it appears on the right hand side.
	if (errorImage)
	{
		NSSize imageSize;
		NSRect imageFrame;
		
		imageSize = [errorImage size];
		NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMaxXEdge);
		if ([self drawsBackground])
		{
			[[self backgroundColor] set];
			NSRectFill(imageFrame);
		}
		imageFrame.size = imageSize;
		
		if ([controlView isFlipped])
			imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
		else
			imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
		
		[errorImage compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
	}
	
	// If the cell has a count button, draw the count
	// button on the right of the cell.
	if (hasCount)
	{
		NSString * number = [NSString stringWithFormat:@"%i", count];

		// Use the current font point size as a guide for the count font size
		float pointSize = [[self font] pointSize];

		// Create attributes for drawing the count.
		NSDictionary * attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica-Bold" size:pointSize],
			NSFontAttributeName,
			[NSColor whiteColor],
			NSForegroundColorAttributeName,
			nil];
		NSSize numSize = [number sizeWithAttributes:attributes];

		// Compute the dimensions of the count rectangle.
		int cellWidth = MAX(numSize.width + 6, numSize.height + 1);

		NSRect countFrame;
		NSDivideRect(cellFrame, &countFrame, &cellFrame, cellWidth, NSMaxXEdge);
		if ([self drawsBackground])
		{
			[[self backgroundColor] set];
			NSRectFill(countFrame);
		}

		countFrame.origin.y += 1;
		countFrame.size.height -= 3;
		NSBezierPath * bp = [NSBezierPath bezierPathWithRoundRectInRect:countFrame radius:numSize.height / 2];
		[countBackgroundColour set];
		[bp fill];

		// Draw the count in the rounded rectangle we just created.
		NSPoint point = NSMakePoint(NSMidX(countFrame) - numSize.width / 2.0f,  NSMidY(countFrame) - numSize.height / 2.0f + 1.0f);
		[number drawAtPoint:point withAttributes:attributes];
		[attributes release];
	}

	// Draw the text
	[super drawWithFrame:cellFrame inView:controlView];
}

/* dealloc
 * Delete our resources.
 */
-(void)dealloc
{
	[countBackgroundColour release];
	[errorImage release];
	[image release];
	[super dealloc];
}
@end