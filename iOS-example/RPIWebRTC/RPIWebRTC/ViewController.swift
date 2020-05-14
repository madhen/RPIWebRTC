//
//  ViewController.swift
//  RPIWebRTC
//
//  Created by Madhen K Venkataraman on 2020/4/4.
//  Copyright © 2020 Madhen K Venkataraman. All rights reserved.
//

import UIKit
import WebKit
import BRHJoyStickView

class ViewController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var webView: WKWebView!
    var joyView = JoyStickView()
    let viewURL = "http://10.0.0.77:8888/fordev.html"
    let params = ["username":"john", "password":"123456"] as Dictionary<String, String>
    var request = URLRequest(url: URL(string: "http://10.0.0.77:8050/drive")!)
    
    

    override func loadView() {
        let monitor: JoyStickViewPolarMonitor = { report in
            if report.displacement > 0.0 {
// invoke drive
                print(String(format: "Angle : %.3f", report.angle))
                print(String(format: "Displacement : %.3f", report.displacement))
            }
        }
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.clear
        webView.isUserInteractionEnabled = true
        webView.scrollView.backgroundColor = UIColor.clear
        view = webView
        joyView.baseAlpha = 0.5
        joyView.monitor = .polar(monitor: monitor)
        
        joyView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        view.addSubview(joyView)
        joyView.baseImage = UIImage(named: "CustomBase")
        joyView.handleImage = UIImage(named: "CustomHandle")
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapGesture.delegate = self
        webView.addGestureRecognizer(tapGesture)
        joyView.isHidden = true
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joyView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        joyView.isHidden = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        joyView.isHidden = false
        for touch in touches
        {
            let location = touch.location(in: webView)
        }
    }
    
//    func driveAPI(angle, displacement) -> nil {
//        <#function body#>
//    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Receive App active/inactive notification
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: willResignActive)
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: didBecomeActive)

        // load URL
        let url = URL(string: viewURL)
        let request = URLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData)
        webView.load(request)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//           tap.numberOfTapsRequired = 1
        webView.addGestureRecognizer(tap)
    }
    
    

    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        
//        let alertController = UIAlertController(title: nil, message: "You tapped at \(gestureRecognizer.location(in: self.webView))", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in }))
//        self.present(alertController, animated: true, completion: nil)
//        let size = CGSize(width: 100, height: 100)
        let point = gestureRecognizer.location(in: self.webView)
        
        joyView.frame.size.height = 100
        joyView.frame.size.width = 100
        joyView.center = point
        joyView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        handleWebView(turn: false)
    }
    
    func willResignActive(notification: Notification) {
        print("willResignActive")
        handleWebView(turn: false)
    }
    
    func didBecomeActive(notification: Notification) {
        print("didBecomeActive")
        handleWebView(turn: true)
    }
    
    func handleWebView(turn on: Bool) {
        var script: String;
        if (on) {
            script = "viewResume()"
        }
        else {
            script = "viewPause()"
        }
        webView.evaluateJavaScript(script) { (result, error) in
            if let e = error {
                print(e)
            }
        }
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        joyView.isHidden = false
//    }
}

