// AdobeProvider.m
// Copyright 2013 Segment.io

#import "AdobeProvider.h"
#import "ADMS_Measurement.h"
#import "AnalyticsLogger.h"

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
        self.name = @"Adobe";
        self.valid = NO;
        self.initialized = NO;
    }
    return self;
}

- (void)start
{
    // Require the Report Suite ID and Tracking Server.
    NSString *reportSuite = [self.settings objectForKey:@"reportSuite"];
    NSString *trackingServer = [self.settings objectForKey:@"trackingServer"];
    
    ADMS_Measurement *measurement = [ADMS_Measurement sharedInstance];
    [measurement configureMeasurementWithReportSuiteIDs:reportSuite trackingServer:trackingServer];
    
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
    BOOL hasReportSuite = [self.settings objectForKey:@"reportSuite"] != nil;
    BOOL hasTrackingServer = [self.settings objectForKey:@"trackingServer"] != nil;
    self.valid = hasReportSuite && hasTrackingServer;
}


#pragma mark - Analytics API

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits context:(NSDictionary *)context
{
    // TODO: keep traits in a local store and merge them onto event/screen properties when they're sent?
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties context:(NSDictionary *)context
{
    // TODO: include mapping from event --> "event1" which should be downloaded from the server.
    [[ADMS_Measurement sharedInstance] trackEvents:event withContextData:properties];
}

- (void)screen:(NSString *)screenTitle properties:(NSDictionary *)properties context:(NSDictionary *)context
{
    [[ADMS_Measurement sharedInstance] trackAppState:screenTitle withContextData:properties];
}

@end
