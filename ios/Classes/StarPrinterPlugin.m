#import "StarPrinterPlugin.h"
#if __has_include(<star_printer/star_printer-Swift.h>)
#import <star_printer/star_printer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "star_printer-Swift.h"
#endif

#import "ModelCapability.h"
#import "PrinterSetting.h"
#import "GlobalQueueManager.h"
#import "Communication.h"

#import <StarIO/SMPort.h>

@interface StarPrinterPlugin ()


@property (nonatomic) NSString *portName;
@property (nonatomic) NSString *portSettings;
@property (nonatomic) NSString *modelName;
@property (nonatomic) NSString *macAddress;

@property (nonatomic) PaperSizeIndex paperSizeIndex;

@property (nonatomic) StarIoExtEmulation emulation;

@end

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

- (NSString *)findPrinter {
    
    NSArray *portInfoArray;
    
    NSError *error = nil;
    
    portInfoArray = [SMPort searchPrinter:@"ALL:" :&error];
    
    NSLog(@"Printer %@",portInfoArray);
    
    
    for (PortInfo *portInfo in portInfoArray) {
        self.portName   = portInfo.portName;
        self.modelName  = portInfo.modelName;
        self.macAddress = portInfo.macAddress;
    }
    
    NSLog(@"Name: %@",self.portName);
    NSLog(@"Model Name: %@",self.modelName);
    NSLog(@"Mac Address: %@",self.macAddress);
    
    return @"Hello World Star Plugin!!!!";
}
@end


