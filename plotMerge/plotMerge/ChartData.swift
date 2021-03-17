

import Foundation

class ChartData
{
    var date: Date
    var rates: [String: NSNumber]
    
    init(date: Date, rates: [String: NSNumber])
    {
        self.date = date
        self.rates = rates
    }
    
    func minRate() -> NSNumber
    {
        return rates.values.sorted(by: { (n1, n2) -> Bool in
                return n1.compare(n2) == .orderedAscending
            }).first!
    }
    
    func maxRate() -> NSNumber
    {
        return rates.values.sorted(by: { (n1, n2) -> Bool in
                return n1.compare(n2) == .orderedAscending
            }).last!
    }

    func formatDate(format:String?) -> String
    {
        let dateFormatter = DateFormatter()
        
        if format != nil
        {
            dateFormatter.dateFormat = format
        }
        else
        {
            dateFormatter.dateStyle = .short
        }
        
        return dateFormatter.string(from: date)
    }
}
