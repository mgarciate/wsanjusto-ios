//
//  FlagView.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 30/6/22.
//

import SwiftUI

struct FlagView : View {
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Color("Green")
                Color("Yellow")
            }
            Color("Red")
            VStack(spacing: 0) {
                Color("Yellow")
                Color("Green")
            }
        }
    }
}

struct FlagView_Previews: PreviewProvider {
    static var previews: some View {
        FlagView()
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
