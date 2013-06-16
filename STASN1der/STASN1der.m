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
			return identifier.constructed ? STASN1derIdentifierValid : STASN1derIdentifierInvalid;

		case STASN1derIdentifierTagOBJECTDESCRIPTOR:
			return true;

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


@interface STASN1derObject ()
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content;
@end
@implementation STASN1derObject
- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}
- (id)initWithIdentifier:(struct STASN1derIdentifier)identifier content:(NSData *)content {
	if ((self = [super init])) {
		_identifier = identifier;
		_content = [content copy];
	}
	return self;
}
@end


@implementation STASN1derParser

+ (id)objectFromASN1Data:(NSData *)data error:(NSError *__autoreleasing *)error {
	NSArray * const objects = [self objectsFromASN1Data:data error:error];
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

		// TODO content lengths > 0x7f
		unsigned char content_length_byte = data_bytes[data_i++];
		if (content_length_byte & 0x80) {
			if (error) {
				*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
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
		unsigned long content_len = content_length_byte;
		(void)content_bytes;

		data_i += content_len;
		if (data_i > data_len) {
			if (error) {
				*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnexpectedEOD userInfo:nil];
			}
			return nil;
		}

		switch (identifier.tag) {
			case STASN1derIdentifierTagEOC: {
				if (content_len != 0) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
			} break;

			case STASN1derIdentifierTagNULL: {
				if (content_len != 0) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				[objects addObject:[NSNull null]];
			} break;

			case STASN1derIdentifierTagBOOLEAN: {
				if (content_len != 1) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				bool value = content_bytes[0];
				[objects addObject:@(value)];
			} break;

			case STASN1derIdentifierTagINTEGER:
			case STASN1derIdentifierTagENUMERATED: {
				if (content_len == 0) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				long long value = 0;
				if (content_len > sizeof(value)) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
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
				[objects addObject:@(value)];
			} break;

			case STASN1derIdentifierTagOCTETSTRING: {
				if (identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				id object = [[NSData alloc] initWithBytes:content_bytes length:content_len];
				[objects addObject:object];
			} break;

			case STASN1derIdentifierTagIA5STRING:
			case STASN1derIdentifierTagNUMERICSTRING:
			case STASN1derIdentifierTagPRINTABLESTRING:
			case STASN1derIdentifierTagVISIBLESTRING: {
				if (identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				id object = [[NSString alloc] initWithBytes:content_bytes length:content_len encoding:NSASCIIStringEncoding];
				[objects addObject:object];
			} break;

			case STASN1derIdentifierTagUTF8STRING: {
				if (identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				id object = [[NSString alloc] initWithBytes:content_bytes length:content_len encoding:NSUTF8StringEncoding];
				[objects addObject:object];
			} break;

			case STASN1derIdentifierTagSEQUENCE: {
				if (!identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				NSData *contentData = [[NSData alloc] initWithBytesNoCopy:(void *)content_bytes length:content_len freeWhenDone:NO];
				NSError *err = nil;
				NSArray *subobjects = [self objectsFromASN1Data:contentData error:&err];
				if (!subobjects) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				[objects addObject:subobjects];
			} break;

			case STASN1derIdentifierTagSET: {
				if (!identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				NSData *contentData = [[NSData alloc] initWithBytesNoCopy:(void *)content_bytes length:content_len freeWhenDone:NO];
				NSError *err = nil;
				NSArray *subobjects = [self objectsFromASN1Data:contentData error:&err];
				if (!subobjects) {
					if (error) {
						*error = [NSError errorWithDomain:STASN1derErrorDomain code:STASN1derErrorUnknown userInfo:nil];
					}
					return nil;
				}
				[objects addObject:[NSSet setWithArray:subobjects]];
			} break;

			default: { //TODO
				NSData *contentData = [[NSData alloc] initWithBytes:content_bytes length:content_len];
				id object = [[STASN1derObject alloc] initWithIdentifier:identifier content:contentData];
				[objects addObject:object];
			} break;
		}
	}

	return objects;
}

@end
