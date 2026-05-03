//
//  NurWidgetsBundle.swift
//  NurWidgets
//
//  Created by Ислам Абдыкарим уулу on 30/4/26.
//

import WidgetKit
import SwiftUI

@main
struct NurWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NurPrayerWidget()
        NurAyahWidget()
        NurDuaWidget()
        NurStreakWidget()
    }
}
