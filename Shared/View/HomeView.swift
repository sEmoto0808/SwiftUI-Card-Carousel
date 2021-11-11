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
        Card(cardColor: Color("orange"), date: "Friday 12th November", title: "Neurobics for your \nmind.")
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
            
            // Geometry Reader to take up all Available Space and giving about the Rect Data
            GeometryReader { proxy in
                
                let size = proxy.size
                
                // your wish
                let trailingCardsToShown: CGFloat = 2
                let trailingSpaceOfEachCards: CGFloat = 20
                
                ZStack {
                    
                    ForEach(cards) { card in
                        
                        InfiniteStackedCardView(cards: $cards, card: card, trailingCardsToShown: trailingCardsToShown, trailingSpaceOfEachCards: trailingSpaceOfEachCards)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, trailingCardsToShown * trailingSpaceOfEachCards)
                .frame(height: size.height / 1.6)
                
                // Your Wish
                // Make Cards size as 1.6 of th the height
                
                // Since Geometry Reader push away all View to leading
                // Make it Center
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

struct InfiniteStackedCardView: View {
    
    @Binding var cards: [Card]
    var card: Card
    var trailingCardsToShown: CGFloat
    var trailingSpaceOfEachCards: CGFloat
    
    // Gesture Propertiee
    // Used to tell whether user is Dragging Cards
    @GestureState var isDragging: Bool = false
    // Used to store offset
    @State var offset: CGFloat = .zero
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            
            Text(card.date)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(card.title)
                .font(.title.bold())
                .padding(.top)
            
            Spacer()
            
            // Since I need icon at right
            // Simply swap the content inside label
            Label {
                Image(systemName: "arrow.right")
            } icon: {
                Text("Read More")
            }
            .font(.system(size: 15, weight: .semibold))
            // Moving to right without Spacer
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .padding(.vertical, 10)
        .foregroundColor(.white)
        // Giving Background Color
        .background(
        
            RoundedRectangle(cornerRadius: 25)
                .fill(card.cardColor)
        )
        .padding(.trailing, -getPadding())
        // Applying vertical padding
        // to look like shurinking
        .padding(.vertical, getPadding())
        // since we use ZStack all cards are reversed
        // Simply undoing with the help of ZIndex
        .zIndex(Double(cards.count - Int(getIndex())))
        .rotationEffect(.init(degrees: getRotation(angle: 10)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .offset(x: offset)
        .gesture(
            DragGesture()
                .updating($isDragging, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    
                    var translation = value.translation.width
                    // Applying Translation for only First card to avoid dragging bottom Cards
                    translation = cards.first?.id == card.id ? translation : 0
                    // Applying dragging only if its dragged
                    translation = isDragging ? translation : 0
                    
                    // Stopping right Swipe
                    translation = translation < 0 ? translation : 0
                    
                    offset = translation
                })
                .onEnded({ value in
                    
                    // Checking if card is swiped more than width
                    let width = UIScreen.main.bounds.width
                    let cardPassed = -offset > (width / 2)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        if cardPassed {
                            offset = -width
                            removeAndPutBack()
                        } else {
                            offset = .zero
                        }
                    }
                })
        )
    }
    
    // Removing Card from first and putting it back at least so it lools like infinite stacked carousel without using Memory
    func removeAndPutBack() {
        
        // Removing card after animation finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            // Updating card id
            // to avoid ForEach Warning
            let updatedCard = Card(cardColor: card.cardColor, date: card.date, title: card.title)
            
            cards.append(updatedCard)
            
            withAnimation {
                // Removing first card
                cards.removeFirst()
            }
        }
    }
    
    // Rotating Card whilr dragging
    func getRotation(angle: Double) -> Double {
        // Removing Paddings
        let width = UIScreen.main.bounds.width - 50
        let progress = offset / width
        
        return Double(progress) * angle
    }
    
    func getPadding() -> CGFloat {
        
        // retreiving padding for each card(At trailing)
        
        let maxPadding = trailingCardsToShown * trailingSpaceOfEachCards
        
        let cardPadding = getIndex() * trailingSpaceOfEachCards
        
        // returning only number of cards declared
        return (getIndex() <= trailingCardsToShown ? cardPadding : maxPadding)
    }
    
    // Retreiving Index to find which card need to show
    func getIndex() -> CGFloat {
        
        let index = cards.firstIndex { card in
            return self.card.id == card.id
        } ?? 0
        
        return CGFloat(index)
    }
}
