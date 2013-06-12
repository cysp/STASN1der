//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

#import "STASNone.h"


@interface STASNoneTests : XCTestCase
@end

@implementation STASNoneTests

- (void)testIdentifierExtraction {
	struct identifier_testcase {
		unsigned char const input;
		struct STASNoneIdentifier const expected;
		enum STASNoneIdentifierValidity const validity;
	} const testcases[] = {
		{
			.input = 0x00,
			.expected = { .class = STASNoneIdentifierClassUniversal, .constructed = false, .tag = STASNoneIdentifierTagEOC },
			.validity = STASNoneIdentifierValid,
		},
		{
			.input = 0x20,
			.expected = { .class = STASNoneIdentifierClassUniversal, .constructed = true, .tag = STASNoneIdentifierTagEOC },
			.validity = STASNoneIdentifierInvalid,
		},
		{
			.input = 0x01,
			.expected = { .class = STASNoneIdentifierClassUniversal, .constructed = false, .tag = STASNoneIdentifierTagBOOLEAN },
			.validity = STASNoneIdentifierValid,
		},
		{
			.input = 0x02,
			.expected = { .class = STASNoneIdentifierClassUniversal, .constructed = false, .tag = STASNoneIdentifierTagINTEGER },
			.validity = STASNoneIdentifierValid,
		},
		{
			.input = 0x10,
			.expected = { .class = STASNoneIdentifierClassUniversal, .constructed = false, .tag = STASNoneIdentifierTagSEQUENCE },
			.validity = STASNoneIdentifierInvalid,
		},
		{
			.input = 0x30,
			.expected = { .class = STASNoneIdentifierClassUniversal, .constructed = true, .tag = STASNoneIdentifierTagSEQUENCE },
			.validity = STASNoneIdentifierValid,
		},
	};
	unsigned int const ntestcases = sizeof(testcases) / sizeof(testcases[0]);

	for (unsigned int i = 0; i < ntestcases; ++i) {
		struct identifier_testcase testcase = testcases[i];
		struct STASNoneIdentifier const output = STASNoneIdentifierFromChar(testcase.input);
		enum STASNoneIdentifierValidity const validity = STASNoneIdentifierValidate(output);

		bool equal = !memcmp(&testcase.expected, &output, sizeof(testcase.expected));
		XCTAssertTrue(equal, @"");

		XCTAssertEquals(testcase.validity, validity, @"");
	}
}

- (void)testParseFailure {
	{
		char input_bytes[] = "\x01\x01";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEquals(error.code, (NSInteger)STASNoneErrorUnexpectedEOD, @"");
	}

	{
		char input_bytes[] = "\x01\x04\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEquals(error.code, (NSInteger)STASNoneErrorUnexpectedEOD, @"");
	}

	{
		char input_bytes[] = "\x00\x00\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNil(output, @"error: %@", error);
		XCTAssertEquals(error.code, (NSInteger)STASNoneErrorUnexpectedEOD, @"");
	}
}

@end
