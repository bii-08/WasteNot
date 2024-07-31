//
//  ReminderSetting.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/21.
//

import Foundation
import SwiftData

@Model final class Setting {
    var notificationIsOn: Bool
    var hour: Int
    var minute: Int
    var numsOfDayBefore: Int
    var currentTime: Date
    
    init(notificationIsOn: Bool, hour: Int, minute: Int, numsOfDayBefore: Int, currentTime: Date) {
        self.notificationIsOn = notificationIsOn
        self.hour = hour
        self.minute = minute
        self.numsOfDayBefore = numsOfDayBefore
        self.currentTime = currentTime
    }
}
