//
//  loadingView.swift
//  loadingView
//
//  Created by zkhCreator on 9/29/16.
//  Copyright © 2016 zkhCreator. All rights reserved.
//

import UIKit

enum Direction {
    case top,right,left,bottom
}

class loadingView: MaskView {
    
    var perscent:CGFloat = 0
    var coverColor:UIColor = UIColor.clear
    var directionTo:Direction = .top
    
    var EmitterSpeed:CGFloat = 10
    
    var coverLayer:CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
//        gradientLayer.backgroundColor = UIColor.white.cgColor
//        设置位置
        gradientLayer.startPoint = CGPoint(x:0.0,y:0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let locations = [0.25,0.5,0.75]
        gradientLayer.locations = locations as [NSNumber]?
        
        return gradientLayer
    }()
    lazy var emitterLayer:CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()
        
        emitterLayer.emitterShape = kCAEmitterLayerLine
        
        return emitterLayer
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [-1.5,-1.25,-1]
        gradientAnimation.toValue = [2.0,2.25,2.50]
        gradientAnimation.duration = 3
        gradientAnimation.repeatCount = Float.infinity
        coverLayer.add(gradientAnimation, forKey: "gradient")
        
    }
    
    convenience init(frame:CGRect,directionTo:Direction,coverColor:UIColor){
        self.init(frame:frame)

        self.coverColor = coverColor
        self.coverLayer.backgroundColor = coverColor.cgColor
        self.directionTo = directionTo
        
        setUpEmitterLayer()
        setUpCoverLayer(directionTo: directionTo, coverColor: coverColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCoverLayer(directionTo:Direction,coverColor:UIColor) {
        
//        添加子layer
        self.layer.addSublayer(coverLayer)
        
//        设置加载方向
        switch directionTo {
        case .top:
            coverLayer.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 0)
            coverLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
            coverLayer.startPoint = CGPoint(x: 0.5, y: 1)
            coverLayer.endPoint = CGPoint(x: 0.5, y: 0)
        case .bottom:
            coverLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0)
            coverLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
            coverLayer.startPoint = CGPoint(x: 0.5, y: 0)
            coverLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .left:
            coverLayer.frame = CGRect(x: self.frame.width, y: 0, width: 0, height: self.frame.height)
            coverLayer.anchorPoint = CGPoint(x: 1, y: 0.5)
            coverLayer.startPoint = CGPoint(x: 1, y: 0.5)
            coverLayer.endPoint = CGPoint(x: 0, y: 0.5)
        case .right:
            coverLayer.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.height)
            coverLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
            coverLayer.startPoint = CGPoint(x: 0, y: 0.5)
            coverLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }
        
        //设置渐变效果
        var rgba = coverColor.getRGBA()
        self.layer.backgroundColor = UIColor.white.cgColor
        
        if rgba.red > rgba.blue && rgba.red > rgba.green {
            rgba.green += 0.1
            rgba.blue += 0.1
        }else if rgba.green > rgba.blue && rgba.green > rgba.red{
            rgba.blue += 0.1
            rgba.red += 0.1
        }else if rgba.blue > rgba.green && rgba.blue > rgba.red {
            rgba.red += 0.1
            rgba.green += 0.1
        }else{
            rgba.blue += 0.1
            rgba.green += 0.1
            rgba.red += 0.1
        }
        
        let middleColor = UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: 1)
        
        let colors = [
            coverColor.cgColor,
            middleColor.cgColor,
            coverColor.cgColor
        ]
        
        coverLayer.colors = colors
    }

    func setUpEmitterLayer() {
        self.layer.addSublayer(emitterLayer)
        
        var xAcceleration:CGFloat = 0
        var yAcceleration:CGFloat = 0
        var position = CGPoint.zero
        var size = CGSize.zero
        
        switch directionTo {
        case .bottom:
            xAcceleration = 0
            yAcceleration = -20
            position = CGPoint(x: 0.5 * self.layer.frame.width, y: self.layer.frame.height + 20)
            size = CGSize(width: self.layer.frame.width, height: 20)
            break;
        case .top:
            xAcceleration = 0
            yAcceleration = 20
            position = CGPoint(x: 0.5 * self.layer.frame.width, y: -20)
            size = CGSize(width: self.layer.frame.width, height: 20)
            break
        case .left:
            xAcceleration = 20
            yAcceleration = 0
            position = CGPoint(x: -20, y: 0.5 * self.layer.frame.height)
            size = CGSize(width: 20, height: self.frame.height)
            break
        case .right:
            xAcceleration = -20
            yAcceleration = 0
            position = CGPoint(x: self.layer.frame.width + 20, y: 0.5 * self.layer.frame.height)
            size = CGSize(width: 20, height: self.frame.height)
            break
        }
        
        emitterLayer.emitterPosition = position
        emitterLayer.emitterSize = size
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = createEmitterCell(color: coverColor, size: CGSize(width:5,height:5)).cgImage
        emitterCell.birthRate = 2
        emitterCell.lifetime = 5
        emitterCell.xAcceleration = xAcceleration
        emitterCell.yAcceleration = yAcceleration
        emitterCell.velocityRange = 10
        emitterCell.velocity = 0
        emitterCell.scaleRange = 0.5
        emitterCell.scaleSpeed = -0.12
        emitterCell.scale = 1

        emitterLayer.emitterCells = [emitterCell]
        
    }
    
    func animateWith(perscent:CGFloat) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if perscent >= 1 {
                
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        switch self.directionTo {
                        case .top:
                            self.coverLayer.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 0)
                        case .bottom:
                            self.coverLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0)
                        case .left:
                            self.coverLayer.frame = CGRect(x: self.frame.width, y: 0, width: 0, height: self.frame.height)
                        case .right:
                            self.coverLayer.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.height)
                        }
                    })
                    self.coverLayer.opacity = 0
                    CATransaction.commit()
                    
                })
                self.emitterLayer.opacity = 0
                
                CATransaction.commit()

            }else{
                self.emitterLayer.opacity = 1
                self.coverLayer.opacity = 1
            }
        }
        
        self.perscent = perscent
        
        switch directionTo {
        case .bottom:
            self.coverLayer.frame = CGRect(origin: self.coverLayer.frame.origin, size: CGSize(width: self.frame.size.width, height: perscent * self.frame.size.height))
            break;
        case .top:
            self.coverLayer.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: -perscent * self.frame.size.height)
            break;
        case .right:
            self.coverLayer.frame = CGRect(origin: self.coverLayer.frame.origin, size: CGSize(width: self.frame.size.width * perscent, height: self.frame.size.height))
            break;
        case .left:
            self.coverLayer.frame = CGRect(x: self.frame.width, y: 0, width: -self.frame.size.width * perscent, height: self.frame.height)
            break;
        }
        CATransaction.commit()
    }
    
    
    func createEmitterCell(color:UIColor,size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.addEllipse(in: CGRect(origin:CGPoint.zero,size:size))
        self.coverColor.setFill()
        context?.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
        
    }
}


extension UIColor{
    func getRGBA() -> (red:CGFloat,green:CGFloat,blue:CGFloat,alpha:CGFloat) {
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r,g,b,a)
    }
    
    func getHUEA() -> (hue:CGFloat,saturation:CGFloat,brightness:CGFloat,alpha:CGFloat) {
        var h:CGFloat = 0
        var s:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        print(h)
        print(s)
        print(b)
        print(a)
        
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return (h,s,b,a)
    }
}
