#import "StarPrinterPlugin.h"
#if __has_include(<star_printer/star_printer-Swift.h>)
#import <star_printer/star_printer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "star_printer-Swift.h"
#endif

@implementation StarPrinterPlugin
/*
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStarPrinterPlugin registerWithRegistrar:registrar];
}
*/

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  // 1. Create MethodChannel
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"star_printer" binaryMessenger:registrar.messenger];
  // 2. Plugin registration.
  StarPrinterPlugin* plugin = [[StarPrinterPlugin alloc] init];
  [registrar addMethodCallDelegate:plugin channel:channel];
}


- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([self findPrinter]);
  } else if ([@"getPrinters" isEqualToString:call.method]) {
    result([self findPrinter]);
  } else {
    // NSString *url = call.arguments[@"url"];
    result(FlutterMethodNotImplemented);
  }
}

- (NSString  *)findPrinter {
  return @"Hello World Star Plugin!!!!";
}
@end


