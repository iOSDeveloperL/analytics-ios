// AdobeProvider.m
// Copyright 2013 Segment.io

#import "AdobeProvider.h"
#import "ADMS_Measurement.h"
#import "AnalyticsLogger.h"

// http://microsite.omniture.com/t2/help/en_US/sc/appmeasurement/ios/index.html#Developer_Quick_Start

@implementation AdobeProvider {
    
}

#pragma mark - Initialization

+ (instancetype)withNothing
{
    return [[self alloc] initWithNothing];
}

- (id)initWithNothing
{
    if (self = [self init]) {
        self.name = @"Omniture";
        self.valid = NO;
        self.initialized = NO;
    }
    return self;
}

- (void)start
{
    // Require the Report Suite ID and Tracking Server.
    NSString *reportSuiteId = [self.settings objectForKey:@"reportSuiteId"];
    NSString *trackingServerUrl = [self.settings objectForKey:@"trackingServerUrl"];
    
    ADMS_Measurement *measurement = [ADMS_Measurement sharedInstance];
    [measurement configureMeasurementWithReportSuiteIDs:reportSuiteId trackingServer:trackingServerUrl];
    
    // Optionally turn on SSL.
    BOOL useSSL = [[self.settings objectForKey:@"useSSL"] boolValue];
    if (useSSL) {
        measurement.ssl = YES;
    }
    else {
        measurement.ssl = NO;
    }
    
    // Disable debug logging.
    measurement.debugLogging = YES;
    
    
    // Auto-tracking
    BOOL lifecycleAutoTracking = [[self.settings objectForKey:@"lifecycleAutoTracking"] boolValue];
    BOOL navigationAutoTracking = [[self.settings objectForKey:@"navigationAutoTracking"] boolValue];
    
    if (lifecycleAutoTracking && navigationAutoTracking) {
        // LifeCycle and navigation tracking enabled (iOS only)
        [measurement setAutoTrackingOptions:ADMS_AutoTrackOptionsLifecycle | ADMS_AutoTrackOptionsNavigation];
    }
    else if (lifecycleAutoTracking) {
        // LifeCycle auto tracking enabled (default)
        [measurement setAutoTrackingOptions:ADMS_AutoTrackOptionsLifecycle];
    }
    else if (navigationAutoTracking) {
        // Only Navigation auto tracking enabled (iOS only)
        [measurement setAutoTrackingOptions:ADMS_AutoTrackOptionsNavigation];
    }
    else {
        // Disable auto-tracking completely
        [measurement setAutoTrackingOptions:ADMS_AutoTrackOptionsNone];
    }
    
    // All done!
    [AnalyticsLogger log:@"AdobeProvider initialized."];
}


#pragma mark - Settings

- (void)validate
{
    // All that's required is the report suite and the tracking server.
    BOOL hasReportSuiteId = [self.settings objectForKey:@"reportSuiteId"] != nil;
    BOOL hasTrackingServerUrl = [self.settings objectForKey:@"trackingServerUrl"] != nil;
    self.valid = hasReportSuiteId && hasTrackingServerUrl;
}


#pragma mark - Analytics API

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits context:(NSDictionary *)context
{
    // TODO: keep traits in a local store and merge them onto event/screen properties when they're sent?
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties context:(NSDictionary *)context
{
    NSDictionary *eventMap = [self.settings objectForKey:@"events"];
    NSString *eventMapped = [eventMap objectForKey:event];
    if (eventMapped != nil) {
        [[ADMS_Measurement sharedInstance] trackEvents:eventMapped withContextData:properties];
    }
    else {
        [AnalyticsLogger log:@"The event %@ is not yet mapped to Adobe (Omniture) eventN in your integration page settings. Here are the existing mappings: %@", event, eventMap];
    }
}

- (void)screen:(NSString *)screenTitle properties:(NSDictionary *)properties context:(NSDictionary *)context
{
    [[ADMS_Measurement sharedInstance] trackAppState:screenTitle withContextData:properties];
}

@end
