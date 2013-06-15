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

- (void)testParseNULL {
	{
		char input_bytes[] = "\x05\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = [NSNull null];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}
}

- (void)testParseBOOLEAN {
	{
		char input_bytes[] = "\x01\x01\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = [NSNumber numberWithBool:0];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x01\x01\x01";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = [NSNumber numberWithBool:1];
		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = [NSNumber numberWithBool:1];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}
}

- (void)testParseINTEGER {
	{
		char input_bytes[] = "\x02\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = [NSNumber numberWithInteger:-1];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x02\x01\xfe";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = [NSNumber numberWithInteger:-2];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}
}

- (void)testParseOCTETSTRING {
	{
		char input_bytes[] = "\x04\x07\x04\x0A\x3B\x5F\x29\x1C\xD0";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		char expected_bytes[] = "\x04\x0A\x3B\x5F\x29\x1C\xD0";
		unsigned long const expected_len = sizeof(expected_bytes) - 1;
		id const expected = [[NSData alloc] initWithBytesNoCopy:expected_bytes length:expected_len freeWhenDone:NO];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}
}

- (void)testParseIA5STRING {
	{
		char input_bytes[] = "\x0C\x05Hello";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = @"Hello";

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}
}

- (void)testParseUTF8STRING {
	{
		char input_bytes[] = "\x16\x05Hello";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = @"Hello";

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}
}

- (void)testParseSEQUENCE {
	{
		char input_bytes[] = "\x30\x03\x01\x01\x00";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = @[ @NO ];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x30\x03\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = @[ @YES ];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x30\x06\x01\x01\x00\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = @[ @NO, @YES ];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}

	{
		char input_bytes[] = "\x30\x0a\x16\x05Smith\x01\x01\xff";
		unsigned long const input_len = sizeof(input_bytes) - 1;
		NSData *inputData = [[NSData alloc] initWithBytesNoCopy:input_bytes length:input_len freeWhenDone:NO];
		id const expected = @[ @"Smith", @YES ];

		NSError *error = nil;
		id const output = [STASNoneParser objectFromASN1Data:inputData error:&error];
		XCTAssertNotNil(output, @"error: %@", error);
		if (output) {
			XCTAssertEqualObjects(output, expected, @"");
		}
	}
}

@end
