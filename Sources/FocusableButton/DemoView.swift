import SwiftUI

struct DemoView: View {
    
    var body: some View {
        HStack(content: {
            FocusableButton(
                selectedBackground: .clear,
                action: {
                    
                },
                label: {
                    Image(systemName: "cube.fill")
                        .font(.largeTitle)
                        .foregroundStyle(LinearGradient(colors: [Color.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                }
            )

            FocusableButton(
                action: {
                    
                },
                label: {
                    Text("OK")
                }
            )
        })
    }
}

#Preview {
    DemoView()
        .frame(width: 200, height: 200)
}
