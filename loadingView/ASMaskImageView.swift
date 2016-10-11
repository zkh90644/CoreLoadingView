//
//  MaskView.swift
//  maskView
//
//  Created by zkhCreator on 8/20/16.
//  Copyright © 2016 zkhCreator. All rights reserved.
//

import UIKit

extension UIImage{
    func imageReplaceColor(_ tintColor:UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        tintColor.setFill()
        
        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func getRadiusImage(_ color:UIColor,radius:CGFloat,size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        
        //        绘制圆角
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addArc(tangent1End: CGPoint(x:0,y:size.height), tangent2End: CGPoint(x:size.width,y:size.height), radius: radius)
        context?.addArc(tangent1End: CGPoint(x:size.width,y:size.height), tangent2End: CGPoint(x:size.width,y:0), radius: radius)
        context?.addArc(tangent1End: CGPoint(x:size.width,y:0), tangent2End: CGPoint(x:0,y:0), radius: radius)
        context?.addArc(tangent1End: CGPoint(x:0,y:0), tangent2End: CGPoint(x:0,y:size.height), radius: radius)
        
        context?.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }

}

open class MaskView: UIView {
    var backgroundImage:UIImage
    var labelViewCache:Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    open var maskViewArray:[UILabel]
    open var maskBackgroundColor:UIColor
    
    open var tempImage:UIImage?
    
    //    用于存储遮住图片在moveView中的移动位置
    fileprivate var infoArray:Array<(offset:CGPoint,image:UIImage,label:UILabel)>
    
    override init(frame: CGRect) {
        maskViewArray = []
        infoArray = []
        self.backgroundImage = UIImage()
        self.maskBackgroundColor = UIColor.white
        
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
    }
    
    convenience public init(image:UIImage,frame:CGRect) {
        self.init(frame:frame)
        
        self.layer.contents = image.cgImage
//        self.image = image
        backgroundImage = image
    }
    
    convenience public init(color:UIColor,radius:CGFloat,frame:CGRect){
        self.init(frame:frame)
        
        let image = UIImage.getRadiusImage(color, radius: radius, size: frame.size)
        self.layer.contents = image.cgImage
//        self.image = image
        backgroundImage = image
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     * 当Move的frame发生改变的时候，对每次的遮罩效果进行重新渲染
     *
     * @param    label    遮住的文字
     *
     * @date     2016-8-21
     * @author   zkh90644@gmail.com
     */
    open func changeMoveImage() {
        
        var flag = false
        infoArray = []
        
        for item in maskViewArray {
            if (self.frame.origin.y + self.frame.height) >= item.frame.origin.y &&
                self.frame.origin.y < item.frame.origin.y + item.frame.height &&
                self.frame.origin.x + self.frame.width >= item.frame.origin.x &&
                self.frame.origin.x < item.frame.origin.x + item.frame.width{
                    changeImage(item)
                flag = true
            }
        }
        
        if flag == true {
            //        重新绘制UIImageView的layer
            UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
            
            //        将界面用背景图先渲染一遍
            backgroundImage.draw(in: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            
            for item in infoArray {
                item.image.draw(in: CGRect.init(x: item.offset.x, y: item.offset.y, width: item.label.frame.width, height: item.label.frame.height))
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            //            关闭上下文
            UIGraphicsEndImageContext()
            
            self.layer.contents = image?.cgImage
//            self.image = image
            
        }else{
            self.layer.contents = backgroundImage.cgImage
//            self.image = backgroundImage
        }
    }
    
    
    /**
     * 获得每个图片被遮住的部分以及与MoveView的位置关系，并进行存储
     *
     * @param    label    遮住的文字
     *
     * @date     2016-8-21
     * @author   zkh90644@gmail.com
     */
    func changeImage(_ label:UILabel){
        
        //        将内容图片绘制到对应的位置
        let offsetX = label.frame.origin.x - self.frame.origin.x
        let offsetY = label.frame.origin.y - self.frame.origin.y
        
        //        创建对应图片在当前位置的修改图
        let contentImage = getMaskImage(label,offset: CGSize.init(width: -offsetX, height: -offsetY))
        
        self.infoArray.append((CGPoint.init(x: offsetX, y: offsetY),contentImage,label))
    }
    
    /**
     * 获得每个图片被遮住的部分
     *
     * @param    label    遮住的文字
     * @param    offset     遮罩图层的图片
     *
     * @returns  UIImage    遮罩效果产生的背景图
     *
     * @date     2016-8-21
     * @author   zkh90644@gmail.com
     */
    func getMaskImage(_ label:UILabel,offset:CGSize) -> UIImage{
        if label.text != nil {
            //        获得问题字图片
            var offsetLabelX:CGFloat = 0,offsetLabelY:CGFloat = 0
            var tempContext:CGContext?
            var currentImage:UIImage?
            
            if labelViewCache.index(forKey: label.text!) == nil {
                UIGraphicsBeginImageContextWithOptions((label.frame.size), false, 0)
                
                tempContext = UIGraphicsGetCurrentContext()
                
                let temp = UILabel.init(frame:label.frame)
                temp.font = label.font
                temp.text = label.text
                temp.textColor = UIColor.white
                temp.sizeToFit()
                if temp.frame.width != label.frame.size.width {
                    offsetLabelX = (label.frame.size.width - temp.frame.width) / 2
                }
                if temp.frame.height != label.frame.size.height {
                    offsetLabelY = (label.frame.size.height - temp.frame.height) / 2
                }
                temp.frame = label.frame
                
                temp.layer.draw(in: tempContext!)
                
                currentImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                //        修正字图片的偏移位置
                UIGraphicsBeginImageContextWithOptions(label.frame.size, false, 0)
                
                tempContext = UIGraphicsGetCurrentContext()
                
                currentImage?.draw(at: CGPoint(x:offsetLabelX,y:offsetLabelY))
                currentImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                //            存入缓存
                self.labelViewCache.updateValue(currentImage!, forKey: label.text!)
            }else{
                currentImage = labelViewCache[label.text!]
            }
            
            //        获得需要去掉的图片
            UIGraphicsBeginImageContextWithOptions((label.frame.size), false, 0)

            backgroundImage.draw(in: CGRect.init(x: offset.width, y: offset.height, width: self.frame.width, height: self.frame.height))
            
            let backImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
            
            let result = maskImage(backImage!, mask: currentImage!)
            
            
            let resultLayer = CALayer()
            resultLayer.frame = CGRect(origin: CGPoint.zero, size: (backImage?.size)!)
            resultLayer.contents = backImage?.cgImage
            
            let maskLayer = CALayer()
            maskLayer.frame = CGRect(origin: CGPoint.zero, size: (backImage?.size)!)
            maskLayer.contents = currentImage?.cgImage
            
            resultLayer.mask = maskLayer
            
            //        获得实际上绘制的UIImage
            let resultCALayer = CALayer()
            resultCALayer.frame = CGRect(origin: CGPoint.zero, size: (backImage?.size)!)
            resultCALayer.contents = backImage?.imageReplaceColor(self.maskBackgroundColor).cgImage
            resultCALayer.addSublayer(resultLayer)
            
            UIGraphicsBeginImageContextWithOptions((label.frame.size), false, 0)
            
            backImage?.imageReplaceColor(self.maskBackgroundColor).draw(in: CGRect.init(origin: CGPoint.zero, size: label.frame.size))
            
            result.draw(in: CGRect.init(origin: CGPoint.zero, size: label.frame.size))
            
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return resultImage!

        }else{
            return UIImage()
        }
    }
    
    /**
     * 生成遮罩效果图
     *
     * @param    image    需要遮罩的图片
     * @param    mask     遮罩图层的图片
     *
     * @returns  UIImage    遮罩效果产生的背景图
     *
     * @date     2016-8-21
     * @author   zkh90644@gmail.com
     */
    func maskImage(_ image:UIImage, mask:(UIImage))->UIImage{
        
        let imageReference = image.cgImage
        let maskReference = mask.cgImage
        
        let imageMask = CGImage(maskWidth: (maskReference?.width)!,
                                          height: (maskReference?.height)!,
                                          bitsPerComponent: (maskReference?.bitsPerComponent)!,
                                          bitsPerPixel: (maskReference?.bitsPerPixel)!,
                                          bytesPerRow: (maskReference?.bytesPerRow)!,
                                          provider: (maskReference?.dataProvider!)!, decode: nil, shouldInterpolate: true)
        
        let maskedReference = imageReference?.masking(imageMask!)
        
        let maskedImage = UIImage(cgImage:maskedReference!)
        
        return maskedImage
    }
    
}
