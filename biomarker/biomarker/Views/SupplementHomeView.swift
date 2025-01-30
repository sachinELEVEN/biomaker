//
//  SupplementHomevIEW.swift
//  biomarker
//
//  Created by sachin jeph on 31/01/25.
//

import Foundation
import SwiftUI

struct SupplementHomeView:View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    @State var showAddSupplementScreen = false
    var body: some View {
        NavigationView{
            GeometryReader{ geo in
                VStack(alignment: .leading){
                   
                    ScrollView(showsIndicators: false){
                        VStack(alignment: .leading){
                            
                            Text("Your stack has \(BMSupplementStackGL.supplements.count) supplements")
                                .font(.headline)
                                .foregroundStyle(Color.secondary)
                            
                            //                            HStack{
                            //                                Text("supplement stack")//stack data and high level overview- basically ai fields
                            //                                    .italic()
                            //                                    .underline()
                            //
                            //                                imageView(systemName: "plus.circle.fill", color: .primary, size: 30)
                            //                            }
                            //                            .fontWeight(.bold)
                            //                            .font(.title)
                            //                            .multilineTextAlignment(.leading)
                            //                            .padding(.vertical)
                            //
                            
                            
                            HStack{
                                Spacer()
                            Button(action:{
                                showAddSupplementScreen.toggle()
                            }){
                                label("Add a supplement", textColor: .primaryInvert, bgColor: .primary, imgName: "bolt.fill", imgColor: .primaryInvert, width: geo.size.width*0.8, radius: 10,verticalPadding: 5)
                            }
                                Spacer()
                            }.padding(.top)
                            .sheet(isPresented: $showAddSupplementScreen){
                                AddSupplementView()
                            }
                            
                         
                            
                            Text("Supplements")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                            
                            ForEach(bmSupplementStackGL.supplements){ supp in
                                SupplementRow(supplement: supp)
                                
                            }
                            
                            
                            Text("Schedule")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                            
                            //biomarker recommended
                            Text("Recommended schedule")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                        }
                    }
                }.padding(.horizontal)
            }.navigationTitle("Supplement Stack")
        }
    }
}


struct SupplementRow: View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    var supplement: BMSupplement
    

    var body: some View {
        HStack {
            // Example icon, replace with appropriate icons
            Image(systemName: "leaf.fill") // Use an appropriate SF Symbol or custom icon
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)

            VStack(alignment: .leading) {
                Text(supplement.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack {
                    Text("\(supplement.strengthNumber) \(supplement.strengthUnit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(supplement.frequency.rawValue) // Display frequency
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(supplement.form?.rawValue ?? "") // Display form
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let userNotes = supplement.userNotes, !userNotes.isEmpty {
                    Text("Notes: \(userNotes)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
