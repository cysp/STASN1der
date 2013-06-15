//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STASNone.h"


NSString * const STASNoneErrorDomain = @"STASNoneError";

inline struct STASNoneIdentifier STASNoneIdentifierFromChar(unsigned char const c) {
	union {
		unsigned char a;
		struct STASNoneIdentifier b;
	} x = { .a = c };
	return x.b;
}

inline enum STASNoneIdentifierValidity STASNoneIdentifierValidate(struct STASNoneIdentifier identifier) {
	switch (identifier.class) {
		case STASNoneIdentifierClassPrivate:
		case STASNoneIdentifierClassApplication:
		case STASNoneIdentifierClassContextSpecific:
			return STASNoneIdentifierValidityUnknown;
		case STASNoneIdentifierClassUniversal:
			break;
	}

	switch (identifier.tag) {
		case STASNoneIdentifierTagEOC:
		case STASNoneIdentifierTagBOOLEAN:
		case STASNoneIdentifierTagINTEGER:
			return !identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagBITSTRING:
		case STASNoneIdentifierTagOCTETSTRING:
			return STASNoneIdentifierValid;

		case STASNoneIdentifierTagNULL:
			return !identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagOBJECTIDENTIFIER:
			return identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagOBJECTDESCRIPTOR:
			return true;

		case STASNoneIdentifierTagEXTERNAL:
			return identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagREAL:
		case STASNoneIdentifierTagENUMERATED:
			return !identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagEMBEDDEDPDV:
			return identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagUTF8STRING:
			return STASNoneIdentifierValid;

		case STASNoneIdentifierTagRELATIVEOID:
			return !identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagSEQUENCE:
		case STASNoneIdentifierTagSET:
			return identifier.constructed ? STASNoneIdentifierValid : STASNoneIdentifierInvalid;

		case STASNoneIdentifierTagNUMERICSTRING:
		case STASNoneIdentifierTagPRINTABLESTRING:
		case STASNoneIdentifierTagT61STRING:
		case STASNoneIdentifierTagVIDEOTEXSTRING:
		case STASNoneIdentifierTagIA5STRING:
		case STASNoneIdentifierTagUTCTIME:
		case STASNoneIdentifierTagGENERALIZEDTIME:
		case STASNoneIdentifierTagGRAPHICSTRING:
		case STASNoneIdentifierTagVISIBLESTRING:
		case STASNoneIdentifierTagGENERALSTRING:
		case STASNoneIdentifierTagUNIVERSALSTRING:
		case STASNoneIdentifierTagCHARACTERSTRING:
		case STASNoneIdentifierTagBMPSTRING:
		case STASNoneIdentifierTagUSELONGFORM:
			return STASNoneIdentifierValid;
	}

	return false;
}

inline bool STASNoneIdentifierIsValid(struct STASNoneIdentifier identifier) {
	return STASNoneIdentifierValidate(identifier) == STASNoneIdentifierValid;
}


@interface STASNoneObject ()
- (id)initWithIdentifier:(struct STASNoneIdentifier)identifier content:(NSData *)content;
@end
@implementation STASNoneObject
- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}
- (id)initWithIdentifier:(struct STASNoneIdentifier)identifier content:(NSData *)content {
	if ((self = [super init])) {
		_identifier = identifier;
		_content = [content copy];
	}
	return self;
}
@end


@implementation STASNoneParser

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
			*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnexpectedEOD userInfo:nil];
		}
		return nil;
	}

	while (data_i < data_len) {
		struct STASNoneIdentifier identifier = STASNoneIdentifierFromChar(data_bytes[data_i++]);
		enum STASNoneIdentifierValidity identifierValidity = STASNoneIdentifierValidate(identifier);
		switch (identifierValidity) {
			case STASNoneIdentifierValid:
			case STASNoneIdentifierValidityUnknown:
				break;
			case STASNoneIdentifierInvalid:
				if (error) {
					*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorIdentifierInvalid userInfo:nil];
				}
				return nil;
		}

		if (data_i > data_len) {
			if (error) {
				*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnexpectedEOD userInfo:nil];
			}
			return nil;
		}

		unsigned char content_length_byte = data_bytes[data_i++];
		if (content_length_byte & 0x80) {
			if (error) {
				*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
			}
			return nil;
		}

		if (data_i > data_len) {
			if (error) {
				*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnexpectedEOD userInfo:nil];
			}
			return nil;
		}

		unsigned char const *content_bytes = &data_bytes[data_i];
		unsigned long content_len = content_length_byte;
		(void)content_bytes;

		data_i += content_len;
		if (data_i > data_len) {
			if (error) {
				*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnexpectedEOD userInfo:nil];
			}
			return nil;
		}

		switch (identifier.tag) {
			case STASNoneIdentifierTagEOC: {
				if (content_len != 0) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
			} break;

			case STASNoneIdentifierTagNULL: {
				if (content_len != 0) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				[objects addObject:[NSNull null]];
			} break;

			case STASNoneIdentifierTagBOOLEAN: {
				if (content_len != 1) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				bool value = content_bytes[0];
				[objects addObject:@(value)];
			} break;

			case STASNoneIdentifierTagINTEGER:
			case STASNoneIdentifierTagENUMERATED: {
				if (content_len == 0) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				long long value = 0;
				if (content_len > sizeof(value)) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
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

			case STASNoneIdentifierTagOCTETSTRING: {
				if (identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				id object = [[NSData alloc] initWithBytes:content_bytes length:content_len];
				[objects addObject:object];
			} break;

			case STASNoneIdentifierTagIA5STRING:
			case STASNoneIdentifierTagNUMERICSTRING:
			case STASNoneIdentifierTagPRINTABLESTRING:
			case STASNoneIdentifierTagVISIBLESTRING: {
				if (identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				id object = [[NSString alloc] initWithBytes:content_bytes length:content_len encoding:NSASCIIStringEncoding];
				[objects addObject:object];
			} break;

			case STASNoneIdentifierTagUTF8STRING: {
				if (identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				id object = [[NSString alloc] initWithBytes:content_bytes length:content_len encoding:NSUTF8StringEncoding];
				[objects addObject:object];
			} break;

			case STASNoneIdentifierTagSEQUENCE: {
				if (!identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				NSData *contentData = [[NSData alloc] initWithBytesNoCopy:(void *)content_bytes length:content_len freeWhenDone:NO];
				NSError *err = nil;
				NSArray *subobjects = [self objectsFromASN1Data:contentData error:&err];
				if (!subobjects) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				[objects addObject:subobjects];
			} break;

			case STASNoneIdentifierTagSET: {
				if (!identifier.constructed) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				NSData *contentData = [[NSData alloc] initWithBytesNoCopy:(void *)content_bytes length:content_len freeWhenDone:NO];
				NSError *err = nil;
				NSArray *subobjects = [self objectsFromASN1Data:contentData error:&err];
				if (!subobjects) {
					if (error) {
						*error = [NSError errorWithDomain:STASNoneErrorDomain code:STASNoneErrorUnknown userInfo:nil];
					}
					return nil;
				}
				[objects addObject:[NSSet setWithArray:subobjects]];
			} break;

			default: { //TODO
				NSData *contentData = [[NSData alloc] initWithBytes:content_bytes length:content_len];
				id object = [[STASNoneObject alloc] initWithIdentifier:identifier content:contentData];
				[objects addObject:object];
			} break;
		}
	}

	return objects;
}

@end
