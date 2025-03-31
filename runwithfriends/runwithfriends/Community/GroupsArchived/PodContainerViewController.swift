
import UIKit

class PodContainerViewController: UIViewController {
    private lazy var introViewController: UserIntroViewController = {
        let vc = UserIntroViewController(weekSteps: 0)
//        vc.delegate = self
        return vc
    }()
    
    private lazy var groupsTableViewController: UINavigationController = {
        let vc = GroupsTableViewController()
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialState()
    }
    
    private func setupInitialState() {
        // Check if user is first-time visitor
//        if UserDefaults.standard.bool(forKey: "seenGroupIntro") {
//            showGroupsTable()
//             intro seen
//        } else {
            showIntro()
//        }
    }
    
    private func showIntro() {
        // Add the intro VC
        if let sheet = self.sheetPresentationController {
            let fraction = UISheetPresentationController.Detent.custom { context in 460 }
            sheet.detents = [fraction]
            sheet.prefersGrabberVisible = true
        }
        addChild(introViewController)
        introViewController.view.frame = view.bounds
        view.addSubview(introViewController.view)
        introViewController.didMove(toParent: self)
    }
    
    private func showGroupsTable() {
        if let sheet = self.sheetPresentationController {
            sheet.animateChanges {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = false
            }
        }
        self.isModalInPresentation = true
        addChild(groupsTableViewController)
        groupsTableViewController.view.frame = view.bounds
        view.addSubview(groupsTableViewController.view)
        self.groupsTableViewController.didMove(toParent: self)
    }
    
    func joinGroupPressed() {
        print("join group pressed")
 
        self.introViewController.view.removeFromSuperview()
        self.introViewController.removeFromParent()
        
        showGroupsTable()
    }
}
