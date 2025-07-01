//
//  ViewController.swift
//  runwithfriends
//
//  Created by xavier chia on 20/10/23.
//

import UIKit

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
        OnboardingQuestion(question: "What is your favorite color?", answers: ["Red", "Blue", "Green", "Yellow"]),
        OnboardingQuestion(question: "What is your favorite sport?", answers: ["Soccer", "Basketball", "Tennis", "Running"]),
        OnboardingQuestion(question: "What is your favorite season?", answers: ["Spring", "Summer", "Autumn", "Winter"]),
        OnboardingQuestion(question: "What is your favorite food?", answers: ["Pizza", "Sushi", "Burger", "Salad"]),
        OnboardingQuestion(question: "What is your favorite animal?", answers: ["Dog", "Cat", "Bird", "Fish"])
    ]
    private var currentQuestionIndex = 0
    
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
        skipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Title Label
        titleLabel.text = "General Knowledge Quiz"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .baseText
        titleLabel.textAlignment = .center
        
        // Progress View
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressView.progressTintColor = UIColor.systemGreen
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        // Card View
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Question Number Label
        questionNumberLabel.textColor = .gray
        questionNumberLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Question Label
        questionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        questionLabel.textColor = .black
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
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.tag = i
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.layer.cornerRadius = 12
            button.backgroundColor = UIColor.systemGray5
            button.setTitleColor(.gray, for: .normal)
            button.layer.borderWidth = 0
            button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
            button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
            answerButtons.append(button)
            cardView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
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
        nextButton.setTitle("Next Question", for: .normal)
        nextButton.backgroundColor = UIColor.systemRed
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 16
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
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
        questionNumberLabel.text = "Question \(currentQuestionIndex + 1)/\(questions.count)"
        questionLabel.text = current.question
        for (i, button) in answerButtons.enumerated() {
            button.setTitle(current.answers[i], for: .normal)
            button.backgroundColor = UIColor.systemGray5
            button.setTitleColor(.gray, for: .normal)
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.clear.cgColor
            button.isEnabled = true
        }
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
        progressView.progress = Float(currentQuestionIndex + 1) / Float(questions.count)
        nextButton.setTitle(currentQuestionIndex == questions.count - 1 ? "Finish" : "Next Question", for: .normal)
    }
    
    // MARK: - Actions
    @objc private func answerButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        for (i, button) in answerButtons.enumerated() {
            if i == index {
                button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                button.setTitleColor(.systemGreen, for: .normal)
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.systemGreen.cgColor
            } else {
                button.backgroundColor = UIColor.systemGray5
                button.setTitleColor(.gray, for: .normal)
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.clear.cgColor
            }
        }
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
    }
    
    @objc private func nextQuestionTapped() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            loadCurrentQuestion()
        } else {
            // Finish onboarding: dismiss or transition
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func skipTapped() {
        // Skip onboarding: dismiss or transition
        dismiss(animated: true, completion: nil)
    }
}
