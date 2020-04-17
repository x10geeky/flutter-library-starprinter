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
#import <StarIO_Extension/StarIoExtManager.h>

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

@property (nonatomic) BOOL isCashDrawerOpenActive;

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
        NSLog(@"Hello World");
        return;
    } else if ([@"getPrinters" isEqualToString:call.method]) {
        result([self findPrinter]);
        return;
    } else if ([@"printerWithText" isEqualToString:call.method]) {
        NSLog(@"Printer With Text");
        return;
    } else if ([@"printerWithImage" isEqualToString:call.method]) {
        NSString *base64 = call.arguments[@"base64"];
        NSNumber *drawer = call.arguments[@"drawer"];
        self.isCashDrawerOpenActive = drawer.boolValue;
        
        //NSLog(drawer.boolValue ? @"Yes" : @"No");
        //NSLog(@"%@",base64);
        //result(@(YES));
        
        result([self printerWithImage:base64 drawer:self.isCashDrawerOpenActive]);
        return;
    } else if ([@"openCashDrawer" isEqualToString:call.method]) {
        [self openCashDrawer];
        NSLog(@"Open Cash Drawer");
        return;
    }
    result(FlutterMethodNotImplemented);
}

- (void) openCashDrawer {
    NSData *commands;
    
    commands = [self createData:self.emulation channel:SCBPeripheralChannelNo1];
    
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
}

// Open Cash Drawer
- (NSData *)createData:(StarIoExtEmulation)emulation
               channel:(SCBPeripheralChannel)channel {
    
    ISCBBuilder *builder = [StarIoExt createCommandBuilder:emulation];
    
    [builder beginDocument];
    
    [builder appendPeripheral:channel];
    
    [builder endDocument];
    
    return [builder.commands copy];
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
    
    // Test Print
    ModelIndex modelIndex = [ModelCapability modelIndexAtModelName:self.modelName];
    NSLog(@"Model Index: %ld",modelIndex);
    
    NSString *title = [ModelCapability titleAtModelIndex:modelIndex];
    NSLog(@"Title: %@",title);
    
    self.portSettings = [ModelCapability portSettingsAtModelIndex:modelIndex];
    
    NSLog(@"Port Setting: %@",self.portSettings);
    
    self.emulation = [ModelCapability emulationAtModelIndex:modelIndex];
    
    NSLog(@"Emulation: %ld",(long)self.emulation);
    
    [self getDeviceStatus];
    
    return self.portName;
}

- (NSNumber *)printerWithImage:(NSString *) base64String drawer:(BOOL) cashdrawer {
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
    
    NSString *title = [ModelCapability titleAtModelIndex:modelIndex];
    NSLog(@"Title: %@",title);
    
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
            _paperSizeIndex = PaperSizeIndexNone; // PaperSizeIndexThreeInch, PaperSizeIndexFourInch
            break;
    }
    
    NSData *commands = nil;
    NSInteger width = PaperSizeIndexThreeInch;
    
    NSLog(@"Paper Size: %ld",width);
    
    // Open Cashdrawer ?
    if (self.isCashDrawerOpenActive) {
        NSLog(@"Open Cash Drawer");
        //commands = [CashDrawerFunctions createData:self.emulation channel:SCBPeripheralChannelNo1];
    }else {
        NSLog(@"Close Cash Drawer");
    }
    
    // Command Print Image
    commands = [self createRasterReceiptData:self.emulation imageBase64:base64String paperSize:PaperSizeIndexThreeInch bothScale:YES activeCashdrawer:cashdrawer];
    
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
    
    return [NSNumber numberWithBool:YES];
}

// Print Image
- (NSData *)createRasterReceiptData:(StarIoExtEmulation)emulation
                        imageBase64:(NSString *)base64String
                          paperSize:(NSInteger)width
                          bothScale:(BOOL) bothScale
                   activeCashdrawer:(BOOL) activeCashdrawer {

    UIImage *image = [self decodeBase64ToImage:base64String];

    ISCBBuilder *builder = [StarIoExt createCommandBuilder:emulation];

    [builder beginDocument];
    
    if (activeCashdrawer) {
        [builder appendPeripheral:SCBPeripheralChannelNo1];
    }

    [builder appendBitmap:image diffusion:NO width:width bothScale:bothScale];
    
    [builder appendCutPaper:SCBCutPaperActionPartialCutWithFeed];

    // Open Chash Drawer?
    [builder appendPeripheral:SCBPeripheralChannelNo1];
    
    [builder endDocument];

    return [builder.commands copy];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void)printWithText {
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
    
    NSInteger width = PaperSizeIndexThreeInch;
    
    // Command Print Text
    commands = [self createTextReceiptData:self.emulation utf8:YES];

    
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
    
    //return self.modelName;
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

- (void) getDeviceStatus {
    NSLog(@"Staus ->: %@",self.portName);
    
    CommResult result = CommResultErrorOpenPort;
    NSInteger  code   = SMStarIOResultCodeFailedError;
    
    SMPort *port = nil;
    NSString *portName = self.portName;
    
    NSError *error = nil;
    
    port = [SMPort getPort:self.portName :self.portSettings :10000 :&error];
    
    if (port == nil) {
        code = error.code;
    }else {
        // Sleep to avoid a problem which sometimes cannot communicate with Bluetooth.
        NSOperatingSystemVersion version = {11, 0, 0};
        BOOL isOSVer11OrLater = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version];
        if ((isOSVer11OrLater) && ([portName.uppercaseString hasPrefix:@"BT:"])) {
            [NSThread sleepForTimeInterval:0.2];
        }
        
        StarPrinterStatus_2 printerStatus;
        
        result = CommResultErrorWritePort;
        
        [port getParsedStatus:&printerStatus :2 :&error];
        
        if (error != nil) {
            code = error.code;
        }else {
            if (printerStatus.offline == SM_TRUE) {
                NSLog(@"Offline");
            }else {
                NSLog(@"Online");
            }
            
            if (printerStatus.coverOpen == SM_TRUE) {
                NSLog(@"Cover Open");
            }else {
                NSLog(@"Cover Closed");
            }
            
            if (printerStatus.receiptPaperEmpty == SM_TRUE) {
                NSLog(@"Paper Empty");
            }else if (printerStatus.receiptPaperNearEmptyInner == SM_TRUE ||
                     printerStatus.receiptPaperNearEmptyOuter == SM_TRUE) {
                NSLog(@"Paper Near Empty");
            }else {
                NSLog(@"Printer Read");
            }
            
            if (printerStatus.compulsionSwitch == SM_TRUE) {
                NSLog(@"Cash Drawer Open");
            }else {
                NSLog(@"Cash Drawer Close");
            }
            
            if (printerStatus.overTemp == SM_TRUE) {
                NSLog(@"Head Temperature High");
            }else {
                NSLog(@"Head Temperature Normal");
            }
            
            if (printerStatus.unrecoverableError == SM_TRUE) {
                NSLog(@"Non Recoverable Error Occurs");
            }else {
                NSLog(@"Non Recoverable Error Ready");
            }
            
            if (printerStatus.cutterError == SM_TRUE) {
                NSLog(@"Paper Cutter Error");
            }else {
                NSLog(@"Paper Cutter Ready");
            }
            
            if (printerStatus.headThermistorError == SM_TRUE) {
                NSLog(@"Head Thermistor Error");
            }else {
                NSLog(@"Head Thermistor Normal");
            }
            
            if (printerStatus.voltageError == SM_TRUE) {
                NSLog(@"Voltage Error");
            }else {
                NSLog(@"Voltage Normal");
            }
            
            if (printerStatus.etbAvailable == SM_TRUE) {
                NSLog(@"ETB Counter: %@",[NSString stringWithFormat:@"%d", printerStatus.etbCounter]);
            }
            
            if (printerStatus.offline == SM_TRUE) {
                NSLog(@"Unable to get Firmware info.");
            }else {
                NSDictionary *firmwareInformation = [port getFirmwareInformation :&error];
                
                if (firmwareInformation == nil) {
                    code = error.code;
                }else {
                    NSLog(@"Model Name: %@",[firmwareInformation objectForKey:@"ModelName"]);
                    NSLog(@"Firmware Version: %@",[firmwareInformation objectForKey:@"FirmwareVersion"]);
                }
            }
            
            result = CommResultSuccess;
            code = SMStarIOResultCodeSuccess;
        }
    }
    
    if (port != nil) {
        [SMPort releasePort:port];
        
        port = nil;
    }
    
    if (result != CommResultSuccess) {
        NSLog(@"Communication Result: %@",[Communication getCommunicationResultMessage:[[CommunicationResult alloc] initWithResult:result code:code]]);
    }
}


/*
#pragma mark StarIoExtManagerDelegate

- (void)didPrinterImpossible:(StarIoExtManager *)manager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Printer Impossible.");
}

- (void)didCashDrawerOpen:(StarIoExtManager *)manager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Cash Drawer Open.");
}

- (void)didCashDrawerClose:(StarIoExtManager *)manager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Cash Drawer Close.");
}

- (void)didAccessoryConnectSuccess:(StarIoExtManager *)manager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Accessory Connect Success.");
}

- (void)didAccessoryConnectFailure:(StarIoExtManager *)manager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Accessory Connect Failure.");
}

- (void)didAccessoryDisconnect:(StarIoExtManager *)manager {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Accessory Disconnect.");
}

- (void)didStatusUpdate:(StarIoExtManager *)manager status:(NSString *)status {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSLog(@"Status Update");
}
*/

@end
