//
//  Pancake.m
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import "Pancake.h"
#import "WondewAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation Pancake

-(id) init{
    if (self == [super init]) {
        json = [[SBJSON alloc] init];
    }
    return self;
}

-(void)release {
    [super release];
}


-(void)load {
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"secret"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ftaires.com:8042/%@/wondew?secret=%@&regex=.*", username, secret]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.didFinishSelector = @selector(getRequestDidFinish:);
    [request setDelegate: self];
    [request startAsynchronous];
}

-(NSArray *)parseWondews:(NSArray *)responseObject {
    NSMutableArray *projectTitles = [NSMutableArray array];
    for (NSDictionary *line in responseObject) {
        if ([projectTitles indexOfObject:[[line objectForKey:@"tags"] objectForKey:@"project"]] == NSNotFound) {
            [projectTitles addObject: [[line objectForKey:@"tags"] objectForKey:@"project"]];
        }
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *projectTitle in projectTitles) {
        NSMutableDictionary *project = [NSMutableDictionary dictionary];
        [project setObject:projectTitle forKey:@"projectTitle"];
        [project setObject:[NSMutableArray array] forKey:@"wondews"];
        for (NSDictionary *line in responseObject) {
            if ([[[line objectForKey:@"tags"] objectForKey:@"project"] isEqualToString:projectTitle]) {
                [[project objectForKey:@"wondews"] addObject: line];
            }
        }
        [ret addObject:project];
    }
    return ret;
}

-(void)getRequestDidFinish:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    id responseObject = [json objectWithString:response];
    if (![[responseObject objectForKey:@"status"] isEqualToString:@"ok"]) {
        NSLog(@"!!!!!!!!!!!PERMISSION PROBLEM!!!!!!!");
    }
    NSArray *projects = [self parseWondews:[responseObject objectForKey:@"results"]];
    [(WondewAppDelegate*)[[UIApplication sharedApplication] delegate] projectsDidFinishLoading:projects];
}

-(void)postRequestDidFinish:(ASIHTTPRequest *)request {
//    NSLog(@"POST ASIRequest back!");
//    NSString *response = [request responseString];
//    id responseObject = [json objectWithString:response];
//    NSLog(@"%@", responseObject);
}

-(NSMutableString *)stringByURLEscapingString:(NSString *)s {
    NSMutableString *escaped = [NSMutableString stringWithString:[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];       
    [escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    return escaped;
}

-(void)addWondew:(NSString *)text inProject:(NSString *)projectTitle {
    text = [NSString stringWithFormat:@"%@ #project(%@)", text, projectTitle, nil];

    NSString *lines = [[NSArray arrayWithObject:text] JSONRepresentation];
    lines = [self stringByURLEscapingString:lines];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"secret"];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ftaires.com:8042/%@/wondew?secret=%@&regex=.*", username, secret]];    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ftaires.com:8042/%@/wondew/append_lines?secret=%@&lines=%@", username, secret, lines, nil]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    request.delegate = self;
    request.didFinishSelector = @selector(postRequestDidFinish:);
    [request startAsynchronous];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
    NSLog(@"Internet error!");
}
@end
