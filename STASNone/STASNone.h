//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


extern NSString * const STASNoneErrorDomain;
typedef NS_ENUM(NSUInteger, STASNoneErrorCode) {
	STASNoneErrorUnknown = 0,
	STASNoneErrorIdentifierInvalid,
	STASNoneErrorIdentifierUnsupported,
	STASNoneErrorUnexpectedEOD,
};


enum STASNoneIdentifierClass : NSUInteger {
	STASNoneIdentifierClassUniversal       = 0b00,
	STASNoneIdentifierClassApplication     = 0b01,
	STASNoneIdentifierClassContextSpecific = 0b10,
	STASNoneIdentifierClassPrivate         = 0b11,
};

enum STASNOneIdentifierTag : NSUInteger {
	STASNoneIdentifierTagEOC = 0b00000,
	STASNoneIdentifierTagBOOLEAN = 0b00001,
	STASNoneIdentifierTagINTEGER = 0b00010,
	STASNoneIdentifierTagBITSTRING = 0b00011,
	STASNoneIdentifierTagOCTETSTRING = 0b00100,
	STASNoneIdentifierTagNULL = 0b00101,
	STASNoneIdentifierTagOBJECTIDENTIFIER = 0b00110,
	STASNoneIdentifierTagOBJECTDESCRIPTOR = 0b00111,
	STASNoneIdentifierTagEXTERNAL = 0b01000,
	STASNoneIdentifierTagREAL = 0b01001,
	STASNoneIdentifierTagENUMERATED = 0b01010,
	STASNoneIdentifierTagEMBEDDEDPDV = 0b01011,
	STASNoneIdentifierTagUTF8STRING = 0b01100,
	STASNoneIdentifierTagRELATIVEOID = 0b01101,
	// 0b01110 reserved
	// 0b01111 reserved
	STASNoneIdentifierTagSEQUENCE = 0b10000,
	STASNoneIdentifierTagSET = 0b10001,
	STASNoneIdentifierTagNUMERICSTRING = 0b10010,
	STASNoneIdentifierTagPRINTABLESTRING = 0b10011,
	STASNoneIdentifierTagT61STRING = 0b10100,
	STASNoneIdentifierTagVIDEOTEXSTRING = 0b10101,
	STASNoneIdentifierTagIA5STRING = 0b10110,
	STASNoneIdentifierTagUTCTIME = 0b10111,
	STASNoneIdentifierTagGENERALIZEDTIME = 0b11000,
	STASNoneIdentifierTagGRAPHICSTRING = 0b11001,
	STASNoneIdentifierTagVISIBLESTRING = 0b11010,
	STASNoneIdentifierTagGENERALSTRING = 0b11011,
	STASNoneIdentifierTagUNIVERSALSTRING = 0b11100,
	STASNoneIdentifierTagCHARACTERSTRING = 0b11101,
	STASNoneIdentifierTagBMPSTRING = 0b11110,
	STASNoneIdentifierTagUSELONGFORM = 0b11111,
};


struct __attribute__((packed)) STASNoneIdentifier {
	enum STASNOneIdentifierTag tag : 5;
	bool constructed : 1;
	enum STASNoneIdentifierClass class : 2;
};

extern inline struct STASNoneIdentifier STASNoneIdentifierFromChar(unsigned char const c);

enum STASNoneIdentifierValidity {
	STASNoneIdentifierValid = 0,
	STASNoneIdentifierInvalid = 1,
	STASNoneIdentifierValidityUnknown = -1,
};
extern inline enum STASNoneIdentifierValidity STASNoneIdentifierValidate(struct STASNoneIdentifier identifier);
extern inline bool STASNoneIdentifierIsValid(struct STASNoneIdentifier identifier);
extern inline bool STASNoneIdentifierIsSupported(struct STASNoneIdentifier identifier);


@interface STASNoneParser : NSObject
+ (id)objectFromASN1Data:(NSData *)data error:(NSError * __autoreleasing *)error;
+ (NSArray *)objectsFromASN1Data:(NSData *)data error:(NSError * __autoreleasing *)error;
@end
