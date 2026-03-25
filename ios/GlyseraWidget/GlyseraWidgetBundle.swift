//
//  GlyseraWidgetBundle.swift
//  GlyseraWidget
//
//  Created by Mattéo Meister on 23.03.2026.
//

import WidgetKit
import SwiftUI

@main
struct GlyseraWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlyseraWidget()
        GlyseraWidgetControl()
        GlyseraWidgetLiveActivity()
    }
}
