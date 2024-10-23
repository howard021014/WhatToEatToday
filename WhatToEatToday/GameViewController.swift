import UIKit

class GameViewController: UIViewController {
    
    var items: [String] = ["🍎", "🍌", "🍒", "🍇", "🍉", "🍓"]
    var scrollView: UIScrollView!
    var spinButton: UIButton!
    var overlayView: UIView!
    var wonItemLabel: UILabel!
    var okButton: UIButton!
    var spinAgainButton: UIButton!
    var isSpinning = false
    var itemLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // Slot Machine Frame
        let slotMachineFrame = UIView(frame: CGRect(x: view.center.x - 150, y: view.center.y - 200, width: 300, height: 400))
        slotMachineFrame.backgroundColor = UIColor.darkGray
        slotMachineFrame.layer.cornerRadius = 20
        slotMachineFrame.layer.borderWidth = 5
        slotMachineFrame.layer.borderColor = UIColor.black.cgColor
        view.addSubview(slotMachineFrame)
        
        // Scroll View
        scrollView = UIScrollView(frame: CGRect(x: 25, y: 50, width: 250, height: 150))
        scrollView.showsVerticalScrollIndicator = false
        slotMachineFrame.addSubview(scrollView)
        
        // Add items to the scroll view
        for i in 0..<items.count * 100 {
            let label = UILabel()
            label.text = items[i % items.count]
            label.font = UIFont.systemFont(ofSize: 50)
            label.textAlignment = .center
            label.frame = CGRect(x: 0, y: CGFloat(i) * 50, width: scrollView.frame.width, height: 50)
            scrollView.addSubview(label)
            itemLabels.append(label)
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: CGFloat(items.count * 100) * 50)
        
        // Spin Button
        spinButton = UIButton(type: .system)
        spinButton.setTitle("Spin", for: .normal)
        spinButton.backgroundColor = UIColor.red
        spinButton.setTitleColor(.white, for: .normal)
        spinButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        spinButton.layer.cornerRadius = 10
        spinButton.addTarget(self, action: #selector(spinSlot), for: .touchUpInside)
        spinButton.frame = CGRect(x: slotMachineFrame.frame.midX - 50, y: slotMachineFrame.frame.maxY - 80, width: 100, height: 50)
        view.addSubview(spinButton)
        
        // Overlay View
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        overlayView.isHidden = true
        view.addSubview(overlayView)
        
        // Won Item Label
        wonItemLabel = UILabel()
        wonItemLabel.textColor = .white
        wonItemLabel.textAlignment = .center
        wonItemLabel.frame = CGRect(x: 20, y: view.center.y - 50, width: view.bounds.width - 40, height: 100)
        overlayView.addSubview(wonItemLabel)
        
        // OK Button
        okButton = UIButton(type: .system)
        okButton.setTitle("OK", for: .normal)
        okButton.backgroundColor = UIColor.green
        okButton.setTitleColor(.white, for: .normal)
        okButton.layer.cornerRadius = 10
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        okButton.frame = CGRect(x: view.center.x - 100, y: view.center.y + 100, width: 80, height: 50)
        overlayView.addSubview(okButton)
        
        // Spin Again Button
        spinAgainButton = UIButton(type: .system)
        spinAgainButton.setTitle("Spin Again", for: .normal)
        spinAgainButton.backgroundColor = UIColor.blue
        spinAgainButton.setTitleColor(.white, for: .normal)
        spinAgainButton.layer.cornerRadius = 10
        spinAgainButton.addTarget(self, action: #selector(spinAgainButtonTapped), for: .touchUpInside)
        spinAgainButton.frame = CGRect(x: view.center.x + 20, y: view.center.y + 100, width: 120, height: 50)
        overlayView.addSubview(spinAgainButton)
    }
    
    @objc func spinSlot() {
        guard !isSpinning else { return }
        isSpinning = true
        
        let randomRow = Int.random(in: 0..<items.count * 100)
        let duration = 3.0
        
        // Animate the scroll view to simulate spinning
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(randomRow) * 50), animated: false)
        }, completion: { _ in
            self.isSpinning = false
            self.showOverlay(row: randomRow % self.items.count)
        })
    }
    
    func showOverlay(row: Int) {
        let wonItem = items[row]
        wonItemLabel.text = "Congratulations, you have won \(wonItem)!"
        overlayView.isHidden = false
    }
    
    @objc func okButtonTapped() {
        overlayView.isHidden = true
    }
    
    @objc func spinAgainButtonTapped() {
        overlayView.isHidden = true
        spinSlot()
    }
}
