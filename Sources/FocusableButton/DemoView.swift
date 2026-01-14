//
//  File.swift
//  FocusableButton
//
//  Created by Eugene Kugut on 14.01.2026.
//

import SwiftUI
import FocusableButton

struct DemoView: View {

    var body: some View {
        HStack(content: {
            Spacer(minLength: 0)
            FocusableButton(
                title: "Cancel",
                action: {
                    print("Cancel")
                }
            )
            FocusableButton(
                title: "OK",
                action: {
                    print("OK")
                }
            )
        })
        .padding()
    }
}

#Preview {
    DemoView()
}
