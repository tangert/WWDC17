import UIKit
import PlaygroundSupport
import Foundation

public class NationalBirthViewController: UIViewController {

    //All the triangles for the center of city.
    var triangles = [Shape]()

    //Initial frame width and height
    var frameWidth: CGFloat!
    var frameHeight: CGFloat!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        frameWidth = UIScreen.main.bounds.width
        frameHeight = UIScreen.main.bounds.height
        
        self.view.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        self.view.backgroundColor = UIColor.white
        
        let centerX = UIScreen.main.bounds.width/2
        let centerY = UIScreen.main.bounds.height/2
        
        //Adding 50 triangles to the traingles array
        for _ in 0..<50 {
            let triangle = Shape(sides: 3, color: getRandomColor().cgColor, size: 125, x: centerX, y: centerY)
            triangles.append(triangle)
        }
        
        //Heart beat animation
        var delay: Double = 0
        
        var triangleCenter: CGPoint!
        
        //Figuring out the proper center for the triangles
        let orientation = self.preferredInterfaceOrientationForPresentation
        
        //the center of the display is about a quarter of the screen in 
        let widthFactor = UIScreen.main.bounds.width/4
        let heightFactor = UIScreen.main.bounds.height/4
        
        switch(orientation){
            
        case .landscapeLeft:
            triangleCenter = CGPoint(x: centerX - widthFactor, y: centerY)
            
        case .landscapeRight:
            triangleCenter = CGPoint(x: centerX - widthFactor, y: centerY)
            
        case .portrait:
            triangleCenter = CGPoint(x: centerX, y: centerY - heightFactor)
            
        case .portraitUpsideDown:
            triangleCenter = CGPoint(x: centerX, y: centerY - heightFactor)
            
        default:
            break
        }

        
        for i in 0..<self.triangles.count {
            self.view.addSubview(triangles[i])
            
            
            triangles[i].center = triangleCenter
            
            
            UIView.animate(withDuration: 0.5,
                           delay: TimeInterval(delay),
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 5,
                           options: [.repeat,.autoreverse],
                           animations: {
                            
                            let currentShape = self.triangles[i]
                            
                            currentShape.frame = currentShape.frame.offsetBy(
                                dx: CGFloat(i/2)*sin(CGFloat(i)),
                                dy: CGFloat(i/2)*cos(CGFloat(i))
                                
                            )}, completion: nil)
            
            delay += 0.05
            
        }
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        circle.backgroundColor = UIColor.lightGray
        circle.layer.cornerRadius = circle.frame.width/2
        circle.center = self.view.center
        circle.alpha = 0
        
        let shrunkenView = CGAffineTransform(scaleX: 0.5, y: 0.5)
        circle.transform = shrunkenView
        self.view.addSubview(circle)
        
        var delay: Double = 0
        var animationComplete = false
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            
            //this goes form the top of the triangle stack
            for i in (0..<self.triangles.count).reversed() {
                
                let currentShape = self.triangles[i]
                
                
                UIView.animate(withDuration: 0.025, delay: TimeInterval(delay), options: .curveEaseInOut, animations: {
                    
                    currentShape.frame = currentShape.frame.offsetBy(
                        dx: CGFloat(i*30)*sin(CGFloat(i)),
                        dy: CGFloat(i*30)*cos(CGFloat(i)))
                    
                    
                    let rotate = CGAffineTransform(rotationAngle: (180 * CGFloat(M_PI)) / 180)
                    
                    currentShape.transform = rotate
                    currentShape.alpha = 0
                    
                }, completion: nil)
                
                delay += 0.025
                
            }
            
        }, completion: { (animationComplete) in
            
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseInOut, animations: {
                
                self.showNosides(circle: circle)
                
            }, completion: nil)
            
        })
        
        print("Touched parent view!")
        
    }
    
    func showNosides(circle: UIView) {
        UIView.animate(withDuration: 1, delay: 2, usingSpringWithDamping: 15, initialSpringVelocity: 30, options: .curveEaseInOut, animations: {
            
            let springTransform = CGAffineTransform.identity
            circle.transform = springTransform
            circle.alpha = 1
            
        }, completion: nil)
    }
    
    private func getRandomColor() -> UIColor{
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
    
}
