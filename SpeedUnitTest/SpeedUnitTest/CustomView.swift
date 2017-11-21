//
//  CustomView.swift
//
//  Code generated using QuartzCode 1.57.0 on 2017/8/31.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class CustomView: UIView, CAAnimationDelegate {
	
	var layers : Dictionary<String, AnyObject> = [:]
	var completionBlocks : Dictionary<CAAnimation, (Bool) -> Void> = [:]
	var updateLayerValueForCompletedAnimation : Bool = false
	
	
	
	//MARK: - Life Cycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupProperties()
		setupLayers()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		setupProperties()
		setupLayers()
	}
	
	
	
	func setupProperties(){
		
	}
	
	func setupLayers(){
		let oval = CAShapeLayer()
		oval.frame = CGRect(x: (UIScreen.main.bounds.size.width - 182.62)/2, y: 150, width: 182.62, height: 150)
		oval.path = ovalPath().cgPath
		self.layer.addSublayer(oval)
		layers["oval"] = oval
		
		resetLayerProperties(forLayerIdentifiers: nil)
	}
	
	func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		if layerIds == nil || layerIds.contains("oval"){
			let oval = layers["oval"] as! CAShapeLayer
			oval.fillColor   = UIColor.white.cgColor
			oval.strokeColor = UIColor(red:1, green: 0.502, blue:0, alpha:1).cgColor
			oval.lineWidth   = 40
		}
		
		CATransaction.commit()
	}
	
	//MARK: - Animation Setup
	
    func addUntitled1Animation(completionBlock: ((_ finished: Bool) -> Void)? = nil, value1: Float, value2: Float){
		if completionBlock != nil{
			let completionAnim = CABasicAnimation(keyPath:"completionAnim")
			completionAnim.duration = 1.007
			completionAnim.delegate = self
			completionAnim.setValue("Untitled1", forKey:"animId")
			completionAnim.setValue(false, forKey:"needEndAnim")
			layer.add(completionAnim, forKey:"Untitled1")
			if let anim = layer.animation(forKey: "Untitled1"){
				completionBlocks[anim] = completionBlock
			}
		}
		
		let fillMode : String = kCAFillModeForwards
		
		////Oval animation
		let ovalStrokeEndAnim      = CAKeyframeAnimation(keyPath:"strokeEnd")
		ovalStrokeEndAnim.values   = [value1, value2]
		ovalStrokeEndAnim.keyTimes = [0, 1]
		ovalStrokeEndAnim.duration = 1
		
		let ovalUntitled1Anim : CAAnimationGroup = QCMethod.group(animations: [ovalStrokeEndAnim], fillMode:fillMode)
		layers["oval"]?.add(ovalUntitled1Anim, forKey:"ovalUntitled1Anim")
	}
	
	//MARK: - Animation Cleanup
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
		if let completionBlock = completionBlocks[anim]{
			completionBlocks.removeValue(forKey: anim)
			if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
				updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
				removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
			}
			completionBlock(flag)
		}
	}
	
	func updateLayerValues(forAnimationId identifier: String){
		if identifier == "Untitled1"{
			QCMethod.updateValueFromPresentationLayer(forAnimation: (layers["oval"] as! CALayer).animation(forKey: "ovalUntitled1Anim"), theLayer:(layers["oval"] as! CALayer))
		}
	}
	
	func removeAnimations(forAnimationId identifier: String){
		if identifier == "Untitled1"{
			(layers["oval"] as! CALayer).removeAnimation(forKey: "ovalUntitled1Anim")
		}
	}
	
	func removeAllAnimations(){
		for layer in layers.values{
			(layer as! CALayer).removeAllAnimations()
		}
	}
	
	//MARK: - Bezier Path
	
	func ovalPath() -> UIBezierPath{
		let ovalPath = UIBezierPath()
		ovalPath.move(to: CGPoint(x: 21.364, y: 150))
		ovalPath.addCurve(to: CGPoint(x: 32.618, y: 21.364), controlPoint1:CGPoint(x: -11.05, y: 111.37), controlPoint2:CGPoint(x: -6.012, y: 53.778))
		ovalPath.addCurve(to: CGPoint(x: 161.254, y: 32.618), controlPoint1:CGPoint(x: 71.248, y: -11.05), controlPoint2:CGPoint(x: 128.84, y: -6.012))
		ovalPath.addCurve(to: CGPoint(x: 161.254, y: 150), controlPoint1:CGPoint(x: 189.737, y: 66.562), controlPoint2:CGPoint(x: 189.737, y: 116.056))
		
		return ovalPath
	}
	
	
}
