//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STASN1der.h"


NSString * const STASN1derErrorDomain = @"STASN1der";

inline struct STASN1derIdentifier STASN1derIdentifierFromChar(unsigned char const c) {
	union {
		unsigned char a;
		struct STASN1derIdentifier b;
	} x = { .a = c };
	return x.b;
}

BOOL STASN1derIdentifierEqual(struct STASN1derIdentifier a, struct STASN1derIdentifier b) {
	if (a.class != b.class) {
		return NO;
	}
	if (a.constructed != b.constructed) {
		return NO;
	}
	if (a.tag != b.tag) {
		return NO;
	}
	return YES;
}


inline enum STASN1derIdentifierValidity STASN1derIdentifierValidate(struct STASN1derIdentifier identifier) {
	switch (identifier.class) {
		case STASN1derIdentifierClassPrivate:
		case STASN1derIdentifierClassApplication:
		case STASN1derIdentifierClassContextSpecific:
			return STASN1derIdentifierValidityUnknown;
		case STASN1derIdentifierClassUniversal:
			break;
	}

	switch (identifier.tag) {
		case STASN1derIdentifierTagEOC:
		case STASN1derIdentifierTagBOOLEAN:
		case STASN1derIdentifierTagINTEGER:
			return !identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagBITSTRING:
		case STASN1derIdentifierTagOCTETSTRING:
			return STASN1derIdentifierValid;

		case STASN1derIdentifierTagNULL:
			return !identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagOBJECTIDENTIFIER:
			return !identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagOBJECTDESCRIPTOR:
			return STASN1derIdentifierValid;

		case STASN1derIdentifierTagEXTERNAL:
			return identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagREAL:
		case STASN1derIdentifierTagENUMERATED:
			return !identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagEMBEDDEDPDV:
			return identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagUTF8STRING:
			return STASN1derIdentifierValid;

		case STASN1derIdentifierTagRELATIVEOID:
			return !identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagSEQUENCE:
		case STASN1derIdentifierTagSET:
			return identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagNUMERICSTRING:
		case STASN1derIdentifierTagPRINTABLESTRING:
		case STASN1derIdentifierTagT61STRING:
		case STASN1derIdentifierTagVIDEOTEXSTRING:
		case STASN1derIdentifierTagIA5STRING:
		case STASN1derIdentifierTagUTCTIME:
		case STASN1derIdentifierTagGENERALIZEDTIME:
		case STASN1derIdentifierTagGRAPHICSTRING:
		case STASN1derIdentifierTagVISIBLESTRING:
		case STASN1derIdentifierTagGENERALSTRING:
		case STASN1derIdentifierTagUNIVERSALSTRING:
		case STASN1derIdentifierTagCHARACTERSTRING:
		case STASN1derIdentifierTagBMPSTRING:
		case STASN1derIdentifierTagUSELONGFORM:
			return STASN1derIdentifierValid;
	}

	return false;
}

inline bool STASN1derIdentifierIsValid(struct STASN1derIdentifier identifier) {
	return STASN1derIdentifierValidate(identifier) == STASN1derIdentifierValid;
}


NSIndexPath *STASN1derObjectIdentifierIndexPathFromData(NSData *data) {
	uint8_t const * const bytes = data.bytes;
	size_t const bytesLength = data.length;

	NSUInteger indexes[bytesLength];
	NSUInteger nIndexes = 0;

	if (bytesLength > 0) {
		uint8_t const byte = bytes[0];
		indexes[nIndexes++] = byte / 40;
		indexes[nIndexes++] = byte % 40;
	}
	NSUInteger accumulator = 0;
	for (NSUInteger i = 1; i < bytesLength; ++i) {
		uint8_t const byte = bytes[i];
		accumulator |= byte & 0x7f;
		if (byte & 0x80) {
			accumulator <<= 7;
		} else {
			indexes[nIndexes++] = accumulator;
			accumulator = 0;
		}
	}
	NSIndexPath * const indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:nIndexes];
	return indexPath;
}

@class STASN1derPlaceholderObject;
static STASN1derPlaceholderObject *gSTASN1derPlaceholderObject = nil;
@interface STASN1derPlaceholderObject : NSObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content;
@end

@implementation STASN1derObject
+ (void)initialize {
	gSTASN1derPlaceholderObject = [STASN1derPlaceholderObject alloc];
}
+ (id)alloc {
	if (self == [STASN1derObject class]) {
		return (id)gSTASN1derPlaceholderObject;
	}
	return [super alloc];
}
+ (id)st_alloc {
	return [super alloc];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)init { [self doesNotRecognizeSelector:_cmd]; return nil; }
#pragma clang diagnostic pop
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	if ((self = [super init])) {
		_identifier = identifier;
		_content = [content copy];
	}
	return self;
}
- (NSString *)valueDescription { return nil; }
- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p %d.%c.%d>", NSStringFromClass([self class]), self, _identifier.class, "pc"[_identifier.constructed], _identifier.tag];
}
- (NSString *)debugDescription {
	NSString * const valueDescription = [self valueDescription];
	if (valueDescription) {
		return [NSString stringWithFormat:@"<%@:%p %d.%c.%d [%@]>", NSStringFromClass([self class]), self, _identifier.class, "pc"[_identifier.constructed], _identifier.tag, valueDescription];
	}
	return [self description];
}
@end
@implementation STASN1derPlaceholderObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	Class klass = nil;

	if (identifier.class == STASN1derIdentifierClassUniversal) switch (identifier.tag) {
		case STASN1derIdentifierTagEOC: {
			klass = [STASN1derEOCObject class];
		} break;
		case STASN1derIdentifierTagNULL: {
			klass = [STASN1derNullObject class];
		} break;
		case STASN1derIdentifierTagBOOLEAN: {
			klass = [STASN1derBooleanObject class];
		} break;
		case STASN1derIdentifierTagINTEGER: {
			klass = [STASN1derIntegerObject class];
		} break;
		case STASN1derIdentifierTagENUMERATED: {
			klass = [STASN1derEnumeratedObject class];
		} break;
		case STASN1derIdentifierTagOBJECTIDENTIFIER: {
			klass = [STASN1derObjectIdentifierObject class];
		} break;
		case STASN1derIdentifierTagOCTETSTRING: {
			klass = [STASN1derOctetStringObject class];
		} break;
		case STASN1derIdentifierTagIA5STRING: {
			klass = [STASN1derIA5StringObject class];
		} break;
		case STASN1derIdentifierTagNUMERICSTRING: {
			klass = [STASN1derNumericStringObject class];
		} break;
		case STASN1derIdentifierTagPRINTABLESTRING: {
			klass = [STASN1derPrintableStringObject class];
		} break;
		case STASN1derIdentifierTagVISIBLESTRING: {
			klass = [STASN1derVisibleStringObject class];
		} break;
		case STASN1derIdentifierTagUTF8STRING: {
			klass = [STASN1derUTF8StringObject class];
		} break;
		case STASN1derIdentifierTagUNIVERSALSTRING: {
			klass = [STASN1derUniversalStringObject class];
		} break;
		case STASN1derIdentifierTagBMPSTRING: {
			klass = [STASN1derBMPStringObject class];
		} break;
		case STASN1derIdentifierTagSEQUENCE: {
			klass = [STASN1derSequenceObject class];
		} break;
		case STASN1derIdentifierTagSET: {
			klass = [STASN1derSetObject class];
		} break;
		default: { //TODO
		} break;
	}
	id object = [[klass st_alloc] initWithIdentifier:identifier content:content];
	if (!object) {
		object = [[STASN1derObject st_alloc] initWithIdentifier:identifier content:content];
	}
	return object;
}
@end


@implementation STASN1derEOCObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	if (content.length != 0) {
		return nil;
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
	}
	return self;
}
@end

@implementation STASN1derBooleanObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	if (content.length != 1) {
		return nil;
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		uint8_t byte = 0;
		[content getBytes:&byte length:1];
		_value = !!byte;
	}
	return self;
}
- (NSString *)valueDescription {
	return [NSString stringWithFormat:@"%d", _value];
}
@end

@implementation STASN1derIntegerObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	NSUInteger const content_len = content.length;
	uint8_t const * const content_bytes = content.bytes;
	if (content_len == 0) {
		return nil;
	}
	long long value = 0;
	if (content_len > sizeof(value)) {
		return nil;
	}
	bool const is_negative = content_bytes[0] & 0x80;
	if (is_negative) {
		value = -1;
	}
	for (unsigned int content_i = 0; content_i < content_len; ++content_i) {
		value <<= 8;
		value |= content_bytes[content_i];
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = value;
	}
	return self;
}
- (NSString *)valueDescription {
	return [NSString stringWithFormat:@"%lld", _value];
}
@end

@implementation STASN1derOctetStringObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	if (identifier.constructed) {
		return nil;
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = content;
	}
	return self;
}
- (NSString *)valueDescription {
	return [NSString stringWithFormat:@"%lu bytes", _value.length];
}
@end

@implementation STASN1derNullObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	if (content.length != 0) {
		return nil;
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = [NSNull null];
	}
	return self;
}
@end


@implementation STASN1derObjectIdentifierObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = STASN1derObjectIdentifierIndexPathFromData(content);
	}
	return self;
}
- (NSString *)valueDescription {
	NSString *valueString = nil;
	NSIndexPath * const value = self.value;
	if (value) {
		NSMutableString * const oidContentString = @"".mutableCopy;
		for (NSUInteger i = 0; i < value.length; ++i) {
			if (i != 0) {
				[oidContentString appendString:@"."];
			}
			[oidContentString appendFormat:@"%ld", [value indexAtPosition:i]];
		}
		valueString = oidContentString;
	} else {
		valueString = self.content.description;
	}
	return valueString;
}
@end

@implementation STASN1derEnumeratedObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	NSUInteger const content_len = content.length;
	uint8_t const * const content_bytes = content.bytes;
	if (content_len == 0) {
		return nil;
	}
	long long value = 0;
	if (content_len > sizeof(value)) {
		return nil;
	}
	bool const is_negative = content_bytes[0] & 0x80;
	if (is_negative) {
		value = -1;
	}
	for (unsigned int content_i = 0; content_i < content_len; ++content_i) {
		value <<= 8;
		value |= content_bytes[content_i];
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = value;
	}
	return self;
}
- (NSString *)valueDescription {
	return [NSString stringWithFormat:@"%lld", _value];
}
@end

@implementation STASN1derSequenceObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	NSUInteger const content_len = content.length;
	void const * const content_bytes = content.bytes;
	NSData *contentData = [[NSData alloc] initWithBytesNoCopy:(void *)content_bytes length:content_len freeWhenDone:NO];
	NSError *err = nil;
	NSArray *subobjects = [STASN1derParser objectsFromASN1Data:contentData error:&err];
	if (!subobjects) {
		return nil;
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = subobjects.copy;
	}
	return self;
}
- (NSUInteger)count {
	return _value.count;
}
- (id)objectAtIndex:(NSUInteger)index {
	return [_value objectAtIndex:index];
}
- (id)objectAtIndexedSubscript:(NSUInteger)index {
	return [_value objectAtIndexedSubscript:index];
}
- (NSString *)valueDescription {
	return [NSString stringWithFormat:@"%lu objects", _value.count];
}
@end

@implementation STASN1derSetObject : STASN1derObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	NSUInteger const content_len = content.length;
	void const * const content_bytes = content.bytes;
	NSData *contentData = [[NSData alloc] initWithBytesNoCopy:(void *)content_bytes length:content_len freeWhenDone:NO];
	NSError *err = nil;
	NSArray *subobjects = [STASN1derParser objectsFromASN1Data:contentData error:&err];
	if (!subobjects) {
		return nil;
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = subobjects.copy;
	}
	return self;
}
- (NSUInteger)count {
	return _value.count;
}
- (NSString *)valueDescription {
	return [NSString stringWithFormat:@"%lu objects", _value.count];
}
@end

@implementation STASN1derRestrictedCharacterStringObject
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	return [self initWithIdentifier:identifier content:content encoding:NSUTF8StringEncoding];
}
#pragma clang diagnostic pop
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content encoding:(NSStringEncoding)encoding {
	if (identifier.constructed) {
		return nil;
	}
	NSString * const value = [[NSString alloc] initWithData:content encoding:encoding];
	if (!value) {
		return nil;
	}
	if ((self = [super initWithIdentifier:identifier content:content])) {
		_value = value;
	}
	return self;
}
- (NSString *)valueDescription {
	return _value;
}
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
@implementation STASN1derUTF8StringObject
@end

@implementation STASN1derNumericStringObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	return [super initWithIdentifier:identifier content:content encoding:NSASCIIStringEncoding];
}
@end

@implementation STASN1derPrintableStringObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	return [super initWithIdentifier:identifier content:content encoding:NSASCIIStringEncoding];
}
@end

@implementation STASN1derIA5StringObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	return [super initWithIdentifier:identifier content:content encoding:NSASCIIStringEncoding];
}
@end

@implementation STASN1derVisibleStringObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	return [super initWithIdentifier:identifier content:content encoding:NSASCIIStringEncoding];
}
@end

@implementation STASN1derGeneralStringObject
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	return [super initWithIdentifier:identifier content:content encoding:NSASCIIStringEncoding];
}
@end

@implementation STASN1derUniversalStringObject
@end

@implementation STASN1derBMPStringObject
@end
#pragma clang diagnostic pop


@implementation STASN1derParser

+ (id)objectFromASN1Data:(NSData *)data error:(NSError *__autoreleasing *)error {
	NSArray * const objects = [self objectsFromASN1Data:data error:error];
	if (objects.count > 1) {
		if (error) {
			*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnexpectedData userInfo:nil];
		}
		return nil;
	}
	return [objects firstObject];
}

+ (NSArray *)objectsFromASN1Data:(NSData *)data error:(NSError *__autoreleasing *)error {
	NSUInteger data_len = [data length];
	unsigned char const *data_bytes = [data bytes];

	NSMutableArray * const objects = [[NSMutableArray alloc] init];

	unsigned long data_i = 0;
	if (data_i >= data_len) {
		if (error) {
			*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnexpectedEOD userInfo:nil];
		}
		return nil;
	}

	while (data_i < data_len) {
		struct STASN1derIdentifier identifier = STASN1derIdentifierFromChar(data_bytes[data_i++]);
		enum STASN1derIdentifierValidity identifierValidity = STASN1derIdentifierValidate(identifier);
		switch (identifierValidity) {
			case STASN1derIdentifierValid:
			case STASN1derIdentifierValidityUnknown:
				break;
			case STASN1derIdentifierInvalid:
				if (error) {
					*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorIdentifierInvalid userInfo:nil];
				}
				return nil;
		}

		if (data_i > data_len) {
			if (error) {
				*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnexpectedEOD userInfo:nil];
			}
			return nil;
		}

		unsigned long content_len = 0;
		bool content_len_indefinite = false;

		uint8_t content_length_byte = data_bytes[data_i++];
		if (content_length_byte & 0x80) {
			uint8_t content_length_len = content_length_byte & 0x7f;
			if (content_length_len == 0) {
				content_len_indefinite = true;
			} else {
				if (content_length_len > sizeof(content_len)) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				if (data_i + content_length_len > data_len) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnexpectedEOD userInfo:nil];
					}
					return nil;
				}
				unsigned char const *content_length_bytes = &data_bytes[data_i];
				data_i += content_length_len;
				for (unsigned int content_length_i = 0; content_length_i < content_length_len; ++content_length_i) {
					content_len <<= 8;
					content_len |= content_length_bytes[content_length_i];
				}
			}
		} else {
			content_len = content_length_byte;
		}

		// TODO support indefinite content lengths
		if (content_len_indefinite) {
			if (error) {
				*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnsupported userInfo:nil];
			}
			return nil;
		}

		if (data_i > data_len) {
			if (error) {
				*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnexpectedEOD userInfo:nil];
			}
			return nil;
		}

		unsigned char const *content_bytes = &data_bytes[data_i];

		data_i += content_len;
		if (data_i > data_len) {
			if (error) {
				*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnexpectedEOD userInfo:nil];
			}
			return nil;
		}

		NSData *contentData = [[NSData alloc] initWithBytes:content_bytes length:content_len];
		id object = [[STASN1derObject alloc] initWithIdentifier:identifier content:contentData];
		[objects addObject:object];
	}

	return objects;
}

@end
