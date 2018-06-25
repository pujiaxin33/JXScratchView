# JXScratchView
一个万能的刮刮乐控件。无论是UILabel、UIImageView，还是自定义视图，只要是UIView都可以用来刮。代码简单，功能强大，你值得拥有！

![彩票刮刮乐.png](https://upload-images.jianshu.io/upload_images/1085173-3873a79943af2d26.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 前言
这是一个简单却功能强大的刮刮乐视图，几行代码就可以实现刮刮乐效果，而且性能良好。下面有美女福利哟，相信我，你会喜欢的😍😍

相信大家都买过彩票刮刮乐，总是会抱着中大奖的情况去刮，希望自己是最幸运的那一个，刮中五百万，抱得美人归，从此走上人生巅峰。但现实往往是你口袋里面的几十块零钱，几分钟就被消费殆尽了😂
许多APP也集成了这一功能，比如用支付宝线下支付后就有刮刮乐。虽然刮中的都是些没多大用的优惠券，但总是会吸引人去刮一刮，万一中了大奖呢😎

# 实现效果
多说无益，先来看看实现的效果吧

## 彩票刮刮乐
![彩票刮刮乐.gif](https://upload-images.jianshu.io/upload_images/1085173-fdbdc50c422e771a.gif?imageMogr2/auto-orient/strip)


## 美女刮刮乐
![美女刮刮乐.gif](https://upload-images.jianshu.io/upload_images/1085173-1cf693ff93b33ff8.gif?imageMogr2/auto-orient/strip)

参照了一个叫做“撕掉她的衣服”APP，效果非常sexy，有没有一种心跳加快，血脉膨胀的感觉。（相信大家迫不及待想要体验一下了，点击[https://fir.im/JXScratchView](https://fir.im/JXScratchView)，通过safari打开该链接，安装之后信任证书，就可以快速体验了）**相信我在空白处，双击一下，你会发现新大陆😍**

# 调研
在网上搜索了一番，方案基本上就是这种：[链接](https://www.jianshu.com/p/7c2042764e0c)。
核心代码：
```objc
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 触摸任意位置
    UITouch *touch = touches.anyObject;
    // 触摸位置在图片上的坐标
    CGPoint cententPoint = [touch locationInView:self.imageView];
    // 设置清除点的大小
    CGRect  rect = CGRectMake(cententPoint.x, cententPoint.y, 20, 20);
    // 默认是去创建一个透明的视图
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0);
    // 获取上下文(画板)
    CGContextRef ref = UIGraphicsGetCurrentContext();
    // 把imageView的layer映射到上下文中
    [self.imageView.layer renderInContext:ref];
    // 清除划过的区域
    CGContextClearRect(ref, rect);
    // 获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束图片的画板, (意味着图片在上下文中消失)
    UIGraphicsEndImageContext();
    
    self.imageView.image = image;
}
```
缺点很明显：
1、画笔是矩形的，看着很难受；
2、绘画的核心代码用了CoreGraphics，每次移动都要重新开启一个context上下文，绘制image，对CPU的性能有很大的消耗。[点击该链接，详细了解CAShapeLayer比CG的优势](https://zsisme.gitbooks.io/ios-/content/chapter6/cashapelayer.html)
所以，我想了一个骚技巧，用CAShapeLayer作为mask来实现该效果。[点击该链接，了解mask图层遮罩](https://zsisme.gitbooks.io/ios-/content/chapter4/layer-masking.html)

# 原理
![图层解释.png](https://upload-images.jianshu.io/upload_images/1085173-9e0a0ddb897f7db4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
如图所示，只要用户滑动的时候，更新contentView的maskLayer的path，就可以实现刮刮乐的效果了。代码如下：
- 初始化
```swift
/// 指定初始化器
    ///
    /// - Parameters:
    ///   - contentView: 内容视图，比如彩票的奖品详情内容。（需要隐藏起来的内容）
    ///   - maskView: 遮罩视图
    public init(contentView: UIView, maskView: UIView) {
        super.init(frame: CGRect.zero)

        scratchMaskView = maskView
        self.addSubview(scratchMaskView)

        scratchContentView = contentView
        self.addSubview(scratchContentView)

        maskLayer = CAShapeLayer()
        maskLayer.strokeColor = UIColor.red.cgColor
        maskLayer.lineWidth = strokeLineWidth
        maskLayer.lineCap = strokeLineCap
        scratchContentView?.layer.mask = maskLayer

        maskPath = UIBezierPath()
    }
```
- 绘画核心代码
```swift
open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let point = touch.location(in: scratchContentView)
        maskPath.move(to: point)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let point = touch.location(in: scratchContentView)
        maskPath.addLine(to: point)
        maskPath.move(to: point)
        maskLayer.path = maskPath.cgPath
    }
```
- 获取已经刮了多少百分比，比如用户刮了70%的时候，就显示全部。
```swift
//获取透明像素占总像素的百分比
    private func getAlphaPixelPercent(img: UIImage) -> Float {
        //计算像素总个数
        let width = Int(img.size.width)
        let height = Int(img.size.height)
        let bitmapByteCount = width * height

        //得到所有像素数据
        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width,
                                space: colorSpace,
                                bitmapInfo: CGBitmapInfo(rawValue:
                                    CGImageAlphaInfo.alphaOnly.rawValue).rawValue)!
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.clear(rect)
        context.draw(img.cgImage!, in: rect)


        //计算透明像素个数
        var alphaPixelCount = 0
        for x in 0...Int(width) {
            for y in 0...Int(height) {
                if pixelData[y * width + x] == 0 {
                    alphaPixelCount += 1
                }
            }
        }

        free(pixelData)

        return Float(alphaPixelCount) / Float(bitmapByteCount)
    }
    //展示全部
    open func showContentView() {
        self.scratchContentView.layer.mask = nil
    }
```
# 使用
- 彩票刮刮乐示例代码
```swift
        let contentView = UILabel()
        contentView.backgroundColor = UIColor.white
        contentView.textAlignment = .center
        contentView.font = UIFont.systemFont(ofSize: 25)
        contentView.text = "恭喜你刮中500万"
        contentView.numberOfLines = 0

        let maskView = UIView()
        maskView.backgroundColor = UIColor.lightGray

        let ratio = self.bounds.size.width/400
        scratchView = JXScratchView(contentView: contentView, maskView: maskView)
        scratchView.delegate = self
        scratchView.strokeLineWidth = 25
        scratchView.strokeLineCap = kCALineCapRound
        scratchView.frame = CGRect(x: 33*ratio, y: 140*ratio, width: 337*ratio, height: 154*ratio)
        addSubview(scratchView)
```
- 指定使用JXScratchView的`public init(contentView: UIView, maskView: UIView)`初始化器，只需要传入UIView及其子类就可以了。
- `strokeLineCap`属性设置stroke形状，默认`kCALineCapRound`
- `strokeLineWidth`属性设置stroke线宽，默认20
- 遵从`JXScratchViewDelegate`，实现`func scratchView(scratchView: JXScratchView, didScratched percent: Float)`代理方法，就可以实时获取刮刮乐的百分比。
- 建议新建一个UIView，把JXScratchView封装进去，可以参考`JXScratchTicketView`

# Github仓库地址
[仓库地址，喜欢就star一下❤️](https://github.com/pujiaxin33/JXScratchView) 
