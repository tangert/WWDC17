import UIKit
import PlaygroundSupport
import Foundation
import CoreMotion

public class RoundingOutViewController: UIViewController {

    //Dynamics
    var animator: UIDynamicAnimator?
    var collision: UICollisionBehavior?
    var push: UIPushBehavior?
    let gravity = UIGravityBehavior()
    
    //Collision limit and count
    //45 is when Nosides "becomes a circle" again
    var collisionCount: Float = 0
    var collisionLimit: Float = 45
    
    //This is for detection of the first collision.
    var collisionOccured = false
    
    //The actual shape in the center of the screen
    var centerShape: Shape?
    
    //Core motion
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    //ProgressView
    var progressView: UIProgressView?

    //Initial frame width and height
    var frameWidth: CGFloat!
    var frameHeight: CGFloat!
    
    
    func getRandomColor() -> UIColor{
        //Generate between 0 to 1
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        frameWidth = UIScreen.main.bounds.width
        frameHeight = UIScreen.main.bounds.height
        
        self.view.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        self.view.backgroundColor = UIColor.white
        
        let centerX = UIScreen.main.bounds.width/2
        let centerY = UIScreen.main.bounds.height/2
        
        let heightOffset = frameHeight/10
        self.view.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        self.view.backgroundColor = UIColor.white
        
        //Progress view
        
        let orientation = self.preferredInterfaceOrientationForPresentation
        var shapeCenter: CGPoint!
        
        //the center of the display is about a quarter of the screen in
        let widthFactor = UIScreen.main.bounds.width/4
        let heightFactor = UIScreen.main.bounds.height/4
        
        //Adjusting for the width of the screen during landscape mode
        switch(orientation){
            
        case .landscapeLeft:
            frameWidth = self.frameWidth/2
            shapeCenter = CGPoint(x: centerX - widthFactor, y: centerY)
            
        case .landscapeRight:
            frameWidth = self.frameWidth/2
            shapeCenter = CGPoint(x: centerX - widthFactor, y: centerY)
            
        case .portrait:
            shapeCenter = CGPoint(x: centerX, y: centerY - heightFactor)
            
        case .portraitUpsideDown:
            shapeCenter = CGPoint(x: centerX, y: centerY - heightFactor)

        default:
            break
        }

        
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: heightOffset, width: frameWidth, height: 10))
        self.view.addSubview(progressView!)

        //Give a large amount of sides at first to appear like a circle
        centerShape = Shape(sides: 200, color: UIColor.lightGray.cgColor, size: 200, x: self.view.center.x, y: self.view.center.y)
        self.view.addSubview(centerShape!)
        centerShape?.center = shapeCenter
        
        self.animator = UIDynamicAnimator(referenceView: self.view)
        
        //Collision behavior
        self.collision = UICollisionBehavior(items: [centerShape!])
        self.collision!.translatesReferenceBoundsIntoBoundary = true;
        self.animator!.addBehavior(self.collision!)
        collision!.collisionDelegate = self
        
        
        //Push behavior
        self.push = UIPushBehavior(items: [centerShape!], mode: UIPushBehaviorMode.instantaneous);
        self.push!.setAngle( CGFloat(M_PI/Double(-2)) , magnitude: 5);
        self.animator!.addBehavior(self.push!);
        
        gravity.addItem(centerShape!)
        animator?.addBehavior(gravity);
        
        centerShape?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(sender:))))
        
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        motionManager.gyroUpdateInterval = 0.05
        
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            
            if let gyroData = data {
                
                let x = CGFloat(gyroData.rotationRate.x)
                let y = CGFloat(gyroData.rotationRate.y)
                
                //Go in opposite directions to feel more intuitive
                var p = CGVector(dx: y, dy: x)
                
                let orientation = self.preferredInterfaceOrientationForPresentation
                
                switch(orientation){
                    
                case .landscapeLeft:
                    let t = p.dx
                    p.dx = 0-p.dy
                    p.dy = t
                    
                case .landscapeRight:
                    let t = p.dx
                    p.dx = p.dy
                    p.dy = 0-t
                    
                case .portraitUpsideDown:
                    p.dx *= -1
                    p.dy *= -1
                default:
                    print("default p")
                    break
                    
                }
                
                self.gravity.gravityDirection = p
            }
        }
        

        
    }
    
    public func tap(sender: UITapGestureRecognizer) {
        self.push!.active = false;
        self.push!.setAngle( CGFloat(M_PI/Double(-2)) , magnitude: 10);
        self.push!.active = true;
        
    }
}

extension RoundingOutViewController: UICollisionBehaviorDelegate {
    public func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        
        print("Began")
        print("Point of contact: \(p)")
        
        guard collisionCount < collisionLimit else {
            print("you became a circle again bro")
            return
        }
        
        var shape = item as! Shape
        let shrunkenState = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        
        //initial side count
        if !collisionOccured {
            
            shape.changeSidesTo(sideNumber: 3)
            collisionOccured = true

        } else {
            shape.addSide()
            collisionCount+=1
            
            let progressRate = Float(1)/collisionLimit
            print("Progress rate: \(progressRate)")
            self.progressView?.progress += Float(progressRate)
            
            
        }
        
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            
            shape.transform = shrunkenState
            shape.border.fillColor = UIColor.lightGray.cgColor
            
        })
        
    }
    
    public func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        
        print("Ended!")
    }
}
