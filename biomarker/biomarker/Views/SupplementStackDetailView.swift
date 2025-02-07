//
//  supplementStackDetailView.swift
//  biomarker
//
//  Created by sachin jeph on 07/02/25.
//

import Foundation
import SwiftUI

//here we will give brief about the supplementStack stack and show list of all supplementStacks- might be overkill and not want to do that tbh
struct supplementStackBriefView: View {
    @ObservedObject var supplementStack = BMSupplementStackGL
    @Binding var showSelf : Bool
    @State var analysisInProgress = false
    @State var showDetailView = false
    var width: CGFloat
    
    var body: some View{
        //GeometryReader{ geo in
            VStack{
                if supplementStack.supplements.count == 0{
                    HStack{
                        Spacer()
                        Text("Add your supplements to your stack, and see a comprehensive report right here")
                            .font(.title2)
                            .foregroundStyle(Color.secondary)
                            .padding()
                        Spacer()
                    }
                }else{
                    if supplementStack.aiAnalysisStage == .never {
                        Button(action:{analysesupplementStackWithLLM()}){
                            VStack{
                                HStack{
                                Text("Supplement Stack Analysis")
                                                           //.italic()
                                                           //.underline()
                                                               .fontWeight(.bold)
                                                               .font(.headline)
                                                               .multilineTextAlignment(.leading)
                                                               .padding(.vertical)
                                    Spacer()
                                }
                                label("\(analysisInProgress ? "Analysing":"Analyse with Biomarker Intelligence")", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: width*0.8, radius: 10,verticalPadding: 5)
                                
                                Text("You have \(supplementStack.supplements.count) \(supplementStack.supplements.count==1 ? "supplement" : "supplements") in your stack, analyse \(supplementStack.supplements.count==1 ? "it" : "them") and and see a comprehensive report right here")
                                    .fontWeight(.bold)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    .padding(.top,3)
                                    .padding(.bottom)
                                    .padding(.horizontal)
                            }//.padding(.top)
                            
                        }
                    }else  if supplementStack.aiAnalysisStage == .failed{
                        HStack{
                            Text("Supplement Stack Analysis")
                            //.italic()
                            //.underline()
                                .fontWeight(.bold)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                            Spacer()
                        }
                        Button(action:{analysesupplementStackWithLLM()}){
                            label("\(analysisInProgress ? "Analysing":"Analyse with Biomarker Intelligence")", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: width*0.8, radius: 10,verticalPadding: 5)
                        }
                        Text("Your stack's analysis failed last time, tap to try again")
                            .fontWeight(.bold)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .padding(.top,3)
                            .padding(.bottom)
                            .padding(.horizontal)
                    }
                    
                    else{
                        Button(action:{
                            showDetailView.toggle()
                        }){
                        VStack(alignment: .leading){
                            //show basic information about the stack
                            //                        supplementStackDetailView.aiInfoView(header: supplementStack.getProperty(property: .ai_common_name) != "" ? supplementStack.getProperty(property: .ai_common_name)  : "Supplement Stack", description: "Learn more")
                            HStack{
                                VStack(alignment: .leading){
                                    Text("Supplement Stack Analysis")
                                    //.italic()
                                    //.underline()
                                        .fontWeight(.bold)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .padding(.top)
                                    Text("Learn more")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                        .padding([.bottom])
                                }
                                Spacer()
                            }
                            
//                            supplementStackDetailView.aiInfoView(header: "Rating", description: supplementStack.getProperty(property: .ai_rating))//should be in format x/10
//                            
                            Text("Your supplement stack got a rating of \(supplementStack.getProperty(property: .ai_rating))")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.leading)
                                //.padding(.top)
                            
                            if  Float(supplementStack.getProperty(property: .ai_rating)) != nil{
                                ZStack(alignment: .leading) {
                                    // Background rectangle
                                    Rectangle()
                                        .fill(Color.secondary) // Default color for the background
                                        .frame(height: 30) // Height of the progress bar
                                        .cornerRadius(20) // Optional: Rounded corners
                                    
                                    // Filled rectangle based on the number
                                    Rectangle()
                                        .fill(supplementStackDetailView.colorForNumber(Float(supplementStack.getProperty(property: .ai_rating))!)) // Set the fill color based on the number
                                        .frame(width: min(CGFloat(Float(supplementStack.getProperty(property: .ai_rating))!) / 10 * width, width/1.2), height: 30) // Calculate width based on the number
                                        .cornerRadius(20) // Optional: Rounded corners
                                }//.padding(.horizontal)
                            }
                            
                            //give a brief of the report
                            Text(supplementStack.getProperty(property: .compatibility).prefix(200) + "...")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical)
                            
                        }
                    }
                    }
                    
                    //if supplementViewToShowInDetail != nil{
//                    NavigationLink(destination: supplementStackDetailView(showSelf: $showDetailView,isActive: $showDetailView));) {
//                            Text("")
//                        }
                    
                    NavigationLink(destination: supplementStackDetailView(showSelf: $showDetailView),isActive: $showDetailView) {
                        EmptyView() // This will not show any button; it only serves to navigate
                    }
                        
                }
            }
        //}
    }
    
    func analysesupplementStackWithLLM(){
        
        if analysisInProgress{
            print("Cannot request a supplementStack analysis as the last one is in progress")
            return
        }
        analysisInProgress = true
       // isAnimating = true
        
        
        UserHealthContext.analyzeSupplementStackWithLLM(supplementStack) { success, response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                //putting thing in here because we do not want abrupt stops in animation in case completion handler gets called very quicky
                //side effect is that we will show anlaying with biomarker for a few moments longer, but its fine
               // isAnimating = false
                analysisInProgress = false
            })
            
            
            
            if success{
            
                
            }else{
                print("Failed to analyse the reponse")
                //WE WILL PROBABLY NOT SHOW THIS MESSAGE BECAUSE WE IMEEDIATELY MOVE TO THE SCREEN 7- WHICH IS supplementStack DETAILED VIEW
                //message = "The \(supplementStackIsFoodItem ? "food item" : "supplementStack") has been added to your stack. However Biomarker was unable to analyze the \(supplementStackIsFoodItem ? "food item" : "supplementStack"), and you can request an analysis later from the supplementStack details page."
                
                //currentStep = 7
            }
        }
    }
    
}
    
struct supplementStackDetailView: View {
    @ObservedObject var supplementStack = BMSupplementStackGL
    @Binding var showSelf : Bool
//    var supplementStack: BMsupplementStack
    @State var analysisInProgress = false
    @State private var isAnimating = false
//    @State var showsupplementStackEditView = false
//    @State var showsupplementStackHistoryView = false
//    @State var showActionSheet = false

    var body: some View {
        GeometryReader{ geo in
            ZStack {
               
                    LinearGradient(gradient: Gradient(colors: [Color.brightPurple.opacity(isAnimating ? 0.2 : 0), Color.brightpurple.opacity(isAnimating ? 0 : 0.2)]), startPoint: .topLeading, endPoint: .topTrailing)
                        .edgesIgnoringSafeArea(.all)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                       .opacity(analysisInProgress ? 1 : 0)//for some reason if i put this gradient in if condition on basis analysisInProgress, then animation gets stuck, not giving it too much attention for now
               
                VStack{
                    ScrollView(showsIndicators: false){
                        //supplementStackRow(supplementStack: supplementStack, showRating: false, showDateOfCreation: true)
                        
                        supplementStackDetailView.descriptionView("This supplement report takes into account the supplements and food items in your stack, as well as your medical test records.")
                        
                        if supplementStack.aiAnalysisStage == .completed || supplementStack.aiAnalysisStage == .outdated{
                            //we notice for supplement stack ai return stack not valid many times, so we will not use it

                           // if supplementStack.isSupplementStackValid(){
                                biomarerIntelligenceLabel()
                                    .padding()
                           // }else{
                                //we notice for supplement stack ai return stack not valid many times, so we will not use it
//                                biomarerIntelligenceLabel(text: "Biomarker couldn't find any specific information on your stack")
//                                    .padding()
                          //  }
                        }
                        
                        if supplementStack.aiAnalysisStage == .never{
                            Button(action:{analysesupplementStackWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse with Biomarker Intelligence")", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                        }
                        
                        if supplementStack.aiAnalysisStage == .outdated{
                            Button(action:{analysesupplementStackWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse with Biomarker Intelligence")", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                            Text("You have made changes to your stack since the last analysis. Tap to perform the analysis again.")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.top,3)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        
                        if supplementStack.aiAnalysisStage == .failed{
                            Button(action:{analysesupplementStackWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse with Biomarker Intelligence")", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                            Text("Your stack's analysis failed last time, tap to try again")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.top,3)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        
                       // supplementStackChartViewContainer(supplementStack: supplementStack)
                        
                        //Reminder and dosage information- in edit options
                        
                        //AI data being displayed
                        if supplementStack.aiAnalysisStage == .completed || supplementStack.aiAnalysisStage == .outdated{
                            supplementStackDetailView.descriptionView("Please consult your doctor or a qualified healthcare professional for any advice regarding your supplementStacks, food choices, and dosage recommendations.")
                        }
                        
                        
                        supplementStackDetailView.aiInfoView(header: "Rating", description: supplementStack.getProperty(property: .ai_rating))//should be in format x/10
                        
                        if  Float(supplementStack.getProperty(property: .ai_rating)) != nil{
                            ZStack(alignment: .leading) {
                                // Background rectangle
                                Rectangle()
                                    .fill(Color.secondary) // Default color for the background
                                    .frame(height: 30) // Height of the progress bar
                                    .cornerRadius(20) // Optional: Rounded corners
                                
                                // Filled rectangle based on the number
                                Rectangle()
                                    .fill(supplementStackDetailView.colorForNumber(Float(supplementStack.getProperty(property: .ai_rating))!)) // Set the fill color based on the number
                                    .frame(width: min(CGFloat(Float(supplementStack.getProperty(property: .ai_rating))!) / 10 * geo.size.width, geo.size.width/1.2), height: 30) // Calculate width based on the number
                                    .cornerRadius(20) // Optional: Rounded corners
                            }.padding(.horizontal)
                        }
                        
                        supplementStackDetailView.aiInfoView(header: "Stack Compatibility", description: supplementStack.getProperty(property: .compatibility))
                        supplementStackDetailView.aiInfoView(header: "Recommendation", description: supplementStack.getProperty(property: .ai_advice))
                        supplementStackDetailView.aiInfoView(header: "Recommended Timing", description: supplementStack.getProperty(property: .recommended_timing))
                        
                        supplementStackDetailView.aiInfoView(header: "Your Stack Name", description: supplementStack.getProperty(property: .ai_common_name))
                        supplementStackDetailView.aiInfoView(header: "Category", description: supplementStack.getProperty(property: .ai_category))
                            .padding(.bottom)
                        
                        
                        Divider().padding(.horizontal)
                       // supplementStackDetailView.aiInfoView(header: "Your notes", description: supplementStack.userNotes)
                          //  .padding(.bottom)
                        
//                            .sheet(isPresented: $showsupplementStackEditView){
//                                AddsupplementStackView(showSelf: $showsupplementStackEditView, supplementStackToEdit: supplementStack)
//                            }
//                        
//                            .sheet(isPresented: $showsupplementStackHistoryView){
//                                supplementStackHistoryView(showSelf: $showsupplementStackHistoryView, supplementStack: supplementStack)
//                            }
                        
                        
                        
                    }.animation(.default, value: 1)
                }.navigationTitle("Stack Report")
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            Button(action: {
//                                // Your action here
//                               // self.showsupplementStackEditView.toggle()//view history of this supplementStack
//                                showsupplementStackHistoryView.toggle()
//                            }) {
//                                Image(systemName: "clock.arrow.circlepath")  // SF Symbol for search icon
//                            }
//                        }
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            Button(action: {
//                                // Your action here
//                                self.showsupplementStackEditView.toggle()
//                            }) {
//                                Image(systemName: "slider.horizontal.3")  // SF Symbol for search icon
//                            }
//                        }
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            Button(action: {
//                                // Your action here
//                                self.showActionSheet.toggle()
//                            }) {
//                                Image(systemName: "info.circle")  // SF Symbol for info icon
//                            }
//                            .actionSheet(isPresented: $showActionSheet) {
//                                ActionSheet(
//                                    title: Text("Actions"),
//                                    message: Text(""),
//                                    buttons: [
////                                        .default(Text("Share Original Document (PDF)")) {
////                                            // Navigate to chart view for separate tracking
////                                            //mergeSelectedGroups = false
////                                           // navigateToChartView()
////                                            //print("Each Test Separately")
////        //                                        showUpdateTestManuallyScreen.toggle()
////                                            isSharePresented.toggle()
////                                           // SharePDFView(pdfURL: doc.pdfDocumentUrl,width: system.fullWidth*0.2)
////                                        },
//                                        .destructive(Text("Delete supplementStack and its History")) {
//        //                                        deleteTestRecord()
//                                            //system.medicalDocuments
//                                            //system.deleteDocument(document: doc)
//                                            BMsupplementStackStackGL.removesupplementStack(supplementStack)
//                                            BiomarkerFileSystem.saveSystemMedicalDocuments()
//                                            self.showSelf.toggle()
//                                        },
//                                        .cancel()
//                                    ]
//                                )
//                            }
////                            .sheet(isPresented: $isSharePresented) {
////                                ShareSheet(activityItems: [doc.pdfDocumentUrl])
////                            }
//                        }
//                        
//                    }
                    
            }
        }
       // .background(Color(UIColor.systemBackground))
        //.cornerRadius(8)
        //.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
   static func aiInfoView(header: String, description: String?)->some View{
        return VStack{
            if description != nil && description?.isJustWhitespace() == false{
                headerView(header)
               descriptionView(description!)
            }else{
                //for testing
//                headerView(header)
//                descriptionView("Thyroxine (levothyroxine) is used to replace missing thyroid hormone in individuals with hypothyroidism.  Advantages include improved metabolism, weight management, energy levels, and mood.")
            }
        }
    }
    
    static func headerView(_ text: String)->some View{
        return  HStack{
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
        }//.padding(.bottom,1)
        .padding([.top,.horizontal])
    }
    
    static func descriptionView(_ text: String)->some View{
        return  HStack{
            Text(text)
                .font(.headline)
                //.fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Spacer()
            
        }//.padding(.bottom,1)
        .padding([.horizontal])
    }
    
    // Function to determine the color based on the number
       static func colorForNumber(_ number: Float) -> Color {
           switch number {
           case 0..<4:
               return .red // Highlight red for 0 to 2
           case 4..<7:
               return .yellow // Highlight yellow for 3 to 6
           case 7...10:
               return .green // Highlight green for 7 to 10
           default:
               return .secondary // Default color
           }
       }
    
    func analysesupplementStackWithLLM(){
        
        if analysisInProgress{
            print("Cannot request a supplementStack analysis as the last one is in progress")
            return
        }
        analysisInProgress = true
        isAnimating = true
        
        
        UserHealthContext.analyzeSupplementStackWithLLM(supplementStack) { success, response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                //putting thing in here because we do not want abrupt stops in animation in case completion handler gets called very quicky
                //side effect is that we will show anlaying with biomarker for a few moments longer, but its fine
                isAnimating = false
                analysisInProgress = false
            })
            
            
            if success{
            
                
            }else{
                print("Failed to analyse the reponse")
                //WE WILL PROBABLY NOT SHOW THIS MESSAGE BECAUSE WE IMEEDIATELY MOVE TO THE SCREEN 7- WHICH IS supplementStack DETAILED VIEW
                //message = "The \(supplementStackIsFoodItem ? "food item" : "supplementStack") has been added to your stack. However Biomarker was unable to analyze the \(supplementStackIsFoodItem ? "food item" : "supplementStack"), and you can request an analysis later from the supplementStack details page."
                
                //currentStep = 7
            }
        }
    }

}

