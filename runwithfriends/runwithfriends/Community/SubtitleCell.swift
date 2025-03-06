
import UIKit

class SubtitleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SubtitleTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    func configureUI() {
        backgroundColor = .baseBackground
        textLabel?.textColor = .baseText
        detailTextLabel?.textColor = .baseText
        
        let labelSize = textLabel?.font.pointSize ?? 17
        let detailSize = detailTextLabel?.font.pointSize ?? 12
        
        textLabel?.font = UIFont.Kefir(size: labelSize)
        detailTextLabel?.font = UIFont.Kefir(size: detailSize)
        accessoryType = .disclosureIndicator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
