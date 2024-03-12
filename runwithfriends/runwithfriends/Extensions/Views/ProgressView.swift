import UIKit

class UICircularProgressView: UIView {
    
    var backgroundCircleColor: UIColor = .black {
        didSet {
            backgroundCircle.strokeColor = backgroundCircleColor.cgColor
        }
    }
    var fillColor: UIColor = .white {
        didSet {
            progressCircle.strokeColor = fillColor.cgColor
        }
    }
    var lineWidth: CGFloat = 25 {
        didSet {
            backgroundCircle.lineWidth = lineWidth
            progressCircle.lineWidth = lineWidth
            initialProgressCircle.lineWidth = lineWidth
        }
    }
    var defaultProgress: Float = 0 {
        didSet {
            updateProgress(progress: defaultProgress)
        }
    }
    
    private var backgroundCircle: CAShapeLayer!
    private var initialProgressCircle: CAShapeLayer!
    private var progressCircle: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private func configureView() {
        drawBackgroundCircle()
        drawProgressCircle()
        drawInitialProgressCircle()
    }
    
    private func drawBackgroundCircle() {
        backgroundCircle = CAShapeLayer()
        let centerPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.width / 2)
        let circleRadius: CGFloat = self.bounds.width / 2
        let circlePath = UIBezierPath(arcCenter: centerPoint,
                                      radius: circleRadius,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        backgroundCircle.path = circlePath.cgPath
        backgroundCircle.strokeColor = UIColor.green.cgColor
        backgroundCircle.fillColor = UIColor.clear.cgColor
        backgroundCircle.lineWidth = 4
        backgroundCircle.lineCap = .round
        backgroundCircle.lineJoin = .round
        backgroundCircle.strokeStart = 0
        backgroundCircle.strokeEnd = 1.0
        self.layer.addSublayer(backgroundCircle)
    }
    
    private func drawInitialProgressCircle() {
        initialProgressCircle = CAShapeLayer()
        let centerPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.width / 2)
        let circleRadius: CGFloat = self.bounds.width / 2
        let circlePath = UIBezierPath(arcCenter: centerPoint,
                                      radius: circleRadius,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        initialProgressCircle.path = circlePath.cgPath
        initialProgressCircle.strokeColor = UIColor.brightPumpkin.cgColor
        initialProgressCircle.fillColor = UIColor.clear.cgColor
        initialProgressCircle.lineWidth = 4
        initialProgressCircle.lineCap = .round
        initialProgressCircle.lineJoin = .round
        initialProgressCircle.strokeStart = 0
        initialProgressCircle.strokeEnd = 0.0
        self.layer.addSublayer(initialProgressCircle)
    }
    
    private func drawProgressCircle() {
        progressCircle = CAShapeLayer()
        let centerPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.width / 2)
        let circleRadius: CGFloat = self.bounds.width / 2
        let circlePath = UIBezierPath(arcCenter: centerPoint,
                                      radius: circleRadius,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = UIColor.red.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = 4
        progressCircle.lineCap = .round
        progressCircle.lineJoin = .round
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = 0.0
        self.layer.addSublayer(progressCircle)
    }
    
    func updateProgress(progress: Float) {
        progressCircle.strokeEnd = CGFloat(progress)
    }
    
    func updateInitialProgress(progress: Float) {
        initialProgressCircle.strokeEnd = CGFloat(progress)
    }
}
