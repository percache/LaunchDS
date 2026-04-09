//
//  LaunchAnimationViewController.swift
//  AntoineDS
//
//  Launch animation with typewriter text, orange progress ring, and smooth transitions.
//

import UIKit

class LaunchAnimationViewController: UIViewController {

    // MARK: - Theme
    private let accentOrange = UIColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "System Log Viewer + Kernel Exploit"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(white: 0.55, alpha: 1.0)
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ringContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Core Animation layers
    private var trackLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    private var glowLayer: CAShapeLayer!

    private let ringSize: CGFloat = 64
    private let ringLineWidth: CGFloat = 3.5

    // Typewriter state
    private let fullTitle = "LaunchdDS"
    private var typewriterIndex = 0
    private var typewriterTimer: Timer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        setupRingLayers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimationSequence()
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(ringContainer)
        view.addSubview(titleLabel)
        view.addSubview(taglineLabel)

        NSLayoutConstraint.activate([
            // Ring above center
            ringContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ringContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            ringContainer.widthAnchor.constraint(equalToConstant: ringSize),
            ringContainer.heightAnchor.constraint(equalToConstant: ringSize),

            // Title below ring
            titleLabel.topAnchor.constraint(equalTo: ringContainer.bottomAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Tagline below title
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
    }

    // MARK: - Ring Layers
    private func setupRingLayers() {
        let center = CGPoint(x: ringSize / 2, y: ringSize / 2)
        let radius = (ringSize - ringLineWidth) / 2
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        // Background track
        trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor(white: 0.15, alpha: 1.0).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = ringLineWidth
        trackLayer.lineCap = .round
        ringContainer.layer.addSublayer(trackLayer)

        // Glow layer (larger, blurred orange behind progress)
        glowLayer = CAShapeLayer()
        glowLayer.path = circularPath.cgPath
        glowLayer.strokeColor = accentOrange.withAlphaComponent(0.35).cgColor
        glowLayer.fillColor = UIColor.clear.cgColor
        glowLayer.lineWidth = ringLineWidth + 6
        glowLayer.lineCap = .round
        glowLayer.strokeEnd = 0
        ringContainer.layer.addSublayer(glowLayer)

        // Progress ring
        progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = accentOrange.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = ringLineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        ringContainer.layer.addSublayer(progressLayer)
    }

    // MARK: - Animation Sequence
    private func startAnimationSequence() {
        // 1. Fade in ring container
        ringContainer.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
            self.ringContainer.alpha = 1
        }

        // 2. Animate progress ring filling over ~2.0s
        let progressAnim = CABasicAnimation(keyPath: "strokeEnd")
        progressAnim.fromValue = 0
        progressAnim.toValue = 1
        progressAnim.duration = 2.0
        progressAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressAnim.fillMode = .forwards
        progressAnim.isRemovedOnCompletion = false
        progressLayer.add(progressAnim, forKey: "progressFill")

        let glowAnim = CABasicAnimation(keyPath: "strokeEnd")
        glowAnim.fromValue = 0
        glowAnim.toValue = 1
        glowAnim.duration = 2.0
        glowAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowAnim.fillMode = .forwards
        glowAnim.isRemovedOnCompletion = false
        glowLayer.add(glowAnim, forKey: "glowFill")

        // 3. Glow pulse on the ring (opacity pulsing)
        let pulseAnim = CABasicAnimation(keyPath: "opacity")
        pulseAnim.fromValue = 0.3
        pulseAnim.toValue = 0.7
        pulseAnim.duration = 0.8
        pulseAnim.autoreverses = true
        pulseAnim.repeatCount = .infinity
        pulseAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowLayer.add(pulseAnim, forKey: "glowPulse")

        // 4. Typewriter effect for title starting at 0.3s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.titleLabel.alpha = 1
            self?.startTypewriter()
        }

        // 5. Fade in tagline at 1.2s
        UIView.animate(withDuration: 0.6, delay: 1.2, options: .curveEaseOut) {
            self.taglineLabel.alpha = 1
        }

        // 6. Transition after 2.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.transitionToExploit()
        }
    }

    // MARK: - Typewriter
    private func startTypewriter() {
        typewriterIndex = 0
        titleLabel.text = ""
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            if self.typewriterIndex < self.fullTitle.count {
                let idx = self.fullTitle.index(self.fullTitle.startIndex, offsetBy: self.typewriterIndex)
                self.titleLabel.text = String(self.fullTitle[...idx])
                self.typewriterIndex += 1
            } else {
                timer.invalidate()
                self.typewriterTimer = nil
            }
        }
    }

    // MARK: - Transition
    private func transitionToExploit() {
        let exploitVC = ExploitViewController()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        // Fade out current content, then swap
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { _ in
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
                window.rootViewController = exploitVC
            }
        }
    }

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var prefersStatusBarHidden: Bool { true }
}
