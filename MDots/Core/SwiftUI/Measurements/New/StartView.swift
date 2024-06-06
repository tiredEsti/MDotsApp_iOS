//
//  File.swift
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

import Foundation


import SwiftUI

/// View for the start screen of the MDots app.
struct StartView: View {
    @State private var patientID: String = ""
    @State private var testType: TestType = (TestType.allCases.first ?? TestType.isquio)
    @State private var side: String = ""
    @State private var pageIndex = 0
    @State private var firstPage = true
    @State private var pages: [Page]
    private let dotAppearance = UIPageControl.appearance()
    
    /// Initializes the StartView with a test type and patient ID.
    /// - Parameters:
    ///   - testType: The type of test.
    ///   - patientID: The ID of the patient.
    init(testType: TestType, patientID: String) {
        self.testType = testType
        self.patientID = patientID
        self.pages = Page.createPages(testType: testType)
    }
    
    /// Wrapper struct to use `MainViewController` in SwiftUI
    struct ObjectiveCViewControllerWrapper: UIViewControllerRepresentable {
        let patientID: String // Property to store the patient ID
        let testtype: String
        let side: String
        
        /// Initializes the ObjectiveCViewControllerWrapper with optional patient ID, test type, and side.
        /// - Parameters:
        ///   - patientID: The ID of the patient.
        ///   - testtype: The type of test.
        ///   - side: The side of the movement.
        init(patientID: String?, testtype: TestType, side: String) {
            self.patientID = patientID ?? ""
            self.testtype = testtype.rawValue
            self.side = side
        }
        
        func makeUIViewController(context: Context) -> MainViewController {
            let mainViewController = MainViewController()
            mainViewController.setPatientID(self.patientID) // Pass patient ID to updateLabelText
            mainViewController.setTestType(self.testtype)
            mainViewController.setSide(self.side)
            
            return mainViewController
        }
        
        func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
            // Update the Objective-C view controller if needed
        }
    }
    
    var body: some View {
        if (firstPage){
            HStack(alignment: .bottom) {
                VStack {
                    Button {
                        side = "L"
                        changeBool()
                    } label: {
                        Image("LeftSide").resizable().aspectRatio(contentMode: .fit)
                        //("Left side")
                    }.buttonStyle(.borderedProminent)
                    Text("Measure left side movement").font(.footnote)
                }.padding()
                
                if(testType == TestType.isquio) {
                    VStack {
                        Button {
                            side = "S"
                            changeBool()
                        } label: {
                            Image("SingleSide").resizable().aspectRatio(contentMode: .fit)
                            //Text("Single movement")
                        }.buttonStyle(.borderedProminent)
                        Text("Measure single movement").font(.footnote)
                    }.padding()
                }
                
                VStack {
                    Button {
                        side = "R"
                        changeBool()
                    } label: {
                        Image("RightSide").resizable().aspectRatio(contentMode: .fit)
                        //Text("Right side")
                    }.buttonStyle(.borderedProminent)
                    Text("Measure right side movement").font(.footnote)
                }.padding()
            }
            .transition(.scale) // Animation: scale to disappear
            .scaleEffect(firstPage ? 1.0 : 0.0) // Scale effect to control visibility
            .opacity(firstPage ? 1.0 : 0.0)
        } else {
            TabView(selection: $pageIndex) {
                ForEach(pages) { page in
                    VStack {
                        Spacer()
                        PageView(page: page)
                        Spacer()
                        if page == pages.last {
                            NavigationLink(destination: ObjectiveCViewControllerWrapper(patientID: patientID, testtype: testType, side: side)) {
                                HStack {
                                    Image(systemName: "angle")
                                    Text("New Measure")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        } else {
                            Button("Next", action: incrementPage)
                                .buttonStyle(.bordered)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 50)
                    .tag(page.tag)
                }
            }
            .animation(.easeInOut, value: pageIndex)// 2
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))
            .tabViewStyle(PageTabViewStyle())
            .onAppear {
                
                dotAppearance.currentPageIndicatorTintColor = .black
                dotAppearance.pageIndicatorTintColor = .gray
            }
        }
    }
    
    /// Increments the page index.
    func incrementPage() {
        pageIndex += 1
    }
    
    /// Toggles the `firstPage` boolean with animation.
    func changeBool() {
        withAnimation {
            firstPage.toggle() // Toggle the boolean with animation
        }
    }
    
    /// Sets the page index to zero.
    func goToZero() {
        pageIndex = 0
    }
    
}


