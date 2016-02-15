//
//  YoutubePlayerViewController.swift
//  YoutubeSample
//
//  Created by AnilKumar Koya on 09/11/15.
//  Copyright © 2015 AnilKumar Koya. All rights reserved.
//

import UIKit

class YoutubePlayerViewController: UIViewController {

    @IBOutlet var playerView : YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        playerView.loadWithVideoId("pHsvYPMqsOc")//("https://www.youtube.com/watch?v=pHsvYPMqsOc", startSeconds: 0.0, suggestedQuality: YTPlaybackQuality.Auto)
        playerView.playVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
