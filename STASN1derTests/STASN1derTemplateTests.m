//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

#import "STASN1der.h"


@interface STASN1derTemplateTests : XCTestCase
@end

@implementation STASN1derTemplateTests

- (void)testTemplate1 {
	STASN1derTemplateObject * const template = [STASN1derSequenceObject templateObjectWithTemplateObjects:@[
		[STASN1derIntegerObject templateObject],
		[STASN1derIntegerObject templateObjectWithContextSpecificIdentifierTag:0],
		[STASN1derSequenceObject templateObjectWithContextSpecificIdentifierTag:1 templateObjects:@[
			[STASN1derBooleanObject templateObject],
			[STASN1derBooleanObject templateObjectWithContextSpecificIdentifierTag:0],
		]],
	]];
	XCTAssertNotNil(template, @"");
}

- (void)testSimple1 {
	char input_bytes[] = "\x01\x01\xff";
	unsigned long const input_len = sizeof(input_bytes) - 1;
	NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

	STASN1derTemplateObject * const template = [STASN1derBooleanObject templateObject];

	NSError *error = nil;
	STASN1derBooleanObject * const output = [STASN1derParser parseASN1Data:inputData withTemplate:template error:&error];
	XCTAssertNotNil(output, @"");
	XCTAssertNil(error, @"");

	XCTAssert([output isKindOfClass:[STASN1derBooleanObject class]], @"");
	XCTAssert(output.value, @"");
}

- (void)testSequence1 {
	char input_bytes[] = "\x30\x03\x01\x01\xff";
	unsigned long const input_len = sizeof(input_bytes) - 1;
	NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

	STASN1derTemplateObject * const template = [STASN1derSequenceObject templateObjectWithTemplateObjects:@[
		[STASN1derBooleanObject templateObject],
	]];

	NSError *error = nil;
	STASN1derBooleanObject * const output = [STASN1derParser parseASN1Data:inputData withTemplate:template error:&error];
	XCTAssertNotNil(output, @"");
	XCTAssertNil(error, @"");

	XCTAssert([output isKindOfClass:[STASN1derBooleanObject class]], @"");
	XCTAssert(output.value, @"");
}

@end
