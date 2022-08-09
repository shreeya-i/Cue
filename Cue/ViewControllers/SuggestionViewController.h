//
//  SuggestionViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/25/22.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Suggestion.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

/// Protocol between Suggestion and Details to update the view once Cue selected
@protocol SuggestionViewDelegate
- (void)didSelectCue:(NSString *)cueId;
@end

@interface SuggestionViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) Suggestion *detailSuggestion;
@property (nonatomic, weak) id <SuggestionViewDelegate> delegateObject;
@property (nonatomic, strong) Event *detailEvent;

@end

NS_ASSUME_NONNULL_END
