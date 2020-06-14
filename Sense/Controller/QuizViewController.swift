//
//  QuizViewController.swift
//  Sense
//
//  Created by Bob Yuan on 2020/1/2.
//  Copyright © 2020 Bob Yuan. All rights reserved.
//

import UIKit
import Hero
import ChameleonFramework
import Lottie



class QuizViewController: UIViewController {
    
    @IBOutlet weak var congratsView: UIView!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var levelTextLabel: UILabel!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var stackView: UIView!
    
    @IBOutlet weak var finalView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    let pulsatingView = AnimationView()
    
    @IBOutlet var buttons: [UIButton]!
    
    let defaults = UserDefaults.standard
    
    var level: Int = 9{
        didSet{
            defaults.setValue(level, forKey: "level")
        }
    }//= gVars.level
    var cellLevel: Int = 9{
        didSet{
            defaults.setValue(cellLevel, forKey: "cellLevel")
        }
    }//= gVars.cellLevel
    var questionsCorrect: Int = 0{
        didSet{
            defaults.setValue(questionsCorrect, forKey: "questionsCorrect")
        }
    }
    
    var startTime: Int = 0 {
        didSet{
            defaults.setValue(startTime, forKey: "startTime")
        }
    }
    var endTime: Int = 0
    var currentView: CellView?
    var latestYCor: CGFloat = 0
    var spacing: CGFloat = 20
    var timesOffsetChanged: CGFloat = 0
    
    var snap : UISnapBehavior!
    var animator : UIDynamicAnimator!
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 400)
    lazy var normalViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    
    var pulsatingLayer: CAShapeLayer!
    

    
    lazy var scrollview: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .white
        view.frame = self.view.bounds
        //Just for test
        //view.frame.size.height = 300
        
        view.contentSize = normalViewSize
        //view.contentOffset = CGPoint(x:0, y:100)
        return view
    }()
    
    
    
    @objc func revealAnswer(sender: UIButton) {
        
        
        print("yo mama")
        
        
        
    }
    
    func createNewView() {
        
        if (Int(self.view.frame.height - latestYCor)) < 90 && timesOffsetChanged != 1 {
            let scrollPoint = CGPoint(x: 0.0, y: 300.0)
            scrollview.contentSize = contentViewSize
            scrollview.setContentOffset(scrollPoint, animated: false)
            timesOffsetChanged += 1
        }
        //Just for test
        let tempCellView = CellView(frame: CGRect(x:0, y:0, width:self.view.frame.width - 50, height:self.view.frame.height-80))
        
        //let tempCellView = CellView(frame: CGRect(x:0, y:0, width:300, height:10))
        
        //let tempCellView = CellView(frame: self.view.bounds)
        
        
        tempCellView.tag = Int(String(level)+String(cellLevel))!
        
        configureStackView()
        
        cellViewInitialization(CellView: tempCellView, cl: String(cellLevel), ll: String(level))
        
        // !!!
        view.addSubview(tempCellView)
        
        currentView = tempCellView

        // update timely
        self.view.layoutIfNeeded()
        view.bringSubviewToFront(stackView)
        UIView.animate(withDuration: 0.5, animations: {
            // Height
            self.stackView.alpha = 1
        })
        
        
    }
    

    
    func currentTime() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return (hour*60)+minutes
    }
    
    func finalScoreViewConfig() {
        if defaults.integer(forKey: "highScore") <= questionsCorrect {
            defaults.setValue(questionsCorrect, forKey: "highScore")
        }
        endTime = currentTime() - startTime
        print(endTime)
        let displayLink = CADisplayLink(target: self, selector: #selector(updater))
        displayLink.add(to: .main, forMode: .default)
        finalView.isHidden = false
        finalView.layer.zPosition = CGFloat(10)
        stackView.isHidden = true
        correctLabel.text = "0"
        highScoreLabel.text = "0"
        timeLabel.text = "0"
        print(questionsCorrect)
        level = 0
        cellLevel = 0
        
        
    }
    
    @objc func updater() {

        if Int(correctLabel.text!)! < Int(questionsCorrect) {
            correctLabel.text = String(Int(correctLabel!.text!)! + 1)
        }
        else if Int(correctLabel.text!)! == Int(questionsCorrect){
            questionsCorrect = 0
        }
        
        if Int(highScoreLabel.text!)! < Int(defaults.integer(forKey: "highScore")) {
            highScoreLabel.text = String(Int(highScoreLabel!.text!)! + 1)
        }
        
        if Int(timeLabel.text!)! < endTime {
            timeLabel.text = String(Int(timeLabel!.text!)! + 1)
        }
        else if Int(timeLabel.text!)! == endTime {
            endTime = 0
            startTime = 0
        }
        
    }
    
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        proceedButton.isHidden = true
        for view in scrollview.subviews {
            view.removeFromSuperview()
        }
        if level == 9 {
            print("floor gang auh")
            finalScoreViewConfig()
        }
        else {
            level += 1
            cellLevel = level
            timesOffsetChanged = 0
            latestYCor = 0
            createNewView()
        }
        
    }
    @IBAction func nextLevelButtonPressed(_ sender: UIButton) {
        congratsView.isHidden = true
        blurEffect.isHidden = true
        for view in scrollview.subviews {
            view.removeFromSuperview()
        }
        if level == 9 {
            print("floor gang auh")
            finalScoreViewConfig()
        }
        else {
            level += 1
            cellLevel = level
            timesOffsetChanged = 0
            latestYCor = 0
            createNewView()
            tabBarController?.tabBar.isHidden = true
        }
        
    }
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        self.view.bringSubviewToFront(self.proceedButton)
        UIView.animate(withDuration: 2, animations: {
            self.congratsView.isHidden = true
            self.proceedButton.isHidden = false
            self.blurEffect.isHidden = true
            
            
        })
        tabBarController?.tabBar.isHidden = true
        
    }
    
    func correctAnswer() {
        print(cellLevel)
        print(level)
        questionsCorrect += 1
        let str_result = String(Int(currentView!.firstLabel!.text!)! * Int(currentView!.secondLabel!.text!)!);
        
        currentView!.ansButton.setTitle(str_result, for: .normal);
        currentView!.ansButton.isEnabled = false
        currentView!.ansButton.titleLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        pulsatingLayerConfig(parentView: currentView!.ansButton)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            // wait for user to dismiss: tap any open area
            print("hi")
            // Animating....
            UIView.animate(withDuration: 0.5, animations: {
                // Height
                self.currentView!.frame.size.height = 70
                // Center
                self.currentView!.center = CGPoint(x: CGFloat(self.view.frame.width/2), y: CGFloat(CGFloat(self.cellLevel-self.level+1)*(self.spacing + (self.currentView!.frame.height))))
                self.currentView!.firstLabelCenter.constant += 80
                self.currentView!.secondLabelCenter.constant += 80
                self.currentView!.newplyCenter.constant += 80
                self.currentView!.equalSign.frame.origin.y += 80
                self.currentView!.ansButton.frame.origin.y += 80
                
                // update layout right now if any changes
                self.view.layoutIfNeeded() // !!! important !!!
            }, completion: { finished in
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    //self.currentView!.center = CGPoint(x: CGFloat(self.view.frame.width/2), y: CGFloat(CGFloat(self.cellLevel)*(self.spacing + (self.currentView!.frame.height))))
                    UIView.performWithoutAnimation {
                        //self.currentView!.center.y = c_y //CGPoint(x: c_x, y: c_y )
                        
                    }
                    
                }, completion: { finished in
                    
                    self.latestYCor = CGFloat(CGFloat(self.cellLevel)*(self.spacing + (self.currentView!.frame.height)))
                    self.cellLevel += 1
                    print(self.latestYCor)
                    
                    
                    
                    // CellView doesnot belong to scrollview at the beginning
                    self.currentView!.removeFromSuperview()
                    self.scrollview.addSubview(self.currentView!)
                    
                    
                    if self.cellLevel > 9 {
                        print("cellLevel: \(self.cellLevel), level: \(self.level)")
                        self.enterNewLevel()
                        //source
                    }
                    else {
                        //temp commented
                        
                        self.createNewView()
                    }
                })
                
            })
        }
    }
    
    func configureButtons() {
        stackView.frame.origin.y += 150
        for (i, button) in buttons.enumerated() {
            if button.tag != 11 && button.tag != 10 {
                button.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                button.layer.cornerRadius = 15
                button.frame.size.width += 5
                button.frame.size.height += 5
                /*
                if button.tag == 9 {
                    button.center = CGPoint(x: buttons[2].frame.origin.x, y: button.frame.origin.y)
                }
                */
                //button.titleLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
            }
            else {
                button.frame.size.width = 30
                button.frame.size.height = 30
                print(button.frame.size)
            }
        }
    }
    
    @IBAction func changeLanguage(sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        
        let ans_length: Int = String(Int(currentView!.firstLabel!.text!)! * Int(currentView!.secondLabel!.text!)!).count;
        if currentView?.ansButton.currentTitle == "_" || currentView?.ansButton.currentTitle == "__" {
            currentView!.ansButton.setTitle("", for: .normal)
            print("removed!!")
        }
        
        switch button.tag {
            case 11:
                
                if currentView!.ansButton.titleLabel?.text == String(Int(currentView!.firstLabel!.text!)! * Int(currentView!.secondLabel!.text!)!) {
                    print("congratulations!")
                    stackView.alpha = 0
                    correctAnswer()
                }
            case 10:
                if currentView?.ansButton.currentTitle?.last == "_" {
                    currentView!.ansButton.setTitle("__", for: .normal)
                }
                else if currentView?.ansButton.currentTitle?.count == ans_length {
                    let tempTitle = currentView!.ansButton.currentTitle!.dropLast()
                    currentView!.ansButton.setTitle(String(tempTitle) + "_", for: .normal)
                }
                else {
                    let tempTitle = currentView!.ansButton.currentTitle!.dropLast()
                    currentView!.ansButton.setTitle(String(tempTitle), for: .normal)
                }
            
            default:
                
                if ans_length == 1 {
                    currentView!.ansButton.setTitle(String(button.tag), for: .normal)
                    print("equal")
                }
                else {
                    if currentView?.ansButton.currentTitle?.count != ans_length && currentView?.ansButton.currentTitle?.last != "_" && currentView?.ansButton.currentTitle == "" {
                        currentView!.ansButton.setTitle((currentView?.ansButton.currentTitle)! + String(button.tag) + "_", for: .normal)
                        print("plus equal")
                        print(currentView?.ansButton.currentTitle)
                    }
                    else {
                        
                        let tempTitle = currentView!.ansButton.currentTitle!.dropLast()
                        currentView!.ansButton.setTitle(tempTitle + String(button.tag), for: .normal)
                    }
                }
                
                print(button.tag)
            
        }
    }
    func enterNewLevel() {
        print("level complete")
        if level == 9 {
            nextButton.setTitle("Finish", for: .normal)
        }
        levelTextLabel.text = "You've completed level \(level)!"
        blurEffect.isHidden = false
        self.view.bringSubviewToFront(blurEffect)
        self.view.bringSubviewToFront(congratsView)
        congratsView.isHidden = false
        tabBarController?.tabBar.isHidden = false
        self.view.layoutIfNeeded()
        print(scrollview.subviews)
    }
    
    func configureCongrats() {
        congratsView.isHidden = true
        reviewButton.layer.cornerRadius = 15
        nextButton.layer.cornerRadius = 15
        congratsView.layer.cornerRadius = 5
        shadow(view: congratsView)
        
    }

    
    func shadow(view: UIView) {
        view.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.3
        view.isHidden = true
    }
    
    
    func pulsatingLayerConfig(parentView: UIView) {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        pulsatingLayer = CAShapeLayer()
        pulsatingLayer.path = circularPath.cgPath
        pulsatingLayer.strokeColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
        pulsatingLayer.fillColor = UIColor.yellow.cgColor
        pulsatingLayer.lineCap = CAShapeLayerLineCap.round
        pulsatingLayer.position = parentView.center
        parentView.layer.addSublayer(pulsatingLayer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        gVars.level = level
        gVars.cellLevel = cellLevel
        print("levels \(gVars.level) \(gVars.cellLevel)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFromDefaults()
        configureCongrats()
        finalView.isHidden = true
        view.addSubview(scrollview)
        createNewView()
        //shadow(view: backButton)
        proceedButton.isHidden = true
        proceedButton.layer.cornerRadius = 25
        shadow(view: proceedButton)
        blurEffect.isHidden = true
        self.view.bringSubviewToFront(blurEffect)
        
        tabBarController?.tabBar.isHidden = true
        configureButtons()
        startTime = currentTime()        
        //stackView.isHidden = true
        print("GL")
    }
    
    func fetchFromDefaults() {
        latestYCor = 0
        level = 8
        cellLevel = 8
        if let _ = defaults.integer(forKey: "highScore") as? Int {
            //
        } else {
            defaults.setValue(0, forKey: "highScore")
        }
        
        if let plevel = defaults.integer(forKey: "level") as? Int {
            level = plevel
        }
        if let pcellLevel = defaults.integer(forKey: "cellLevel") as? Int {
            cellLevel = pcellLevel
        }

    }
    
    func configureStackView() {
        print("DEBUG_BUTTONS: \(buttons)")
        stackView.layer.cornerRadius = 15
        
    }
    
    func cellViewInitialization(CellView: CellView,cl: String, ll: String) {
        print(timesOffsetChanged)
        
        //CellView.cellView.backgroundColor = .clear
        let y = (self.view.frame.size.height / 2)*(timesOffsetChanged+1) - (timesOffsetChanged*spacing)
        
        
        CellView.center = CGPoint(x: self.view.frame.size.width  / 2, y: y)
        
        CellView.firstLabelCenter.constant -= 80
        CellView.secondLabelCenter.constant -= 80
        CellView.newplyCenter.constant -= 80
        CellView.equalSign.frame.origin.y -= 80
        CellView.ansButton.frame.origin.y -= 80
        //print("ANSBUTTON CONSTRAINTS: \(CellView.ansButton.constraints)")
        /*
         if cellLevel != 1 {
         let aboveViewTag = Int(String(level)+String(Int(cellLevel)-1))
         let aboveView = self.view.viewWithTag(aboveViewTag!) as? CellView
         CellView.translatesAutoresizingMaskIntoConstraints = false
         CellView.topAnchor.constraint(equalTo: aboveView!.bottomAnchor, constant: 20).isActive = true
         }
         */
        CellView.ansButton.addTarget(self, action: #selector(GuidedLearningVC.revealAnswer(sender:)), for: .touchUpInside)
        
        CellView.layer.cornerRadius = 30
        CellView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.leftToRight, withFrame:CellView.frame, andColors:[.flatPowderBlue, .flatPowderBlueDark])
        
        
        CellView.layer.shadowColor = UIColor.flatPowderBlueDark.cgColor
        CellView.layer.shadowOffset = CGSize(width: 1, height: 1)
        CellView.layer.shadowOpacity = 0.7
        CellView.layer.shadowRadius = 4.0
        //firstNum.text = "1"
        //secondNum.text = "1"
        CellView.firstLabel.text = ll
        CellView.secondLabel.text = cl
        
        CellView.ansButton.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        CellView.ansButton.layer.cornerRadius = 15
        
        // update timely
        self.view.layoutIfNeeded()
        stackView.layer.zPosition = .greatestFiniteMagnitude
        stackView.isHidden = false
        //cellViewConstraints(CellView: CellView)
        let ans_length: Int = String(Int(CellView.firstLabel!.text!)! * Int(CellView.secondLabel!.text!)!).count;
        if ans_length == 1 {
            CellView.ansButton.setTitle("_", for: .normal)
        } else {
            CellView.ansButton.setTitle("__", for: .normal)
        }
    }
    
    
    func cellViewConstraints(CellView: CellView) {
        CellView.translatesAutoresizingMaskIntoConstraints = false
        
        //CellView.cellView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //CellView.cellView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //CellView.cellView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        CellView.frame.size.height = self.view.frame.height
        CellView.center = CGPoint(x: self.view.frame.size.width  / 2, y: (self.view.frame.size.height / 2)*(timesOffsetChanged+1) - (timesOffsetChanged*spacing))
        print(CGPoint(x: CGFloat(self.view.frame.width/2), y: CGFloat(self.view.frame.height/2)))
        //CellView.cellView.frame.size.height = self.view.frame.height / 2
        CellView.cellView.center = CGPoint(x: CellView.cellView.frame.size.width  / 2, y: (self.view.frame.size.height / 2)*(timesOffsetChanged+1) - (timesOffsetChanged*spacing))
        print(CellView.center)
        //CellView.cellView.center = CGPoint(x: CGFloat(self.view.frame.width/2), y: CGFloat(self.view.frame.height/2))
        print(CellView.cellView.center)
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
