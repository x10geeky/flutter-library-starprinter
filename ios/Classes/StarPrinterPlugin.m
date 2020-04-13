#import "StarPrinterPlugin.h"
#if __has_include(<star_printer/star_printer-Swift.h>)
#import <star_printer/star_printer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "star_printer-Swift.h"
#endif

#import <StarIO/SMPort.h>

#import "ModelCapability.h"
#import "PrinterSetting.h"
#import "PrinterInfo.h"
#import "GlobalQueueManager.h"
#import "Communication.h"

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

- (NSString  *)findPrinter {
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
    
    // Test Print
    ModelIndex modelIndex = [ModelCapability modelIndexAtModelName:self.modelName];
    NSLog(@"Model Index: %ld",modelIndex);
    
    self.portSettings = [ModelCapability portSettingsAtModelIndex:modelIndex];
    
    NSLog(@"Port Setting: %@",self.portSettings);
    
    self.emulation = [ModelCapability emulationAtModelIndex:modelIndex];
    
    NSLog(@"Emulation: %ld",(long)self.emulation);
    
    switch (_emulation) {
        case StarIoExtEmulationStarDotImpact:
            _paperSizeIndex = PaperSizeIndexDotImpactThreeInch;
            break;
        case StarIoExtEmulationEscPos:
            _paperSizeIndex = PaperSizeIndexEscPosThreeInch;
            break;
        default:
            _paperSizeIndex = PaperSizeIndexNone;
            break;
    }
    
    NSData *commands = nil;
    
    //NSInteger width = self.paperSizeIndex;
    
    // Command Print Text
    //commands = [self createTextReceiptData:self.emulation utf8:YES];
    
    // Command Print Image
    commands = [self createRasterReceiptData:self.emulation imageBase64:@""];
    
    
    //self.blind = YES;
    
    dispatch_async(GlobalQueueManager.sharedManager.serialQueue, ^{
        [Communication sendCommands:commands
                           portName:self->_portName
                       portSettings:self->_portSettings
                            timeout:10000
                  completionHandler:^(CommunicationResult *communicationResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",[Communication getCommunicationResultMessage:communicationResult]);
                //self.blind = NO;
            });
        }];
    });
    
    return self.modelName;
}

// Print Image
- (NSData *)createRasterReceiptData:(StarIoExtEmulation)emulation
                   imageBase64:(NSString *)base64String {

    UIImage *image = [self decodeBase64ToImage:base64String];

    ISCBBuilder *builder = [StarIoExt createCommandBuilder:emulation];

    [builder beginDocument];

    [builder appendBitmap:image diffusion:NO];

    [builder appendCutPaper:SCBCutPaperActionPartialCutWithFeed];

    [builder endDocument];

    return [builder.commands copy];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(NSData *) createTextReceiptData:(StarIoExtEmulation)emulation utf8:(BOOL)utf8 {
    ISCBBuilder *builder = [StarIoExt createCommandBuilder:emulation];
    
    [builder beginDocument];
    
    // Call Order Data
    [self append3inchTextReceiptData:builder utf8:YES];
    
    [builder appendCutPaper:SCBCutPaperActionPartialCutWithFeed];
    
    [builder endDocument];
    
    return [builder.commands copy];
}

- (void)append3inchTextReceiptData:(ISCBBuilder *)builder utf8:(BOOL)utf8 {
    NSStringEncoding encoding;
    
    if (utf8 == YES) {
        encoding = NSUTF8StringEncoding;
        
        [builder appendCodePage:SCBCodePageTypeUTF8];
    }
    else {
        encoding = NSASCIIStringEncoding;
        
        [builder appendCodePage:SCBCodePageTypeCP998];
    }
    
    [builder appendInternational:SCBInternationalTypeUSA];
    
    [builder appendCharacterSpace:0];
    
    [builder appendAlignment:SCBAlignmentPositionCenter];
    
    [builder appendData:[@"JADLAN Clothing Boutique\n"
                         "123 Star Road\n"
                         "City, State 12345\n"
                         "\n" dataUsingEncoding:encoding]];
    
    [builder appendAlignment:SCBAlignmentPositionLeft];
    
    [builder appendData:[@"Date:MM/DD/YYYY                    Time:HH:MM PM\n"
                         "------------------------------------------------\n"
                         "\n" dataUsingEncoding:encoding]];
    
    [builder appendDataWithEmphasis:[@"SALE \n" dataUsingEncoding:encoding]];
    
    [builder appendData:[@"SKU               Description              Total\n"
                         "300678566         PLAIN T-SHIRT            10.99\n"
                         "300692003         BLACK DENIM              29.99\n"
                         "300651148         BLUE DENIM               29.99\n"
                         "300642980         STRIPED DRESS            49.99\n"
                         "300638471         BLACK BOOTS              35.99\n"
                         "\n"
                         "Subtotal                                  156.95\n"
                         "Tax                                         0.00\n"
                         "------------------------------------------------\n" dataUsingEncoding:encoding]];
    
    [builder appendData:[@"Total                       " dataUsingEncoding:encoding]];
    
    [builder appendDataWithMultiple:[@"   $156.95\n" dataUsingEncoding:encoding] width:2 height:2];
    
    [builder appendData:[@"------------------------------------------------\n"
                         "\n"
                         "Charge\n"
                         "159.95\n"
                         "Visa XXXX-XXXX-XXXX-0123\n"
                         "\n" dataUsingEncoding:encoding]];
    
    [builder appendDataWithInvert:[@"Refunds and Exchanges\n" dataUsingEncoding:encoding]];
    
    [builder appendData:[@"Within " dataUsingEncoding:encoding]];
    
    [builder appendDataWithUnderLine:[@"30 days" dataUsingEncoding:encoding]];
    
    [builder appendData:[@" with receipt\n" dataUsingEncoding:encoding]];
    
    [builder appendData:[@"And tags attached\n"
                         "\n" dataUsingEncoding:encoding]];
    
    [builder appendAlignment:SCBAlignmentPositionCenter];
    
    //[builder appendBarcodeData:[@"{BStar." dataUsingEncoding:encoding] symbology:SCBBarcodeSymbologyCode128 width:SCBBarcodeWidthMode2 height:40 hri:YES];
    
    [builder appendBarcodeData:[@"{BStar." dataUsingEncoding:NSASCIIStringEncoding] symbology:SCBBarcodeSymbologyCode128 width:SCBBarcodeWidthMode2 height:40 hri:YES];
}

@end


