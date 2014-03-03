//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


extern NSString * const STASN1derErrorDomain;
typedef NS_ENUM(NSUInteger, STASN1derErrorCode) {
	STASN1derErrorUnknown = 0,
	STASN1derErrorUnsupported,
	STASN1derErrorIdentifierInvalid,
	STASN1derErrorUnexpectedEOD,
	STASN1derErrorUnexpectedData,
};


enum STASN1derIdentifierClass : NSUInteger {
	STASN1derIdentifierClassUniversal       = 0b00,
	STASN1derIdentifierClassApplication     = 0b01,
	STASN1derIdentifierClassContextSpecific = 0b10,
	STASN1derIdentifierClassPrivate         = 0b11,
};

enum STASN1derIdentifierTag : NSUInteger {
	STASN1derIdentifierTagEOC = 0b00000,
	STASN1derIdentifierTagBOOLEAN = 0b00001,
	STASN1derIdentifierTagINTEGER = 0b00010,
	STASN1derIdentifierTagBITSTRING = 0b00011,
	STASN1derIdentifierTagOCTETSTRING = 0b00100,
	STASN1derIdentifierTagNULL = 0b00101,
	STASN1derIdentifierTagOBJECTIDENTIFIER = 0b00110,
	STASN1derIdentifierTagOBJECTDESCRIPTOR = 0b00111,
	STASN1derIdentifierTagEXTERNAL = 0b01000,
	STASN1derIdentifierTagREAL = 0b01001,
	STASN1derIdentifierTagENUMERATED = 0b01010,
	STASN1derIdentifierTagEMBEDDEDPDV = 0b01011,
	STASN1derIdentifierTagUTF8STRING = 0b01100,
	STASN1derIdentifierTagRELATIVEOID = 0b01101,
	// 0b01110 reserved
	// 0b01111 reserved
	STASN1derIdentifierTagSEQUENCE = 0b10000,
	STASN1derIdentifierTagSET = 0b10001,
	STASN1derIdentifierTagNUMERICSTRING = 0b10010,
	STASN1derIdentifierTagPRINTABLESTRING = 0b10011,
	STASN1derIdentifierTagT61STRING = 0b10100,
	STASN1derIdentifierTagVIDEOTEXSTRING = 0b10101,
	STASN1derIdentifierTagIA5STRING = 0b10110,
	STASN1derIdentifierTagUTCTIME = 0b10111,
	STASN1derIdentifierTagGENERALIZEDTIME = 0b11000,
	STASN1derIdentifierTagGRAPHICSTRING = 0b11001,
	STASN1derIdentifierTagVISIBLESTRING = 0b11010,
	STASN1derIdentifierTagGENERALSTRING = 0b11011,
	STASN1derIdentifierTagUNIVERSALSTRING = 0b11100,
	STASN1derIdentifierTagCHARACTERSTRING = 0b11101,
	STASN1derIdentifierTagBMPSTRING = 0b11110,
	STASN1derIdentifierTagUSELONGFORM = 0b11111,
};


struct __attribute__((packed)) STASN1derIdentifier {
	enum STASN1derIdentifierTag tag : 5;
	bool constructed : 1;
	enum STASN1derIdentifierClass class : 2;
};

extern struct STASN1derIdentifier STASN1derIdentifierFromChar(unsigned char const c);
extern BOOL STASN1derIdentifierEqual(struct STASN1derIdentifier a, struct STASN1derIdentifier b);

enum STASN1derIdentifierValidity {
	STASN1derIdentifierValid = 0,
	STASN1derIdentifierInvalid = 1,
	STASN1derIdentifierValidityUnknown = -1,
};
extern enum STASN1derIdentifierValidity STASN1derIdentifierValidate(struct STASN1derIdentifier identifier);
extern bool STASN1derIdentifierIsValid(struct STASN1derIdentifier identifier);
extern NSIndexPath *STASN1derObjectIdentifierIndexPathFromData(NSData *data);


@interface STASN1derObject : NSObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content __attribute__((objc_designated_initializer));
@property (nonatomic,assign,readonly) struct STASN1derIdentifier identifier;
@property (nonatomic,copy,readonly) NSData *content;
@end

@interface STASN1derEOCObject : STASN1derObject
@end

@interface STASN1derBooleanObject : STASN1derObject
@property (nonatomic,assign,readonly) BOOL value;
@end

@interface STASN1derIntegerObject : STASN1derObject
@property (nonatomic,assign,readonly) long long value;
@end

@interface STASN1derOctetStringObject : STASN1derObject
@property (nonatomic,copy,readonly) NSData *value;
@end

@interface STASN1derNullObject : STASN1derObject
@property (nonatomic,copy,readonly) NSNull *value;
@end

@interface STASN1derObjectIdentifierObject : STASN1derObject
@property (nonatomic,copy,readonly) NSIndexPath *value;
@end

@interface STASN1derEnumeratedObject : STASN1derObject
@property (nonatomic,assign,readonly) long long value;
@end

@interface STASN1derSequenceObject : STASN1derObject
@property (nonatomic,copy,readonly) NSArray *value;
@property (nonatomic,assign,readonly) NSUInteger count;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end

@interface STASN1derSetObject : STASN1derObject
@property (nonatomic,copy,readonly) NSArray *value;
@property (nonatomic,assign,readonly) NSUInteger count;
@end

@interface STASN1derRestrictedCharacterStringObject : STASN1derObject
@property (nonatomic,copy,readonly) NSString *value;
@end
@interface STASN1derUTF8StringObject : STASN1derRestrictedCharacterStringObject
@end
@interface STASN1derNumericStringObject : STASN1derRestrictedCharacterStringObject
@end
@interface STASN1derPrintableStringObject : STASN1derRestrictedCharacterStringObject
@end
@interface STASN1derIA5StringObject : STASN1derRestrictedCharacterStringObject
@end
@interface STASN1derVisibleStringObject : STASN1derRestrictedCharacterStringObject
@end
@interface STASN1derGeneralStringObject : STASN1derRestrictedCharacterStringObject
@end
@interface STASN1derUniversalStringObject : STASN1derRestrictedCharacterStringObject
@end
@interface STASN1derBMPStringObject : STASN1derUniversalStringObject
@end


@interface STASN1derParser : NSObject
+ (id)objectFromASN1Data:(NSData *)data error:(NSError * __autoreleasing *)error;
+ (NSArray *)objectsFromASN1Data:(NSData *)data error:(NSError * __autoreleasing *)error;
@end
