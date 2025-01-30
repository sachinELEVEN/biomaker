//
//  SupplementHomevIEW.swift
//  biomarker
//
//  Created by sachin jeph on 31/01/25.
//

import Foundation
import SwiftUI

struct SupplementHomeView:View {
    @ObservedObject var sys = system
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
