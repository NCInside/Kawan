//
//  HomeView.swift
//  Kawan
//
//  Created by Nicholas Christian Irawan on 28/05/24.
//

import SwiftUI

struct HomeView: View {
    @State private var isExpand = false
    
    var body: some View {
        ZStack {
            Color(red: 160/255, green: 193/255, blue: 114/255)
                .ignoresSafeArea()
            Circle()
                .stroke(.white, lineWidth: 6)
                .fill(Color(red: 177/255, green: 207/255, blue: 134/255))
                .overlay(
                    GeometryReader { geometry in
                        ForEach(0..<3) { _ in
                            Text("Random")
                                .position(CGPoint(x: CGFloat.random(in: 0...geometry.size.width), y: CGFloat.random(in: 0...geometry.size.height)))
                        }
                    }
                )
                .frame(width: 350)
                .offset(y: -50)
            if isExpand {
                Color(red: 0/255, green: 0/255, blue: 0/255)
                    .ignoresSafeArea()
                    .opacity(0.5)
            }
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Label("Inventory", systemImage: "archivebox")
                    .font(.system(size: 64))
            }
            .labelStyle(.iconOnly)
            .offset(y: isExpand ? 200 : 300)
            .opacity(isExpand ? 100 : 0)
            .animation(.easeInOut)
            Button(action: {self.isExpand.toggle()}) {
                Label("Center", systemImage: isExpand ? "x.circle.fill" : "plus.circle.fill")
                .font(.system(size: 64))
            }
            .labelStyle(.iconOnly)
            .foregroundColor(.white)
            .offset(y: 300)
        }
    }
}


#Preview {
    HomeView()
}
