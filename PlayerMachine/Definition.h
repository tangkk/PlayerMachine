//
//  Definition.h
//  PlayerMachine
//
//  Created by tangkk on 16/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//


#define AnimateArrayLength 10
#define RegLength 5
#define GridSize 6
#define LabelMargin 10

//note Size = 22 means there are 3 octives with one page
#define noteSize 22

//#define TEST
#ifdef TEST
#   define DSLog(...) NSLog(__VA_ARGS__)
#else
#   define DSLog(...)
#endif
