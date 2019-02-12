//
//  JKMicroView.m
//  JKMicroWebView
//
//  Created by byRong on 2018/11/13.
//  Copyright © 2018 byRong. All rights reserved.
//

#import "JKMicroView.h"

@implementation JKMicroView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

#pragma mark - override

- (void)dealloc
{
    //停止加载
    [self stopLoading];
    //清空相关delegate
    [super setUIDelegate:nil];
    [super setNavigationDelegate:nil];
}

#pragma mark - Configuration
- (void)config
{
    self.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
    // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
    self.configuration.allowsInlineMediaPlayback = YES;
    if (@available(iOS 9.0, *)) {
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        self.configuration.requiresUserActionForMediaPlayback = YES;
        //设置是否允许画中画技术 在特定设备上有效
        self.configuration.allowsPictureInPictureMediaPlayback = YES;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        self.configuration.applicationNameForUserAgent = @"ChinaDailyForiPad";
    }
}

- (void)setAllowBack:(BOOL)allowBack
{
    _allowBack = allowBack;
    // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
    self.allowsBackForwardNavigationGestures = _allowBack;
}

#pragma mark - public method
- (void)jk_loadRequestURLString:(NSString *)urlString
{
    [self jk_loadRequestURL:[NSURL URLWithString:urlString]];
}

- (void)jk_loadRequestURL:(NSURL *)url
{
    [self jk_loadRequestURL:url cookie:nil];
}

- (void)jk_loadRequestURL:(NSURL *)url cookie:(NSDictionary *)params
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    __block NSMutableString *cookieStr = [NSMutableString string];
    if (params) {
        [params enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull value, BOOL *_Nonnull stop) {
            [cookieStr appendString:[NSString stringWithFormat:@"%@ = %@;", key, value]];
        }];
    }
    if (cookieStr.length > 1) {
        [cookieStr deleteCharactersInRange:NSMakeRange(cookieStr.length - 1, 1)];
    }
    [request addValue:cookieStr forHTTPHeaderField:@"Cookie"];
    [self jk_loadRequest:request.copy];
}

- (void)jk_loadRequest:(NSURLRequest *)requset
{
    [super loadRequest:requset];
}

- (void)jk_loadHTMLTemplate:(NSString *)htmlTemplate
{
    [super loadHTMLString:htmlTemplate baseURL:nil];
}

#pragma mark - Cache
+ (void)jk_clearAllWebCache
{
    if (@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeSessionStorage,
                                                        WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeOfflineWebApplicationCache,
                                                        WKWebsiteDataTypeCookies,
                                                        WKWebsiteDataTypeLocalStorage,
                                                        WKWebsiteDataTypeIndexedDBDatabases,
                                                        WKWebsiteDataTypeWebSQLDatabases
                                                        ]];
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            NSLog(@"WKWebView (ClearWebCache) Clear All Cache Done");
        }];
    } else {
        // iOS8
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        @"WKWebsiteDataTypeCookies",
                                                        @"WKWebsiteDataTypeLocalStorage",
                                                        @"WKWebsiteDataTypeIndexedDBDatabases",
                                                        @"WKWebsiteDataTypeWebSQLDatabases"
                                                        ]];
        for (NSString *type in websiteDataTypes) {
            clearWebViewCacheFolderByType(type);
        }
    }
}
FOUNDATION_STATIC_INLINE void clearWebViewCacheFolderByType(NSString *cacheType)
{
    static dispatch_once_t once;
    static NSDictionary *cachePathMap = nil;
    dispatch_once(&once, ^{
        NSString *bundleId = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleIdentifierKey];
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *storageFileBasePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"WebKit/%@/WebsiteData/", bundleId]];
        cachePathMap = @{
                         @"WKWebsiteDataTypeCookies" : [libraryPath stringByAppendingPathComponent:@"Cookies/Cookies.binarycookies"],
                         @"WKWebsiteDataTypeLocalStorage" : [storageFileBasePath stringByAppendingPathComponent:@"LocalStorage"],
                         @"WKWebsiteDataTypeIndexedDBDatabases" : [storageFileBasePath stringByAppendingPathComponent:@"IndexedDB"],
                         @"WKWebsiteDataTypeWebSQLDatabases" : [storageFileBasePath stringByAppendingPathComponent:@"WebSQL"]
                         };
    });
    
    NSString *filePath = cachePathMap[cacheType];
    if (filePath && filePath.length > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"removed file fail: %@ ,error %@", [filePath lastPathComponent], error);
            }
        }
    }
}

- (void)jk_clearBrowseHistory
{
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"_re", @"moveA", @"llIte", @"ms"]);
    if ([self.backForwardList respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.backForwardList performSelector:sel];
#pragma clang diagnostic pop
    }
}
@end
