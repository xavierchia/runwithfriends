//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import UIKit
import SharedCode

struct OnboardingQuestion {
    let question: String
    let answers: [String]
}

class OnboardingViewController: UIViewController {
    // MARK: - UI Elements
    private let skipButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let cardView = UIView()
    private let questionNumberLabel = UILabel()
    private let questionLabel = UILabel()
    private var answerButtons: [UIButton] = []
    private let nextButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    // MARK: - Data
    private let questions: [OnboardingQuestion] = [
        OnboardingQuestion(question: "Looking for a walking app that won't judge your snack breaks?\n\nYou've found your people 💁", answers: ["Snacks are part of my training 🍪", "Is there a snack leaderboard? 🤤"]),
        OnboardingQuestion(question: "Each week we’ll drop a new marathon route from around the world.\n\nThis week you might be ‘walking’ through Tokyo 🍣\n\nNext week maybe Paris 🥐", answers: ["My couch has never been to Tokyo.", "Do I get frequent walker miles? ✈️"]),
        OnboardingQuestion(question: "The best part? 🤔\n\nYou can walk with your friends and pretend you’re all training for something important.", answers: ["We’re very serious walkers 😤", "What friends? 🤭"]),
        OnboardingQuestion(question: "P.S. we need permission to count your steps.\n\nYes, all 47 of them from today 😆", answers: ["I only walk to the fridge 🍦", "Fine, expose my laziness 🙄"]),
        OnboardingQuestion(question: "Ready to join thousands of people who are oddly proud of their daily shuffling? 🚶‍♂️", answers: ["Let’s shuffle together. 💪", "I prefer competitive sitting. 🧘"])
    ]
    private var currentQuestionIndex = 0
    
    let userData: UserData

    init(with userData: UserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseBackground
        setupUI()
        loadCurrentQuestion()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Skip Button
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.baseText, for: .normal)
        skipButton.titleLabel?.font = UIFont.KefirMedium(size: 16)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Title Label
        titleLabel.text = "Glorified Onboarding"
        titleLabel.font = UIFont.KefirMedium(size: 28)

        titleLabel.textColor = .baseText
        titleLabel.textAlignment = .center
        
        // Progress View
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressView.progressTintColor = UIColor.moss
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        // Card View
        cardView.backgroundColor = .card
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Question Number Label
        questionNumberLabel.textColor = .gray
        questionNumberLabel.font = UIFont.QuicksandMedium(size: 14)

        
        // Question Label
        questionLabel.font = UIFont.QuicksandMedium(size: 18)
        questionLabel.textColor = .baseText
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .left
        
        // StackView for Card Content
        let cardStack = UIStackView(arrangedSubviews: [questionNumberLabel, questionLabel])
        cardStack.axis = .vertical
        cardStack.spacing = 12
        cardStack.alignment = .fill
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        // Answer Buttons
        for i in 0..<2 {
            let button = UIButton(type: .custom)
            button.tag = i
            button.titleLabel?.font = UIFont.QuicksandMedium(size: 16)
            button.layer.cornerRadius = 12
            button.backgroundColor = UIColor.clear
            button.setTitleColor(.baseText, for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.baseText.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
            button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
            answerButtons.append(button)
            cardView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
                button.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
                button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            ])
            if i == 0 {
                button.topAnchor.constraint(equalTo: cardStack.bottomAnchor, constant: 20).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: answerButtons[i-1].bottomAnchor, constant: 12).isActive = true
            }
        }
        answerButtons.last?.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20).isActive = true
        
        // Main StackView
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(progressView)
        stackView.addArrangedSubview(cardView)
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Next Button
        nextButton.setTitle("Continue", for: .normal)
        nextButton.backgroundColor = UIColor.lightGray
        nextButton.setTitleColor(.baseBackground, for: .normal)
        nextButton.layer.cornerRadius = 16
        nextButton.titleLabel?.font = UIFont.QuicksandBold(size: 18)
        nextButton.isEnabled = false
        nextButton.addTarget(self, action: #selector(nextQuestionTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Load Question
    private func loadCurrentQuestion() {
        let current = questions[currentQuestionIndex]
        questionNumberLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        questionLabel.text = current.question
        for (i, button) in answerButtons.enumerated() {
            button.setTitle(current.answers[i], for: .normal)
            button.backgroundColor = UIColor.clear
            button.setTitleColor(.baseText, for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.baseText.cgColor
            button.isEnabled = true
        }
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.lightGray
        progressView.progress = Float(currentQuestionIndex + 1) / Float(questions.count)
        nextButton.setTitle(currentQuestionIndex == questions.count - 1 ? "Finish" : "Continue", for: .normal)
    }
    
    // MARK: - Actions
    @objc private func answerButtonTapped(_ sender: UIButton) {
        // request permissions
        if currentQuestionIndex == 3 {
            StepCounter.shared.requestMotionPermission { authorized in
                print("motion is authorized? \(authorized)")
            }
            Task { @MainActor in
                let _ = await StepCounter.shared.requestHealthKitPermission()
            }
        }
        
        let index = sender.tag
        for (i, button) in answerButtons.enumerated() {
            if i == index {
                button.backgroundColor = UIColor.clear
                button.setTitleColor(.accent, for: .normal)
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.accent.cgColor
            } else {
                button.backgroundColor = UIColor.clear
                button.setTitleColor(.baseText, for: .normal)
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.baseText.cgColor
            }
        }
        nextButton.isEnabled = true
        nextButton.backgroundColor = UIColor.moss
    }
    
    @objc private func nextQuestionTapped() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            loadCurrentQuestion()
        } else {
            // Finish onboarding: dismiss or transition
            goToTabVC()
        }
    }
    
    @objc private func skipTapped() {
        goToTabVC()
    }
    
    private func goToTabVC() {
        if let peaDefaults = PeaDefaults.shared {
            peaDefaults.setValue(true, forKey: UserDefaultsKey.isOnboardingComplete)
        }
        
        DispatchQueue.main.async {
            let window = self.view.window!
            window.rootViewController = TabViewController(with: self.userData)
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
