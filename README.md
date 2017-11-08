# 终于把tableview上使用的功能加上了.其余功能都已经完成差不多,稍后补上说明文档.

~~终于把tableview上使用的功能加上了.
其余功能都已经完成差不多,稍后补上说明文档

Finally, the use of the tableview with the function.

The rest of the functions have been completed almost, later added on the documentation.~~

![image](https://github.com/CZXBigBrother/MCPlayer/blob/master/Demo/resource/MV.gif)
#主要作者比较懒，有问题可以直接发邮件chenxingghost@gmail.com,还有待完善的地方慢慢修改


# 模型类
 	MCPlayerModel * data = [[MCPlayerModel alloc]init];
    data.videoURL = @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4";
    data.title = @"电影一";

 #基本公开的三个方法
/**
 *  播放
 */
- (void)MCPlayerPlay;

/**
 *  暂停
 */
- (void)MCPlayerPause;

/**
 *  重置
 */
- (void)MCPlayerReset;

# tableview上的使用方法
    MCPlayerModel * data = [[MCPlayerModel alloc]init];
    data.videoURL = @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4";
    data.title = @"电影一";
    UITableViewCell * middleCell = [tableView cellForRowAtIndexPath:indexPath];
    MCPlayerView * view = [MCPlayerView sharedPlayerView];
    [middleCell addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    view.cell = middleCell;
    view.playModel = data;
    [view MCPlayerReset];
