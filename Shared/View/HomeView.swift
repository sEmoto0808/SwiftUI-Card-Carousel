//
//  Home.swift
//  swiftui-card-carousel-sample (iOS)
//
//  Created by Sho Emoto on 2021/11/11.
//

import SwiftUI

struct HomeView: View {
    
    @State var cards: [Card] = [
        Card(cardColor: Color("blue"), date: "Monday 8th November", title: "Neurobics for your \nmind."),
        Card(cardColor: Color("green"), date: "Tuesday 9th November", title: "Brush up on hygine."),
        Card(cardColor: Color("pink"), date: "Wednesday 10th November", title: "Don't skip breakfast."),
        Card(cardColor: Color("purple"), date: "Thursday 11th November", title: "Brush up on hygine."),
        Card(cardColor: Color("yellow"), date: "Friday 12th November", title: "Neurobics for your \nmind.")
    ]
    
    var body: some View {
        
        VStack {
            
            // Title
            HStack(alignment: .bottom) {
                
                VStack(alignment: .leading) {
                    
                    Text("9TH OF NOV")
                        .font(.largeTitle.bold())
                    
                    Label {
                        Text("Tokyo, Japan")
                    } icon: {
                        Image(systemName: "location.circle")
                    }
                }
                
                Spacer()
                
                Text("Updated 1:30 PM")
                    .font(.caption2)
                    .fontWeight(.light)
            }
        }
        .padding()
        // Moving view to Top without using Spacers
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

