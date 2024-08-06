////
////  Testing.swift
////  WasteNot
////
////  Created by LUU THANH TAM on 2024/08/01.
////
//
//import SwiftUI
//
//struct Action: Identifiable {
//    
//    let id = UUID().uuidString
//    let title: String
//    let icon: String
//    let bgColor: Color
//    let fgColor: Color
//    let cornerRadius: CGFloat
//    let action: () -> Void?
//    
//    init(title: String, icon: String, bgColor: Color, fgColor: Color, cornerRadius: CGFloat = 0, action: @escaping () -> Void?) {
//        self.title = title
//        self.icon = icon
//        self.bgColor = bgColor
//        self.fgColor = fgColor
//        self.cornerRadius = cornerRadius
//        self.action = action
//    }
//}
//
//struct SwipeTammie<Content: View>: View {
//    @GestureState var isDragging = false
//    @State var dragOffset: CGFloat = 0
//    var leftActions: [Action]?
//    var rightActions: [Action]
//    let content: Content
//    let frameHeight: CGFloat
//    
//    init(@ViewBuilder content: () -> Content, leftActions: [Action]?, rightActions: [Action], frameHeight: CGFloat = 90) {
//        self.content = content()
//        self.leftActions = leftActions
//        self.rightActions = rightActions
//        self.frameHeight = frameHeight
//    }
//    var body: some View {
//        ZStack {
//            // Action views
//            if dragOffset < 0 {
//                HStack {
//                    Spacer()
//                    makeActionsView(actions: rightActions)
//                        .frame(width: max(0, abs(dragOffset + 40)))
//                        .padding(.horizontal)
//                }
//            } else if dragOffset > 0 {
//                HStack {
//                    makeActionsView(actions: leftActions ?? [])
//                        .frame(width: max(0, abs(dragOffset - 10)))
//                    Spacer()
//                }
//            }
//            // Main content
//            content
//                .offset(x: dragOffset)
//                .gesture(DragGesture()
//                    .updating($isDragging) { value, state, _ in
//                        state = true
//                        DispatchQueue.main.async {
//                            onChanged(value: value)
//                        }
//                    }
//                    .onEnded { value in
//                        withAnimation(.spring()) {
//                            onEnd(value: value)
//                        }
//                        
//                    }
//                )
//        }
//        .onDisappear {
//            dragOffset = 0
//        }
//        .padding(.horizontal)
//        .frame(minHeight: frameHeight)
//    }
//    
//    private func onChanged(value: DragGesture.Value) {
//        // Update dragOffset based on the gesture's translation
//        if value.translation.width < 0 && isDragging {
//            dragOffset = value.translation.width
//        } else if value.translation.width > 0 && isDragging {
//            dragOffset = value.translation.width
//        }
//        
//    }
//    
//    private func onEnd(value: DragGesture.Value) {
//        // Handle the end of the gesture
//        if value.translation.width < 0 {
//            if value.translation.width <= -50 {
//                withAnimation {
//                    dragOffset = CGFloat(min(4, rightActions.count)) * -80
//                }
//            } else {
//                withAnimation {
//                    dragOffset = 0
//                }
//            }
//        } else {
//            if value.translation.width > 50 {
//                withAnimation {
//                    dragOffset = CGFloat(min(4, leftActions?.count ?? 0)) * 80
//                }
//            } else {
//                withAnimation {
//                    dragOffset = 0
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func makeActionsView(actions: [Action]) -> some View {
//        HStack(spacing: 8) {
//            ForEach(actions) { action in
//                ZStack {
//                    Rectangle()
//                        .fill(action.bgColor)
//                        .cornerRadius(action.cornerRadius)
//                    Button {
//                        action.action()
//                    } label: {
//                        VStack {
//                            Image(systemName: action.icon)
//                                .foregroundColor(action.fgColor)
//                                .font(.system(size: 20))
//                                .padding(.bottom, 8)
//                            Text(action.title)
//                                .foregroundColor(action.fgColor)
//                                .multilineTextAlignment(.center)
//                                .lineLimit(3)
//                                .frame(width: 70)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct Testing: View {
//    @State var items = ["View 1", "View 2", "View 3"]
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                Text("Independed view:")
//                    .bold()
//                Spacer()
//            }
//            
//                List(items.indices, id: \.self) { index in
//                    SwipeTammie(content: {
//                        Text(items[index])
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .background(Color.blue.opacity(0.9))
//                            .cornerRadius(10)
//                    },
//                                leftActions: [Action(title: "Share", icon: "", bgColor: .green, fgColor: .white, cornerRadius: 10, action: {})],
//                                rightActions: [Action(title: "Delete", icon: "trash", bgColor: .red, fgColor: .white, cornerRadius: 10, action: { items.remove(at: index)}), Action(title: "Edit", icon: "pencil", bgColor: .orange, fgColor: .white, cornerRadius: 10, action: {})])
//                }
//                .listStyle(.plain)
//            
//            Spacer()
//        }
//    }
//}
//
//#Preview {
//    Testing()
//}
