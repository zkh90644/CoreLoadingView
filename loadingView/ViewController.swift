//
//  ViewController.swift
//  loadingView
//
//  Created by zkhCreator on 9/29/16.
//  Copyright © 2016 zkhCreator. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var lv:loadingView?
    
    @IBOutlet weak var labelView: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let color = UIColor(red: 102/255.0, green: 204/255.0, blue: 255/255.0, alpha: 1)
        let loading:loadingView = loadingView(frame: CGRect(x:100,y:100,width:200,height:40), directionTo: .right, coverColor:color)
        
        self.lv = loading
        view.addSubview(self.lv!)
        lv?.maskViewArray.append(labelView)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func beginAnimate(_ sender: AnyObject) {
        if lv?.perscent == 0.6 {
            self.lv?.animateWith(perscent: 1)
        }else{
            self.lv?.animateWith(perscent: 0.6)
        }
        
    }

}

