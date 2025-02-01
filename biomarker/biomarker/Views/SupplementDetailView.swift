//
//  SupplementDetailedView.swift
//  biomarker
//
//  Created by sachin jeph on 02/02/25.
//

import Foundation
import SwiftUI


struct SupplementDetailView: View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    @Binding var showSelf : Bool
    var supplement: BMSupplement
    @State var analysisInProgress = false

    var body: some View {
        GeometryReader{ geo in
            VStack{
                ScrollView(showsIndicators: false){
                    SupplementRow(supplement: supplement)
                    
                    if supplement.aiAnalysisStage == .completed || supplement.aiAnalysisStage == .outdated{
                        biomarerIntelligenceLabel()
                            .padding()
                    }
                    
                    if supplement.aiAnalysisStage == .never{
                        Button(action:{analyseSupplementWithLLM()}){
                            label("Analyse with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                        }
                    }
                    
                    if supplement.aiAnalysisStage == .failed{
                        Button(action:{analyseSupplementWithLLM()}){
                            label("Analyse with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                        }
                        Text("\(supplement.name)'s analysis failed last time, tap to try again")
                            .fontWeight(.bold)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .padding(.top,3)
                            .padding(.bottom)
                    }
                    
                }
            }.navigationTitle("\(supplement.supplementType == .food ? "Food" : "Supplement") Report")
        }
       // .background(Color(UIColor.systemBackground))
        //.cornerRadius(8)
        //.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func analyseSupplementWithLLM(){
        
        if analysisInProgress{
            print("Cannot request a supplement analysis as the last one is in progress")
            return
        }
        
        analysisInProgress = true
        UserHealthContext.analyzeSupplementWithLLM(supplement) { success, response in
            analysisInProgress = false
            if success{
            
                
            }else{
                print("Failed to analyse the reponse")
                //WE WILL PROBABLY NOT SHOW THIS MESSAGE BECAUSE WE IMEEDIATELY MOVE TO THE SCREEN 7- WHICH IS SUPPLEMENT DETAILED VIEW
                //message = "The \(supplementIsFoodItem ? "food item" : "supplement") has been added to your stack. However Biomarker was unable to analyze the \(supplementIsFoodItem ? "food item" : "supplement"), and you can request an analysis later from the supplement details page."
                
                //currentStep = 7
            }
        }
    }

}
