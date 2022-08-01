//
//  SuggestionViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/25/22.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Suggestion.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SuggestionViewDelegate
- (void)didSelectCue:(Suggestion*)suggestionToSend;
@end

@interface SuggestionViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) Suggestion *detailSuggestion;
@property (nonatomic, weak) id <SuggestionViewDelegate> delegateObject;

@end

NS_ASSUME_NONNULL_END
