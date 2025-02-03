//
//  Pea_WidgetBundle.swift
//  Pea Widget
//
//  Created by Xavier Chia PY on 3/2/25.
//

import WidgetKit
import SwiftUI

@main
struct Pea_WidgetBundle: WidgetBundle {
    var body: some Widget {
        Pea_Widget()
        Pea_WidgetControl()
        Pea_WidgetLiveActivity()
    }
}
