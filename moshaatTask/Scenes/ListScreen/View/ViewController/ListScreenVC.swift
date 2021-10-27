//
//  ViewController.swift
//  moshaatTask
//
//  Created by Ahmad Abdulrady
import Kingfisher
import Toast

import UIKit

class ListScreenVC: UIViewController {
    
    @IBOutlet private weak var headerBGView: UIImageView!
    @IBOutlet private weak var headerLabelView: HeadLabel!
    @IBOutlet private weak var consultantsCV: UICollectionView!
    @IBOutlet private weak var headLabalTopSpaceConstrain: NSLayoutConstraint!
    @IBOutlet private weak var headBackgroundButtomSpaceConstrain: NSLayoutConstraint!
    
    var listScreenActions: ListScreenActions?
    var noInternet = NoInternet()
    
    let toastActivityStyle: ToastStyle = {
            var style = ToastStyle()
            style.activityBackgroundColor = .clear
            style.maxHeightPercentage = 0.5
            style.activityIndicatorColor = Colors.activityColor.color
            ToastManager.shared.style = style
            return style
        }()
    
    var refreshControl: UIRefreshControl = {
            var refresh = UIRefreshControl()
            refresh.tintColor = Colors.activityColor.color
            return refresh
        }()
    
    var scrollableView: UIScrollView {
        return self.consultantsCV
    }
     
    var presenter: ListScreenPresenterProtocol!
    var consultantCVAdapter: ConsultantCVAdapter!
    weak var listCoordinatorDelegate: ListCoordinatorProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configConsultantCV()
        noInternet.retryAction = presenter.viewLoaded
        presenter.viewLoaded()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configHeaderUI()
        configNavBar()
    }
            
    func configHeaderUI() {
        headerLabelView.setHeaderTitle(with: Strings.ListScreen.title)
    }
    
    func configNavBar() {
        self.hideNavigationBar()
        
        let searchButton = UIBarButtonItem.barButtonWithImage(img: Assets.icSearch.image)
        navigationItem.leftBarButtonItem = searchButton
        let backButton = UIBarButtonItem.barButtonWithImage(img: Assets.icBackArrow.image)
        navigationItem.rightBarButtonItem = backButton
    }
    
    func configConsultantCV() {
        
        let cellNib = UINib(nibName: String(describing: ConsultantCell.self),
                            bundle: Bundle.main)
        
        let footerNib = UINib(nibName: String(describing: NoMoreConsultantsCVFooterCell.self),
                              bundle: Bundle.main)

        consultantsCV.register(cellNib,
                               forCellWithReuseIdentifier: ConsultantCell.reuseID)
        
//        consultantsCV.register(footerNib,
//                               forCellWithReuseIdentifier: NoMoreConsultantsCVFooterCell.reuseID)
        consultantsCV.register(footerNib,
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                               withReuseIdentifier: NoMoreConsultantsCVFooterCell.reuseID)
        consultantsCV.refreshControl = refreshControl

        consultantsCV.backgroundColor = .clear
        
        self.consultantCVAdapter = ConsultantCVAdapter(for: self)
        
        consultantCVAdapter.configDataSource()
        consultantsCV.dataSource = consultantCVAdapter.consultantCVDataSource
        
        consultantsCV.delegate = consultantCVAdapter
    }
    
    // MARK: Refreshing
    @objc
    func refresh() {
        consultantCVAdapter.consultants = []
        noInternet.retryAction = presenter.refreshConsultantData
        presenter.refreshConsultantData()
        consultantCVAdapter.refreshConsultantsCV()
    }
    
    // MARK: Animation when scrolling
    func startScrolling(trans: CGFloat) {
        if trans < 0 {
            // moving up
            self.headLabalTopSpaceConstrain.constant = self.view.safeAreaInsets.top
            self.headBackgroundButtomSpaceConstrain.constant = 8
            
        } else {
            // moving down
            self.headLabalTopSpaceConstrain.constant = 94
            self.headBackgroundButtomSpaceConstrain.constant = 120

//            self.headerBGView.bottomAnchor.constraint(equalTo: headerLabelView.bottomAnchor,
//                                                      constant: 120).isActive = true
        }
        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 2,
                       initialSpringVelocity: 5,
                       options: .curveLinear) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: NoInternet State
    func showNoInternet() {
        self.view.addSubview(noInternet)
        noInternet.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                                    noInternet.topAnchor.constraint(equalTo: headerBGView.bottomAnchor),
                                    noInternet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                    noInternet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                    noInternet.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                                    ])
        noInternet.tryAgainButton.addTarget(self,
                                            action: #selector(listScreenAction),
                                            for: .touchUpInside)

    }
    
    func hideNoInternet() {
        noInternet.removeFromSuperview()
    }

    func noMoreConsultants() {
        consultantCVAdapter.noMoreConsultantsFooter()
        self.hideActivityIndicator()
    }
    
}
