//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STASN1der.h"


@interface STASN1derObject (STASN1derTemplatingSupport)
+ (enum STASN1derIdentifierTag)universalIdentifierTag;
@end

@interface STASN1derObject (STASN1derTemplating)
+ (STASN1derTemplateObject *)templateObject;
+ (STASN1derTemplateObject *)templateObjectWithContextSpecificIdentifierTag:(enum STASN1derIdentifierTag)identifierTag;
+ (STASN1derTemplateObject *)optionalTemplateObject;
+ (STASN1derTemplateObject *)optionalTemplateObjectWithContextSpecificIdentifierTag:(enum STASN1derIdentifierTag)identifierTag;
@end


@interface STASN1derTemplateObject ()
- (id)initWithIdentifierClass:(enum STASN1derIdentifierClass)identifierClass identifierTag:(enum STASN1derIdentifierTag)identifierTag class:(Class)klass optional:(BOOL)optional;
@property (nonatomic,assign,readonly) enum STASN1derIdentifierClass identifierClass;
@property (nonatomic,assign,readonly) enum STASN1derIdentifierTag identifierTag;
@property (nonatomic,strong,readonly) Class klass;
@property (nonatomic,assign,getter=isOptional,readonly) BOOL optional;
- (BOOL)matchesIdentifier:(struct STASN1derIdentifier)identifier;
@end
@implementation STASN1derTemplateObject
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)init { [self doesNotRecognizeSelector:_cmd]; return nil; }
#pragma clang diagnostic pop
- (id)initWithIdentifierClass:(enum STASN1derIdentifierClass)identifierClass identifierTag:(enum STASN1derIdentifierTag)identifierTag class:(Class)klass optional:(BOOL)optional {
	if ((self = [super init])) {
		_identifierClass = identifierClass;
		_identifierTag = identifierTag;
		_klass = klass;
		_optional = optional;
	}
	return self;
}
- (BOOL)matchesIdentifier:(struct STASN1derIdentifier)identifier {
	if (_identifierClass != identifier.class) {
		return NO;
	}
	if (_identifierTag != identifier.tag) {
		return NO;
	}
	return YES;
}
@end

@implementation STASN1derExplicitTemplateObject
+ (STASN1derTemplateObject *)templateObjectWithIdentifier:(struct STASN1derIdentifier)identifier template:(STASN1derTemplateObject *)object {
	return [[self alloc] initWithIdentifierClass:identifier.class identifierTag:identifier.tag class:nil optional:NO];
}
- (id)initWithIdentifierClass:(enum STASN1derIdentifierClass)identifierClass identifierTag:(enum STASN1derIdentifierTag)identifierTag class:(Class)klass optional:(BOOL)optional {
	if ((self = [super initWithIdentifierClass:identifierClass identifierTag:identifierTag class:klass optional:optional])) {
	}
	return self;
}
@end

@implementation STASN1derAnyTemplateObject
+ (STASN1derTemplateObject *)templateObject {
	return [[self alloc] init];
}
- (BOOL)matchesIdentifier:(struct STASN1derIdentifier)identifier {
	return YES;
}
@end

@interface STASN1derChoiceTemplateObject ()
@property (nonatomic,copy,readonly) NSArray *templateObjects;
@end
@implementation STASN1derChoiceTemplateObject
+ (STASN1derTemplateObject *)templateObjectWithTemplateObjects:(NSArray *)objects {
	return [[self alloc] initWithTemplateObjects:objects];
}
- (id)initWithIdentifierClass:(enum STASN1derIdentifierClass)identifierClass identifierTag:(enum STASN1derIdentifierTag)identifierTag class:(Class)klass optional:(BOOL)optional {
	return [self initWithTemplateObjects:nil];
}
- (id)initWithTemplateObjects:(NSArray *)objects {
	if ((self = [super initWithIdentifierClass:0 identifierTag:0 class:nil optional:NO])) {
		_templateObjects = objects.copy;
	}
	return self;
}
- (BOOL)matchesIdentifier:(struct STASN1derIdentifier)identifier {
	for (STASN1derTemplateObject *templateObject in _templateObjects) {
		if ([templateObject matchesIdentifier:identifier]) {
			return YES;
		}
	}
	return NO;
}
@end

@interface STASN1derSequenceTemplateObject : STASN1derTemplateObject
@property (nonatomic,copy,readonly) NSArray *templateObjects;
@end
@implementation STASN1derSequenceTemplateObject
- (id)initWithIdentifierClass:(enum STASN1derIdentifierClass)identifierClass identifierTag:(enum STASN1derIdentifierTag)identifierTag class:(Class)klass optional:(BOOL)optional templateObjects:(NSArray *)objects {
	if ((self = [super initWithIdentifierClass:identifierClass identifierTag:identifierTag class:klass optional:optional])) {
		_templateObjects = objects.copy;
	}
	return self;
}
@end

@interface STASN1derSetTemplateObject : STASN1derTemplateObject
@property (nonatomic,copy,readonly) NSArray *templateObjects;
@end
@implementation STASN1derSetTemplateObject
- (id)initWithIdentifierClass:(enum STASN1derIdentifierClass)identifierClass identifierTag:(enum STASN1derIdentifierTag)identifierTag class:(Class)klass optional:(BOOL)optional templateObjects:(NSArray *)objects {
	if ((self = [super initWithIdentifierClass:identifierClass identifierTag:identifierTag class:klass optional:optional])) {
		_templateObjects = objects.copy;
	}
	return self;
}
@end


@implementation STASN1derObject (STASN1derTemplating)
+ (STASN1derTemplateObject *)templateObject {
	Class const klass = self.class;
	if (![klass respondsToSelector:@selector(universalIdentifierTag)]) {
		return nil;
	}
	enum STASN1derIdentifierTag const identifierTag = [self.class universalIdentifierTag];
	return [[STASN1derTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassUniversal identifierTag:identifierTag class:klass optional:NO];
}
+ (STASN1derTemplateObject *)templateObjectWithContextSpecificIdentifierTag:(enum STASN1derIdentifierTag)identifierTag {
	Class const klass = self.class;
	return [[STASN1derTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassContextSpecific identifierTag:identifierTag class:klass optional:NO];
}
+ (STASN1derTemplateObject *)optionalTemplateObject {
	Class const klass = self.class;
	if (![klass respondsToSelector:@selector(universalIdentifierTag)]) {
		return nil;
	}
	enum STASN1derIdentifierTag const identifierTag = [self.class universalIdentifierTag];
	return [[STASN1derTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassUniversal identifierTag:identifierTag class:klass optional:YES];
}
+ (STASN1derTemplateObject *)optionalTemplateObjectWithContextSpecificIdentifierTag:(enum STASN1derIdentifierTag)identifierTag {
	Class const klass = self.class;
	return [[STASN1derTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassContextSpecific identifierTag:identifierTag class:klass optional:YES];
}
@end

@implementation STASN1derSequenceObject (STASN1derTemplating)
+ (STASN1derTemplateObject *)templateObjectWithTemplateObjects:(NSArray *)objects {
	return [[STASN1derSequenceTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassUniversal identifierTag:STASN1derIdentifierTagSEQUENCE class:self optional:NO templateObjects:objects];
}
+ (STASN1derTemplateObject *)templateObjectWithContextSpecificIdentifierTag:(enum STASN1derIdentifierTag)identifierTag templateObjects:(NSArray *)objects {
	return [[STASN1derSequenceTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassContextSpecific identifierTag:identifierTag class:self optional:NO templateObjects:objects];
}
@end

@implementation STASN1derSetObject (STASN1derTemplating)
+ (STASN1derTemplateObject *)templateObjectWithTemplateObjects:(NSArray *)objects {
	return [[STASN1derSetTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassUniversal identifierTag:STASN1derIdentifierTagSET class:self optional:NO templateObjects:objects];
}
+ (STASN1derTemplateObject *)templateObjectWithContextSpecificIdentifierTag:(enum STASN1derIdentifierTag)identifierTag templateObjects:(NSArray *)objects {
	return [[STASN1derSetTemplateObject alloc] initWithIdentifierClass:STASN1derIdentifierClassContextSpecific identifierTag:identifierTag class:self optional:NO templateObjects:objects];
}
@end


@implementation STASN1derParser (STASN1derTemplating)

+ (id)parseASN1Data:(NSData *)data withTemplate:(STASN1derTemplateObject *)template error:(NSError * __autoreleasing *)error {
	return [self st_parseASN1ObjectWithData:data template:template error:error];
//	Class const templateKlass = template.klass;
//	if ([templateKlass isSubclassOfClass:[STASN1derSequenceObject class]]) {
//		return [self st_parseASN1SequenceWithData:data template:template error:error];
//	} else if ([templateKlass isSubclassOfClass:[STASN1derSetObject class]]) {
//		return [self st_parseASN1SetWithData:data template:template error:error];
//	} else {
//	}
//	return nil;
}

+ (id)st_parseASN1ObjectWithData:(NSData *)data template:(STASN1derTemplateObject *)template error:(NSError *__autoreleasing *)error {
	return nil;
}

+ (id)st_parseASN1SequenceWithData:(NSData *)data template:(STASN1derTemplateObject *)template error:(NSError *__autoreleasing *)error {
	return nil;
}

+ (id)st_parseASN1SetWithData:(NSData *)data template:(STASN1derTemplateObject *)template error:(NSError *__autoreleasing *)error {
	return nil;
}

@end
