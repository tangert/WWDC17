import UIKit
import PlaygroundSupport
import Foundation

public class HateSpawnsViewController: UIViewController {

    public var hateLimit: Int!
    var allHate = [Shape]()
    var circle: UIView!
    var collision: UICollisionBehavior?
    var shrinkFactor: CGFloat = 0.8
    
    //dynamics
    var animator: UIDynamicAnimator!
    lazy var center: CGPoint = {
        return CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
    }()
    
    lazy var radialGravity: UIFieldBehavior = {
        let radialGravity: UIFieldBehavior = UIFieldBehavior.radialGravityField(position: self.circle.center)
        
        radialGravity.region = UIRegion(radius: 800)
        radialGravity.strength = 20
        radialGravity.falloff = 1
        radialGravity.minimumRadius = 700
        return radialGravity
    }()
    
    lazy var vortex: UIFieldBehavior = {
        let vortex: UIFieldBehavior = UIFieldBehavior.vortexField()
        vortex.position = self.circle.center
        vortex.region = UIRegion(radius: self.view.frame.height/2)
        vortex.strength = 0.1
        return vortex
    }()
    
    func getRandomColor() -> UIColor{
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: 0, y: 0, width: 350, height: 550)
        self.view.backgroundColor = UIColor.white
        
        circle = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        circle.backgroundColor = UIColor.lightGray
        circle.layer.cornerRadius = circle.frame.width/2
        
        
        let orientation = self.preferredInterfaceOrientationForPresentation
        let centerX = UIScreen.main.bounds.width/2
        let centerY = UIScreen.main.bounds.height/2
        var shapeCenter: CGPoint!
        
        //the center of the display is about a quarter of the screen in
        let widthFactor = UIScreen.main.bounds.width/4
        let heightFactor = UIScreen.main.bounds.height/4
        
        //Adjusting for the width of the screen during landscape mode
        switch(orientation){
            
        case .landscapeLeft:
            shapeCenter = CGPoint(x: centerX - widthFactor, y: centerY)
            
        case .landscapeRight:
            shapeCenter = CGPoint(x: centerX - widthFactor, y: centerY)
            
        case .portrait:
            shapeCenter = CGPoint(x: centerX, y: centerY - heightFactor)
            
        case .portraitUpsideDown:
            shapeCenter = CGPoint(x: centerX, y: centerY - heightFactor)
            
        default:
            break
        }
        
        
        circle.center = shapeCenter
        circle.layer.zPosition = 999
        self.view.addSubview(circle)
        
        let breatheIn = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 2, delay: 0, options: [.autoreverse,.repeat], animations: {
            
            self.circle.transform = breatheIn
            
        }, completion: nil)
        
        
        
        let itemBehavior = UIDynamicItemBehavior(items: allHate)
        itemBehavior.density = 1
        
        self.animator = UIDynamicAnimator(referenceView: self.view)
        animator.addBehavior(itemBehavior)
        
        animator.addBehavior(radialGravity)
        animator.addBehavior(vortex)
        
        
        collision = UICollisionBehavior(items: allHate)
        collision!.translatesReferenceBoundsIntoBoundary = true;
        animator.addBehavior(self.collision!)
//        collision!.collisionDelegate = self
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard allHate.count < hateLimit else {
            print("that's enough hate")
            return
        }
        
        let touchY = touches.first?.location(in: self.view).y
        let touchRadiusY = touchY! - self.view.center.y
        
        let touchX = touches.first?.location(in: self.view).x
        let touchRadiusX = touchX! - self.view.center.x
        
        print("X: \(touchRadiusX)")
        print("Y: \(touchRadiusY)")
        
        //this prevents adding the shape too out of bounds
        guard (touchRadiusY < self.radialGravity.minimumRadius)
            && (touchRadiusX < self.radialGravity.minimumRadius) else {
                print("touch closer")
                return
        }
        
        let hateShape = Shape(sides: 3, color: UIColor.red.cgColor, size: 100, x: touchX!, y: touchY!)
        let shrunkenState = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
        hateShape.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        
        //Scale in
        UIView.animate(withDuration: 0.2, animations: {
            hateShape.transform = CGAffineTransform.identity
        })
        
        self.view.addSubview(hateShape)
        
        
        self.allHate.append(hateShape)
        UIView.animate(withDuration: 0.2) {
            self.circle.transform = CGAffineTransform.init(scaleX: self.shrinkFactor, y: self.shrinkFactor)
        }
        
        shrinkFactor*=0.75
        vortex.addItem(hateShape) // 14
        radialGravity.addItem(hateShape) // 15
        
        
    }
    
}
