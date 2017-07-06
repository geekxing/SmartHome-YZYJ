//
//  XBDisplayRealStateView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/24.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBDisplayRealStateView: UIView {
    
    static let gapTime:Int = 10
    
    let cellId = "cell"
    var timer:DispatchSourceTimer?
    var xScale:CGFloat = 0
    
    var datas = [UIImage]()
    var dataWidth = [CGFloat]()
    var lastEvent = 0
    var offset:CGFloat = 0.0
    var now = Date()
    var quarterHour = Date().add(components: [.minute:XBDisplayRealStateView.gapTime])
    var motivateCounter = 0
    var firstComin = true
    
    var event:Int = 0 {
    
        didSet {
            
            if event == 3 {  //motivate
                motivateCounter += 1
                if motivateCounter == 3 || motivateCounter == 4 {
                    event = 2  // modify data to onBed
                }
            } else {
                motivateCounter = 0
            }
            
            if let eventType = XBEventType(rawValue: event) {
                if dataWidth.count == 0 || (lastEvent != event)  {
                    dataWidth.append(xScale)
                    datas.append(XBRealData.image(eventType))
                } else if lastEvent == event {
                    dataWidth[dataWidth.count-1] = dataWidth[dataWidth.count-1]+xScale
                }
                
                lastEvent = event
            } else if (lastEvent != 0) {
                //对于非第一次的无效的信号则画上一次的信号
                dataWidth[dataWidth.count-1] = dataWidth[dataWidth.count-1]+xScale
            }
            collection.reloadData()
            
            print("\(event)")
        }
    }
    
    var timeLineLayer:CALayer!
    var collection:UICollectionView!
    var begin:UILabel!
    var end:UILabel!
    
    deinit {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
    
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.white
        collection.showsHorizontalScrollIndicator = false
        collection.isUserInteractionEnabled = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier:cellId )
        addSubview(collection)
        
        
        begin = UILabel()
        begin.font = UIFontSize(14)
        begin.text = "--:--"
        begin.sizeToFit()
        addSubview(begin)
        
        end = UILabel()
        end.font = UIFontSize(14)
        end.text = "--:--"
        end.sizeToFit()
        addSubview(end)
        
        setupTimer()

    }
    
    func drawTimeLine() {

        let r = CAReplicatorLayer()
        r.bounds = CGRect(x: 0.0, y: 0.0, width: self.width, height: 12.0)
        
        self.layer.addSublayer(r)
        
        let nrDots: Int = 26
        let gap = (r.bounds.width) / CGFloat(nrDots)
        
        for i in 1 ... 5 {
            let dotWH:CGFloat = i % 5 == 1 ? 6 : 2
            let dot = CALayer()
            dot.bounds = CGRect(x: 0.0, y: 0.0, width: dotWH, height: dotWH)
            dot.position = CGPoint(x: 3 + CGFloat(i-1)*gap, y: r.frame.height / 2)
            dot.backgroundColor = UIColor.darkGray.cgColor
            dot.cornerRadius = dot.bounds.height/2
            
            r.addSublayer(dot)
        }
        r.instanceCount = 6
        r.instanceTransform = CATransform3DMakeTranslation(CGFloat(5 * gap), 0.0, 0.0)
        r.masksToBounds = true
        
        timeLineLayer = r
    }
    
    private func setupTimer()  {
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer?.setEventHandler( handler: {
            if !self.firstComin {
                self.viewController()?.navigationController?.popViewController(animated: true)
            }
            self.refreshTimeRange()
            self.firstComin = false
        })
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(XBDisplayRealStateView.gapTime*60))
        timer?.resume()
    }
    
    private func refreshTimeRange() {
        
        now = Date()
        quarterHour = Date().add(components: [.minute:XBDisplayRealStateView.gapTime])
        datas.removeAll()
        dataWidth.removeAll()
        
        begin.text = String(format: "%.2zd:%.2zd", now.hour, now.minute)
        end.text = String(format: "%.2zd:%.2zd", quarterHour.hour, quarterHour.minute)
        begin.sizeToFit()
        end.sizeToFit()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        xScale = width / CGFloat(XBDisplayRealStateView.gapTime*6) // gapTime * 6
        collection.frame = CGRect(x: 0, y: 0, width: width, height: height * 2/3)
        if timeLineLayer == nil {
            drawTimeLine()
        }
        timeLineLayer.position = CGPoint(x: self.width * 0.5, y: collection.bottom + 12 + timeLineLayer.bounds.height/2)
        let anchorPoint = timeLineLayer.position
        begin.left = 0
        begin.top = anchorPoint.y + 16
        end.right = collection.width
        end.top = anchorPoint.y + 16
    }

}

extension XBDisplayRealStateView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.width = collectionView.width
        imageView.height = cell.height
        imageView.image = datas[indexPath.row]
        cell.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        
        return cell
    }
    
}

extension XBDisplayRealStateView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: dataWidth[indexPath.row], height: collection.height)
    }

}
