//
//  ViewController.m
//  ColorPickerDemo
//
//  Created by sven on 2020/12/17.
//

#import "ViewController.h"
#import "DCColorPicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DCColorPicker *colorPicker = [[DCColorPicker alloc] initWithFrame:CGRectMake(10, 120, 300, 300) bgImage:[UIImage imageNamed:@"Popup_color_bg"]];
    [self.view addSubview:colorPicker];
    colorPicker.currentColorBlock = ^(UIColor * _Nonnull color, int x, int y) {
        //callback
    };
}


@end
