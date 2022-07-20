//
//  GoogleViewController.h
//  Cue
//
//  Created by Shreeya Indap on 7/19/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (strong, nonatomic) NSDictionary *importedEvents;

@end

NS_ASSUME_NONNULL_END
