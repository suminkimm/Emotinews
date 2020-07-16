//
//  WebViewController.swift
//  Twittermenti
//
//  Created by Su Min Kim on 7/15/20.
//  Copyright © 2020 London App Brewery. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    
    var url: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        webview.scrollView.contentInset = UIEdgeInsets(top: <#T##CGFloat#>, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>)
        
        let request = URLRequest(url: URL(string: url!)!)
        
        webview.load(request)
    }

}
