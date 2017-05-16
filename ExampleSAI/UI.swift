//
//  UI.swift
//  ExampleSAI
//
//  Created by Karol Sladecek on 01/05/2017.
//  Copyright © 2017 Orátu, s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
public class SAIButton: UIButton {
    @IBInspectable dynamic private var cornerRadius:CGFloat {
        get {return self.layer.cornerRadius}
        set {self.layer.cornerRadius = newValue}
    }
    private var originalBackgroundColor:UIColor? = nil
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.originalBackgroundColor = self.backgroundColor
        let e = self.isEnabled
        self.isEnabled = e
    }
    
    override public var isEnabled: Bool {
        didSet {
            guard let obc = self.originalBackgroundColor else {return}
            if (self.isEnabled) {
                self.backgroundColor = obc
            } else {
                self.backgroundColor = obc.withAlphaComponent(0.3)
            }
        }
    }
 
}

@IBDesignable
public class SAICircleProgressView: UIView {
    @IBInspectable dynamic private var color:UIColor = UIColor.blue { didSet {DispatchQueue.main.async {self.setNeedsLayout()}}}
    @IBInspectable dynamic private var startAngle:CGFloat = CGFloat.pi * 1.5
    @IBInspectable dynamic private var endAngle:CGFloat = CGFloat.pi * 3.5
    @IBInspectable dynamic private var lineWidth:CGFloat = 2.0
    private var progressLayer = CAShapeLayer()
    private var borderLayer = CAShapeLayer()
    public var progress:Float = 0.0 {
        didSet {
            DispatchQueue.main.async {self.setNeedsLayout()}
        }
    }
    public var maxValue:Int?
    public var currentValue:Int? {
        didSet {
            if let m = self.maxValue, let c = self.currentValue, m > 0 {
                self.progress = Float(c)/Float(m)
            }
        }
    }
    
    override public func layoutSubviews() {
        //setup fill
        if self.progressLayer.superlayer == nil {
            self.borderLayer.fillColor = UIColor.clear.cgColor
            self.borderLayer.strokeColor = UIColor.lightGray.cgColor
            self.borderLayer.lineWidth =  0.5
            self.layer.addSublayer(self.borderLayer)
            self.layer.addSublayer(self.progressLayer)
        }
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: CGPoint(x: CGFloat(self.bounds.width / 2), y: CGFloat(self.bounds.height / 2)), radius: self.bounds.width / 2.0 - self.lineWidth / 2.0, startAngle: self.startAngle, endAngle: (self.endAngle - self.startAngle) * CGFloat(self.progress) + self.startAngle, clockwise: true) // Create our arc, with the correct angles
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.strokeColor = self.color.cgColor
        self.progressLayer.lineWidth =  self.lineWidth
        self.progressLayer.path = bezierPath.cgPath
        let p2 = UIBezierPath()
        p2.addArc(withCenter: CGPoint(x: CGFloat(self.bounds.width / 2), y: CGFloat(self.bounds.height / 2)), radius: self.bounds.width / 2.0 - 0.5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        self.borderLayer.path = p2.cgPath
        if let label = self.viewWithTag(1) as? UILabel {
            if let m = self.maxValue, let c = self.currentValue {
                label.text = "\(c)/\(m)\n\(Int(round(self.progress*100)))%"
            } else {
                label.text = "\(Int(round(self.progress*100)))%"
            }
        }
        super.layoutSubviews()
    }
    
    public override func prepareForInterfaceBuilder() {
        self.maxValue = 4
        self.currentValue = 3
        self.setNeedsLayout()
    }
}
