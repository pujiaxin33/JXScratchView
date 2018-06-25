//
//  JXScratchTicketView.swift
//  JXScratchTicketView
//
//  Created by jiaxin on 2018/6/25.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

@objc public protocol JXScratchViewDelegate {
    //当前已经刮了多少百分比
    func scratchView(scratchView: JXScratchView, didScratched percent: Float)
}

open class JXScratchView: UIView {
    open weak var delegate: JXScratchViewDelegate?
    open var scratchContentView: UIView!
    open var scratchMaskView: UIView!
    open var strokeLineCap: String = kCALineCapRound {
        didSet {
            maskLayer.lineCap = strokeLineCap
        }
    }
    open var strokeLineWidth: CGFloat = 20 {
        didSet {
            maskLayer.lineWidth = strokeLineWidth
        }
    }
    private var maskLayer: CAShapeLayer!
    private var maskPath: UIBezierPath!


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

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        scratchContentView?.frame = self.bounds
        scratchMaskView?.frame = self.bounds
    }

    //展示全部
    open func showContentView() {
        self.scratchContentView.layer.mask = nil
    }

    open func resetState() {
        self.maskPath.removeAllPoints()
        self.maskLayer.path = nil
        self.scratchContentView.layer.mask = maskLayer
    }

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

        updateScratchScopePercent()
    }

    private func updateScratchScopePercent() {
        let image = self.getImageFromContentView()
        var percent = 1 - self.getAlphaPixelPercent(img: image)
        percent = max(0, min(1, percent))
        self.delegate?.scratchView(scratchView: self, didScratched: percent)
    }

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

    private func getImageFromContentView() -> UIImage {
        let size = scratchContentView.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        scratchContentView.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}
