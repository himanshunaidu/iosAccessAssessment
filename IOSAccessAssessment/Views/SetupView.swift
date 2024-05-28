//
//  SetupView.swift
//  IOSAccessAssessment
//
//  Created by Kohei Matsushima on 2024/03/29.
//

import SwiftUI

struct SetupView: View {
    let classes = ["Traffic Lights", "Poles", "Human", "Walls", "Sidewalks", "Fences"]
    @State private var selection = Set<Int>()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Setup View")
                    .font(.largeTitle)
                    .padding(.bottom, 5)
                
                Text("Select Classes to Identify")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                List {
                    ForEach(0..<classes.count, id: \.self) { index in
                        Button(action: {
                            if self.selection.contains(index) {
                                self.selection.remove(index)
                            } else {
                                self.selection.insert(index)
                            }
                        }) {
                            Text(classes[index])
                                .foregroundColor(self.selection.contains(index) ? .blue : .black)
                        }
                    }
                }
                .environment(\.colorScheme, .light)
            }
            .padding()
            .navigationBarTitle("Setup View", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: ContentView(selection: Array(selection), classes: classes)) {
                Text("Next").foregroundStyle(Color.black).font(.headline)
            })
        }.environment(\.colorScheme, .light)
    }
}

