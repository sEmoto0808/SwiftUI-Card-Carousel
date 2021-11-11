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
    
    // Detail Hero Page
    @State var showDetailPage: Bool = false
    @State var currentCard: Card?
    
    // for Hero animation
    // Using NameSpace
    @Namespace var animation
    
    
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
                        
                        InfiniteStackedCardView(cards: $cards, card: card, trailingCardsToShown: trailingCardsToShown, trailingSpaceOfEachCards: trailingSpaceOfEachCards, animation: animation, showDetailPage: $showDetailPage)
                        // Setting on Tap
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    currentCard = card
                                    showDetailPage = true
                                }
                            }
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
        .overlay(DetailPage())
    }
    
    @ViewBuilder
    func DetailPage() -> some View {
        
        if let currentCard = currentCard, showDetailPage {
            
            Rectangle()
                .fill(currentCard.cardColor)
                .matchedGeometryEffect(id: currentCard.id, in: animation)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 15) {
                
                // Close Button
                Button {
                    withAnimation {
                        // Closing view
                        showDetailPage = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.white.opacity(0.6))
                        .clipShape(Circle())
                }
                // Moving button to left without Spacers
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(currentCard.date)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text(currentCard.title)
                    .font(.title.bold())
                    
                ScrollView(.vertical, showsIndicators: false) {
                    
                    // Sample Content
                    Text(content)
                        .padding(.top)
                }
            }
            .foregroundColor(.white)
            .padding()
            // Moving button to top without Spacers
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
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
    
    // for Hero animation
    var animation: Namespace.ID
    @Binding var showDetailPage: Bool
    
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
        
            ZStack {
                
                // Hiding original Content
                // to avois warning
                // When MatchedGeometry Effect Animating
                
                // Matched Geometry effect not animating smoothly when we hide the original content
                // don't avoid original content if you want smooth animation
//                RoundedRectangle(cornerRadius: 25)
//                    .fill(card.cardColor)
                
                if showDetailPage {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.clear)
                } else {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(card.cardColor)
                        .matchedGeometryEffect(id: card.id, in: animation)
                }
            }
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

let content = "When the user taps in an editable text view, that text view becomes the first responder and automatically asks the system to display the associated keyboard. Because the appearance of the keyboard has the potential to obscure portions of your user interface, it is up to you to make sure that does not happen by repositioning any views that might be obscured. Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.\n \nIt is your application’s responsibility to dismiss the keyboard at the time of your choosing. You might dismiss the keyboard in response to a specific user action, such as the user tapping a particular button in your user interface. To dismiss the keyboard, send the resignFirstResponder() message to the text view that is currently the first responder. Doing so causes the text view object to end the current editing session (with the delegate object’s consent) and hide the keyboard.\n \nThe appearance of the keyboard itself can be customized using the properties provided by the UITextInputTraits protocol. Text view objects implement this protocol and support the properties it defines. You can use these properties to specify the type of keyboard (ASCII, Numbers, URL, Email, and others) to display. You can also configure the basic text entry behavior of the keyboard, such as whether it supports automatic capitalization and correction of the text."
