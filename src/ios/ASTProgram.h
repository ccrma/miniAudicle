//
//  ASTProgram.h
//  miniAudicle
//
//  Created by Spencer Salazar on 2/21/16.
//
//

#import <Foundation/Foundation.h>


@protocol ASTObject <NSObject>

- (NSString *)render;

@end


@interface ASTProgram : NSObject<ASTObject>

@property (nonatomic) NSArray *structures;

@end

@interface ASTStatement : NSObject<ASTObject>

@end


@class ASTExpression;

@interface ASTExpressionStatement : ASTStatement<ASTObject>

@property (nonatomic) ASTExpression *expression;

@end

@interface ASTExpression : NSObject<ASTObject>

@end

@interface ASTChuckExpression : ASTExpression<ASTObject>

@property (nonatomic) ASTExpression *left;
@property (nonatomic) ASTExpression *right;

@end

@interface ASTDeclaration : ASTExpression<ASTObject>

@property (nonatomic) NSString *type;
@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger array;

@end


