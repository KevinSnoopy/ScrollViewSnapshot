//
//  ViewController.swift
//  Demo
//
//  Created by mac on 2022/1/17.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension UIScrollView {
    /**
     scrollview截长图
     可以保留阴影
     图片拼接
     */
    
    func snapShotOfFullContent(_ completion: ((_ image: UIImage?) -> Void)?) {
        let orginOffset = contentOffset,
            color = backgroundColor ?? .white,
            height = frame.height
        var pageNum = 1,
            imageView: UIImageView?
        if contentSize.height > height {
            /**
             如果超过一屏需要对图片进行轮循截图
             */
            pageNum = Int(floorf(Float(contentSize.height/height)))
            UIGraphicsBeginImageContextWithOptions(frame.size, true, UIScreen.main.scale)
            if let _ = UIGraphicsGetCurrentContext(), let superView = superview {
                superView.drawHierarchy(in: frame, afterScreenUpdates: false)
                if let image = UIGraphicsGetImageFromCurrentImageContext() {
                    /**
                     获取快照
                     轮循截图时需要对滚动图进行滚动
                     这时通过对当前屏幕截图覆盖制造滚动图未改变的假象
                     */
                    imageView = UIImageView(image: image)
                    imageView?.backgroundColor = color
                    imageView?.frame = frame
                    if let view = imageView {
                        superView.addSubview(view)
                    }
                }
            }
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(contentSize, true, UIScreen.main.scale)
        if let block = completion, let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.setStrokeColor(color.cgColor)
            drawSnapShotOfPage(index: 0, maxIndex: pageNum) {
                /**
                 完成截图后移除滚动图上的快照
                 */
                if let _ = imageView?.superview {
                    imageView?.removeFromSuperview()
                    imageView = nil
                }
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.contentOffset = orginOffset
                block(image)
            }
        }
    }
    
    private func drawSnapShotOfPage( index: Int, maxIndex: Int, completion: (() -> Void)?) {
        /**
         对指定位置截图
         */
        let width = frame.width,
            height = frame.height
        setContentOffset(CGPoint(x: 0, y: CGFloat(index)*height), animated: false)
        let pageFrame = CGRect(x: 0, y: CGFloat(index)*height, width: width, height: height)
        if let block = completion {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.drawHierarchy(in: pageFrame, afterScreenUpdates: true)
                if index < maxIndex {
                    self.drawSnapShotOfPage(index: index+1, maxIndex: maxIndex, completion: block)
                }else {
                    block()
                }
            }
        }
    }
    
}
