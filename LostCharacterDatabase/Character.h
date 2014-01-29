//
//  Character.h
//  LostCharacterDatabase
//
//  Created by Apple on 28/01/14.
//  Copyright (c) 2014 Tablified Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Character : NSManagedObject

@property (nonatomic, retain) NSString * actor;
@property (nonatomic, retain) NSString * passenger;
@property (nonatomic, retain) NSNumber * appearances;

@end
