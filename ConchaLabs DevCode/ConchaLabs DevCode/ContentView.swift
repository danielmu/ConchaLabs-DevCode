//
//  ContentView.swift
//  ConchaLabs DevCode
//
//  Created by Dan Muana on 1/25/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var isNextActive = false
    @State var sliderHeight: CGFloat = 0
    @State var lastDragVal: CGFloat = 0
    
    @StateObject var viewModel = ViewModel()
    
    // MARK: - Main
    var body: some View {
        ZStack {
            Color("lighterGray").edgesIgnoringSafeArea(.all)
            
            VStack {
                TitleView(isComplete: viewModel.isComplete)
                    .padding()
                HStack {
                    if !viewModel.isComplete {
                        SliderView(isNextActive: $isNextActive,
                                   sliderHeight: $sliderHeight,
                                   lastDragVal: $lastDragVal,
                                   viewModel: viewModel)
                            .offset(x: 30)
                        SideButtonsView(isNextActive: $isNextActive,
                                        sliderHeight: $sliderHeight,
                                        lastDragVal: $lastDragVal,
                                        viewModel: viewModel)
                    } else {
                        ResutsView(viewModel: viewModel).onAppear{isNextActive = true}
                        
                    }
                }
                ButtonView(isNextActive: $isNextActive,
                           isComplete: viewModel.isComplete,
                           viewModel: viewModel)
                    .padding(.top, 40)
            }
        }.onAppear{
            viewModel.startFetchTicks()
            viewModel.getTicks()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Views

struct ResutsView: View {
    var viewModel: ViewModel
    var body: some View {
        VStack (alignment: .leading) {
            ResutSubViews(slider: "Slider 1:",
                          index: "\(viewModel.selectedIndex[0])",
                          value: "\(viewModel.selectedTicks[0])")
            ResutSubViews(slider: "Slider 2:",
                          index: "\(viewModel.selectedIndex[1])",
                          value: "\(viewModel.selectedTicks[1])")
            ResutSubViews(slider: "Slider 3:",
                          index: "\(viewModel.selectedIndex[2])",
                          value: "\(viewModel.selectedTicks[2])")
        }
    }
}

struct ResutSubViews: View {
    var slider: String
    var index: String
    var value: String
    var body: some View {
        HStack {
            Text(slider).padding(.horizontal, 5).font(.italic(.body)())
            Text(index).bold().padding(.horizontal, 5)
            Text(value).bold().padding(.horizontal, 5)
        }
    }
}

struct TitleView: View {
    var isComplete: Bool
    var body: some View {
        VStack {
            Text(!isComplete ? "Please take this test": "Slider Resuts")
                .fontWeight(.medium).font(.title)
        }
    }
}

struct ButtonView: View {
    @Binding var isNextActive: Bool
    var isComplete: Bool
    var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                if isNextActive {
                    if !isComplete {
                        isNextActive = false
                        viewModel.selectedTicks.append(
                            viewModel.ticks[viewModel.sliderIndex])
                        viewModel.selectedIndex.append(
                            viewModel.sliderIndex + 1)
                        viewModel.nextFetchTicks(choice: String(viewModel.sliderIndex),
                                                 sessionID: viewModel.sessionID)
                        viewModel.getTicks()
                    } else {
                        isNextActive = false
                        viewModel.isComplete = false
                        viewModel.selectedTicks = []
                        viewModel.selectedIndex = []
                        viewModel.startFetchTicks()
                        viewModel.getTicks()
                        return
                    }
                }
            }) {
                Text(!isComplete ? "Next": "Start Over")
                    .frame(width: UIScreen.main.bounds.width * 0.75,
                           height: UIScreen.main.bounds.width * 0.075)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(isNextActive ? .yellow : .gray)
            .foregroundColor(isNextActive ? .black : .white)
        }
    }
}

struct SideButtonsView: View {
    @Binding var isNextActive: Bool
    @Binding var sliderHeight: CGFloat
    @Binding var lastDragVal: CGFloat
    
    var maxHeight: CGFloat = UIScreen.main.bounds.height / 3
    var viewModel: ViewModel
    
    var body: some View {
        VStack {
            //top button
            Button(action: {
                isNextActive = true
                viewModel.sliderIndex = viewModel.sliderIndex != viewModel.arrCount ? viewModel.sliderIndex + 1 : viewModel.arrCount
                sliderHeight = maxHeight * (CGFloat(viewModel.sliderIndex) / CGFloat(viewModel.arrCount))
                viewModel.atTick = viewModel.ticks[viewModel.sliderIndex]
                
                lastDragVal = sliderHeight
            }) {
                Image(systemName: "chevron.up")
                    .frame(width: UIScreen.main.bounds.width * 0.06,
                           height: UIScreen.main.bounds.width * 0.075)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.white)
            .foregroundColor(.yellow)
            .padding(.vertical, 30)
            
            //bottom button
            Button(action: {
                isNextActive = true
                viewModel.sliderIndex = viewModel.sliderIndex != 0 ? viewModel.sliderIndex - 1 : 0
                sliderHeight = maxHeight * (CGFloat(viewModel.sliderIndex) / CGFloat(viewModel.arrCount))
                viewModel.atTick = viewModel.ticks[viewModel.sliderIndex]
                lastDragVal = sliderHeight
            }) {
                Image(systemName: "chevron.down")
                    .frame(width: UIScreen.main.bounds.width * 0.06,
                           height: UIScreen.main.bounds.width * 0.075)
                    .font(.body)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.white)
            .foregroundColor(.yellow)
        }
    }
}

struct SliderView: View {
    var maxHeight: CGFloat = UIScreen.main.bounds.height / 3
    
    @State var sliderProgress: CGFloat = 0
    @Binding var isNextActive: Bool
    @Binding var sliderHeight: CGFloat
    @Binding var lastDragVal: CGFloat
    
    var viewModel: ViewModel
    
    var body: some View {
        VStack {
            //value text
            Text("Current Value:  \(viewModel.atTick)").fontWeight(.semibold).padding(.bottom,20)
            //Slider bars
            ZStack(alignment: .bottom, content: {
                Rectangle().fill(Color(.lightGray)).opacity(0.50)
                VStack (spacing: 20) {
                    ForEach(0..<viewModel.arrCount,id: \.self) { index in
                        Rectangle()
                            .fill(.black)
                            .frame(width: 20, height: 2)
                    }
                }
                
                LinearGradient(colors: [.yellow, Color("darkYellow")], startPoint: .topLeading, endPoint: .bottomTrailing).frame(height: sliderHeight)
                VStack (spacing: 20) {
                    ForEach(0..<viewModel.sliderIndex,id: \.self) { index in
                        Rectangle()
                            .fill(.white)
                            .frame(width: 20, height: 2)
                    }
                }
                
            })
                .frame(width: 20, height: maxHeight, alignment: .center)
                .cornerRadius(35)
                .overlay(
                    Rectangle()
                        .fill(Color(.yellow)).opacity(0.35)
                        .cornerRadius(20)
                        .frame(width: 40, height: 40)
                        .offset(y: -sliderHeight + 20)
                    ,alignment: .bottom
                )
                .overlay(
                    Rectangle()
                        .fill(Color(.white))
                        .cornerRadius(20)
                        .frame(width: 20, height: 20)
                        .offset(y: -sliderHeight + 10)
                    ,alignment: .bottom
                )
                .gesture(DragGesture(minimumDistance: 0).onChanged({ (Value) in
                    let translation = Value.translation
                    sliderHeight = -translation.height + lastDragVal
                    
                    //limit slider
                    sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
                    sliderHeight = sliderHeight >= 1 ? sliderHeight : 1
                    
                    // updating slider progress
                    let progrss = sliderHeight / maxHeight
                    
                    sliderProgress = progrss <= 1.0 ? progrss : 1
                    viewModel.sliderIndex = Int(sliderProgress * 14)
                    viewModel.atTick = viewModel.ticks[viewModel.sliderIndex]
                }).onEnded({ (Value) in
                    sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
                    sliderHeight = sliderHeight >= 1 ? sliderHeight : 1
                    
                    lastDragVal = sliderHeight
                    isNextActive = true
                }))
            
        }
    }
}
