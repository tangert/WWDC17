import UIKit
import PlaygroundSupport

public class Shape: UIView {
    
    public var sides: Int?
    public var path: UIBezierPath?
    public var color: CGColor?
    public let border = CAShapeLayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(sides: Int, color: CGColor, size: CGFloat, x: CGFloat, y: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: size, height: size))
        
        path = roundedPolygonPath(rect: self.bounds, lineWidth: 5, sides: sides, cornerRadius: 2.5, rotationOffset: CGFloat(M_PI / 2.0))
        
        let view = UIView()
        self.addSubview(view)
        
        border.path = path?.cgPath
        border.lineWidth = 5
        border.strokeColor = UIColor.white.cgColor
        border.fillColor = color
        view.layer.addSublayer(border)
        
        self.sides = sides
        self.color = color
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addSide() {
        sides! += 1
        path?.removeAllPoints()
        path = roundedPolygonPath(rect: self.bounds, lineWidth: 5, sides: sides!, cornerRadius: 2.5, rotationOffset: CGFloat(M_PI / 2.0))
        border.path = path?.cgPath
        
    }
    
    public func changeSidesTo(sideNumber: Int) {
        self.sides = sideNumber
        path?.removeAllPoints()
        path = roundedPolygonPath(rect: self.bounds, lineWidth: 5, sides: sideNumber, cornerRadius: 2.5, rotationOffset: CGFloat(M_PI / 2.0))
        border.path = path?.cgPath
        
    }
    
    //Credit: Sapan Diwakar
    func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0)
        -> UIBezierPath {
            
            let path = UIBezierPath()
            let theta: CGFloat = CGFloat(2.0 * M_PI) / CGFloat(sides)
            let offset: CGFloat = cornerRadius * tan(theta / 2.0)
            let width = min(rect.size.width, rect.size.height)
            let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)
            let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0
            var angle = CGFloat(rotationOffset)
            let corner = CGPoint(x: center.x+(radius-cornerRadius)*cos(angle), y: center.y+(radius-cornerRadius)*sin(angle))
            path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
            
            for _ in 0 ..< sides {
                angle += theta
                let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
                
                let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
                
                let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
                
                let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
                
                path.addLine(to: start)
                path.addQuadCurve(to: end, controlPoint: tip)
            }
            
            path.close()
            
            let bounds = path.bounds
            let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0, y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
            path.apply(transform)
            
            return path
    }
}
