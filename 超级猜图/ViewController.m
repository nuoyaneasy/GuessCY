//
//  ViewController.m
//  超级猜图
//
//  Created by Yang Chao on 6/27/15.
//  Copyright (c) 2015 Self. All rights reserved.
//

#import "ViewController.h"
#import "Question.h"

#define kButtonWidth 35
#define kButtonHeight 35
#define kButtonMargin 10
#define kTotalCol 7

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UIButton *scoreButton;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextQuestionButton;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) UIButton *cover;
@property (strong, nonatomic) NSArray *quesions;
@property (assign, nonatomic) int index;
@end

@implementation ViewController
#pragma mark - Property
- (UIButton *)cover
{
    if (_cover == nil) {
        //1. 添加一个遮罩/蒙版，
        _cover= [[UIButton alloc] initWithFrame:self.view.bounds];
        _cover.alpha = 0.0;
        _cover.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        _cover.alpha = 0.0;
        [self.view addSubview:_cover];
        [_cover addTarget:self action:@selector(bigImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cover;
}
#pragma mark - System method
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.quesions == nil) {
        self.quesions = [Question quesitons];
    }
    self.index = -1;
    [self nextQuestion];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return  UIStatusBarStyleLightContent;
}
#pragma mark - IBAction
/**
 *  大图
 *
 *  @param sender <#sender description#>
 */
- (IBAction)bigImage:(id)sender
{
    if (self.cover.alpha == 0.0) { //放大
    //2. 将图像按钮放在最前面
    [self.view bringSubviewToFront:self.iconButton];
    //3. 动画，放大图像按钮
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = w;
    CGFloat y = (self.view.bounds.size.height - h) * 0.5;
    CGRect frame = CGRectMake(0, y, w, h);
    [UIView animateWithDuration:0.5 animations:^{
        self.iconButton.frame = frame;
        self.cover.alpha = 1.0;
    }];  
    } else { //缩小
        [UIView animateWithDuration:0.5 animations:^{
            self.iconButton.frame = CGRectMake(85, 85, 150, 150);
            self.cover.alpha = 0.0;
        }];
    }
}
/**
 *  下一题目
    主要的方法，尽量保留简短的代码，主要体现思路和流程
 */
- (IBAction)nextQuestion
{
    //1.当前答题的索引
    self.index++;
    
    //如果已经到最后一题，提示用户
    if (self.index == self.quesions.count) {
        NSLog(@"通关了");
        return;
    }
    
    //2.从数组中按照索引取出题目模型数据
    Question *question = self.quesions[self.index];
    
    //3.设置基本信息
    [self setupBasicInfomation:question];
    //如果到达最后一题，则禁用下一题按钮
    self.nextQuestionButton.enabled = (self.index < self.quesions.count -1);
    //4.设置答案按钮
    [self createAnswerButtons:question];
    //首先清除掉答题区按钮
    //5.设置备选按钮
    [self createOptionsButton:question];
}

- (IBAction)tipClicked
{
    //1. 清空答题区按钮
    for (UIButton *btn in self.answerView.subviews) {
        //用代码执行点击按钮
        [self answerClicked:btn];
    }
    //2. 把正确的第一个字设置到答题区中
    Question *quesion = self.quesions[self.index];
    NSString *firstChara = [quesion.answer substringToIndex:1];
    UIButton *btn = [self optionButtonWithTitle:firstChara isHidden:NO];
    [self optionClick:btn];
    
    //扣分
    [self changeScore:-1000];
}

#pragma mark - 分数处理
- (void)changeScore:(int)score
{
    //取出当前分数
    int currentScore = self.scoreButton.currentTitle.intValue;
    
    //使用socore调整分数
    currentScore += score;
    
    //重新设置分数
    [self.scoreButton setTitle:[NSString stringWithFormat:@"%d", currentScore] forState:UIControlStateNormal];
}
#pragma mark - 候选按钮点击方法
/**
 *  候选按钮点击方法
 *
 */

- (void)optionClick:(UIButton *)optionBtn
{
    //1. 找到答案区第一个为空的按钮
    UIButton *firstBlankButton = [self firstBlankAnswerButton];

    //没有找到空的按钮
    if (firstBlankButton == nil) {
        return;
    } else {
        //2. 将optionButton的标题赋值给答题区的按钮
        [firstBlankButton setTitle:optionBtn.currentTitle forState:UIControlStateNormal];
        //3. 将optionButton隐藏
        optionBtn.hidden = YES;
        UIButton *btn = [self firstBlankAnswerButton];
        if (btn == nil) {
            [self judge];
        }
    }
//    if (firstBlankButton == nil && firstBlankButton == self.answerView.subviews.lastObject) {
//        //2. 将optionButton的标题赋值给答题区的按钮
//        [firstBlankButton setTitle:optionBtn.currentTitle forState:UIControlStateNormal];
//        //3. 将optionButton隐藏
//        optionBtn.hidden = YES;
//        //4. 判断结果
//        [self judge];
//    } else {
//        //2. 将optionButton的标题赋值给答题区的按钮
//        [firstBlankButton setTitle:optionBtn.currentTitle forState:UIControlStateNormal];
//        //3. 将optionButton隐藏
//        optionBtn.hidden = YES;
//    }

}
/**
 *  找到第一个为空的答题区按钮
 */

- (UIButton *)firstBlankAnswerButton
{
    for (UIButton *btn in self.answerView.subviews) {
        if (btn.currentTitle.length == 0) {
            return btn;
        }
    }
    return nil;
}

/**
 *  判断结果
 */

- (void)judge
{
    BOOL isFull = YES;
    NSMutableString *strM = [NSMutableString string];
    for (UIButton *btn in self.answerView.subviews) {
        if (btn.currentTitle.length == 0) {
            isFull = NO;
            break;
        } else {
            //有字，拼接字符串
            [strM appendString:btn.currentTitle];
        }
    }
    if (isFull) {
        NSLog(@"Full");
        //判断是否和答案一致，先根据index获得答案
        Question *question = self.quesions[self.index];
        //如果一致，进入下一题
        if ([strM isEqualToString:question.answer]) {
            [self setAnswerButtonsColor:[UIColor blueColor]];
            [self changeScore:1800];
            //等待0.5秒进入下一题
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self nextQuestion];
            });
        } else {
            //如果不一致，修改字体颜色
            [self setAnswerButtonsColor:[UIColor redColor]];
        }
    } else {
        
    }
}
/**
 *  修改答题区字体颜色
 */

- (void)setAnswerButtonsColor:(UIColor *)color
{
    for (UIButton *button in self.answerView.subviews) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
}

#pragma mark - 答题按钮点击方法

- (void)answerClicked:(UIButton *)answerBtn
{
    //1. 如果按钮没有字，直接返回
    if (answerBtn.currentTitle.length == 0) {
        return;
    }
    //2. 如果有字，清楚文字，候选区按钮显示
    //a. 使用button的title去查找候选区中对应的按钮
    UIButton *optionBtn = [self optionButtonWithTitle:answerBtn.currentTitle isHidden:YES];
    //b. 显示对应按钮
    optionBtn.hidden = NO;
    //c. 清除文字
    [answerBtn setTitle:@"" forState:UIControlStateNormal];
    //d. 将颜色改回黑色
    [self setAnswerButtonsColor:[UIColor blackColor]];
}

- (UIButton *)optionButtonWithTitle:(NSString *)title isHidden:(BOOL)isHidden
{
    for (UIButton *btn in self.optionsView.subviews) {
        if ([btn.currentTitle isEqualToString:title] && btn.isHidden == isHidden) {
            return btn;
        }
    }
    return nil;
}

#pragma mark - 重构代码
/**
 *  设置基本信息
 *
 *  @return <#return value description#>
 */

- (void)setupBasicInfomation:(Question *)question
{
    self.indexLabel.text = [NSString stringWithFormat:@"%d/%d", self.index + 1, self.quesions.count];
    self.titleLabel.text = question.title;
    [self.iconButton setImage:[UIImage imageNamed:[question icon]] forState:UIControlStateNormal];
}

/**
 *  创建备选区按钮
 */
- (void)createOptionsButton:(Question *)question
{
    //如果按钮已经存在，并且是21个，只需要更改标题
    if (self.optionsView.subviews.count != question.options.count) {
        CGFloat optionW = self.optionsView.bounds.size.width;
        CGFloat optionX = (optionW - kTotalCol * kButtonWidth - (kTotalCol - 1) * kButtonMargin) * 0.5;
        NSUInteger optionsCount = question.options.count;
        for (int i = 0; i < optionsCount; i++) {
            int row = i / kTotalCol;
            int col = i % kTotalCol;
            CGFloat x = optionX + col * (kButtonMargin + kButtonWidth);
            CGFloat y = row * (kButtonHeight + kButtonMargin);
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, kButtonWidth, kButtonHeight)];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
            //设置备选答案
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.optionsView addSubview:btn];
        }
    }
    //按钮已经存在，点击下一题，只需要设置标题
    int i = 0;
    //让模型打乱顺序
    [question randomOptions];
    for (UIButton *btn in self.optionsView.subviews) {
        [btn setTitle:question.options[i++] forState:UIControlStateNormal];
        btn.hidden = NO;
    }
}

/**
 *  创建答题区按钮
 */

- (void)createAnswerButtons:(Question *)question
{
    [self.answerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat answerW = self.answerView.bounds.size.width;
    int count = question.answer.length;
    CGFloat answerX = (answerW - kButtonWidth * count - kButtonMargin * (count -1)) * 0.5;
    for (int i = 0; i < count; i++) {
        CGFloat x = answerX + i * (kButtonMargin + kButtonWidth);
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, kButtonWidth, kButtonHeight)];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(answerClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.answerView addSubview:btn];
    }
}
@end
