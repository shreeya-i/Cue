//
//  DetailsViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "SuggestionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController <SuggestionViewDelegate>

@property (strong, nonatomic) Event *detailEvent;
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTableView;

@end

NS_ASSUME_NONNULL_END
