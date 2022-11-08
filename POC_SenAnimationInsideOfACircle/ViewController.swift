//
//  ViewController.swift
//  BP_viewcode
//
//  Created by Caio Soares on 08/11/22.
//

import UIKit

class ViewController: UIViewController {
    
    private let myCircle: myCircleView = {
        let circle = myCircleView(frame: .zero, sizeOfTheCircle: 300)
        circle.translatesAutoresizingMaskIntoConstraints = false
        return circle
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        buildLayout()
    }
    
}

extension ViewController: ViewCoding {
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupHierarchy() {
        view.addSubview(myCircle)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            myCircle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            myCircle.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            myCircle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            myCircle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
}

// MARK: - Circle View

class myCircleView: UIView {
    
    var sizeOfTheCircle: CGFloat?
    
    private lazy var circularFrame: UIView = {
        let circle = UIView(frame: CGRectMake(10,20,sizeOfTheCircle!,sizeOfTheCircle!))
        circle.backgroundColor = .red
        circle.layer.cornerRadius = sizeOfTheCircle! / 2
        circle.translatesAutoresizingMaskIntoConstraints = false
        return circle
    }()
    
    private lazy var myWave: myWaveView = {
        let waves = myWaveView()
        waves.layer.cornerRadius = sizeOfTheCircle! / 2
        waves.translatesAutoresizingMaskIntoConstraints = false
        waves.clipsToBounds = true
        return waves
    }()
    
    init(frame: CGRect, sizeOfTheCircle: CGFloat) {
        super.init(frame: .zero)
        self.sizeOfTheCircle = sizeOfTheCircle
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension myCircleView: ViewCoding {
    func setupView() {
        
    }
    
    func setupHierarchy() {
        self.addSubview(circularFrame)
        circularFrame.addSubview(myWave)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            circularFrame.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circularFrame.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            circularFrame.widthAnchor.constraint(equalToConstant: sizeOfTheCircle!),
            circularFrame.heightAnchor.constraint(equalToConstant: sizeOfTheCircle!),
            
            myWave.topAnchor.constraint(equalTo: circularFrame.topAnchor),
            myWave.bottomAnchor.constraint(equalTo: circularFrame.bottomAnchor),
            myWave.leadingAnchor.constraint(equalTo: circularFrame.leadingAnchor),
            myWave.trailingAnchor.constraint(equalTo: circularFrame.trailingAnchor),
        ])
    }
    
}

// MARK: - Wave View

class myWaveView: UIView {
    
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private let maxAmplitude: CGFloat = 0.1
    private let maxTidalVariation: CGFloat = 0.1
    private let amplitudeOffset = CGFloat.random(in: -0.5 ... 0.5)
    private let amplitudeChangeSpeedFactor = CGFloat.random(in: 4 ... 8)

    private let defaultTidalHeight: CGFloat = 0.50
    private let saveSpeedFactor = CGFloat.random(in: 4 ... 8)

    private lazy var background: UIView = {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.addSublayer(shapeLayer)
        return background
    }()

    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.cyan.cgColor
        shapeLayer.fillColor = UIColor.cyan.cgColor
        return shapeLayer
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            displayLink?.invalidate()
        }
   }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        shapeLayer.path = wave(at: 0)?.cgPath
    }
}

private extension myWaveView {

    func configure() {
        addSubview(background)
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: self.topAnchor),
            background.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])

        startDisplayLink()
    }

    func wave(at elapsed: Double) -> UIBezierPath? {
        guard bounds.width > 0, bounds.height > 0 else { return nil }

        func f(_ x: CGFloat) -> CGFloat {
            let elapsed = CGFloat(elapsed)
            let amplitude = maxAmplitude * abs(fmod(elapsed / 2, 3) - 1.5)
            let variation = sin((elapsed + amplitudeOffset) / amplitudeChangeSpeedFactor) * maxTidalVariation
            let value = sin((elapsed / saveSpeedFactor + x) * 4 * .pi)
            return value * amplitude / 2 * bounds.height + (defaultTidalHeight + variation) * bounds.height
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))

        let count = Int(bounds.width / 10)

        for step in 0 ... count {
            let dataPoint = CGFloat(step) / CGFloat(count)
            let x = dataPoint * bounds.width + bounds.minX
            let y = bounds.maxY - f(dataPoint)
            let point = CGPoint(x: x, y: y)
            path.addLine(to: point)
        }
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.close()
        return path
    }

    func startDisplayLink() {
        startTime = CACurrentMediaTime()
        displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    func stopDisplayLink() {
        displayLink?.invalidate()
    }

    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        shapeLayer.path = wave(at: elapsed)?.cgPath
    }
}
