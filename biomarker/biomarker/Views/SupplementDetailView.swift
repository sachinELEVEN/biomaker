//
//  SupplementDetailedView.swift
//  biomarker
//
//  Created by sachin jeph on 02/02/25.
//

import Foundation
import SwiftUI
import Charts


struct SupplementDetailView: View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    @Binding var showSelf : Bool
    var supplement: BMSupplement
    @State var analysisInProgress = false
    @State private var isAnimating = false
    @State var showSupplementEditView = false
    @State var showSupplementHistoryView = false
    @State var showActionSheet = false

    var body: some View {
        GeometryReader{ geo in
            ZStack {
               
                    LinearGradient(gradient: Gradient(colors: [Color.brightPurple.opacity(isAnimating ? 0.2 : 0), Color.brightpurple.opacity(isAnimating ? 0 : 0.2)]), startPoint: .topLeading, endPoint: .topTrailing)
                        .edgesIgnoringSafeArea(.all)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                       .opacity(analysisInProgress ? 1 : 0)//for some reason if i put this gradient in if condition on basis analysisInProgress, then animation gets stuck, not giving it too much attention for now
               
                VStack{
                    ScrollView(showsIndicators: false){
                        SupplementRow(supplement: supplement, showRating: false, showDateOfCreation: true)
                        
                        
                        if supplement.aiAnalysisStage == .completed || supplement.aiAnalysisStage == .outdated{
                            if supplement.isSupplementValid(){
                                biomarerIntelligenceLabel()
                                    .padding()
                            }else{
                                biomarerIntelligenceLabel(text: "Biomarker couldn't find any specific information on \(supplement.name).")
                                    .padding()
                            }
                        }
                        
                        if supplement.aiAnalysisStage == .never{
                            Button(action:{analyseSupplementWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse") with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                        }
                        
                        if supplement.aiAnalysisStage == .outdated{
                            Button(action:{analyseSupplementWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse") with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                            Text("You have made changes to \(supplement.name)'s record since the last analysis. Tap to perform the analysis again.")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.top,3)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        
                        if supplement.aiAnalysisStage == .failed{
                            Button(action:{analyseSupplementWithLLM()}){
                                label("\(analysisInProgress ? "Analysing":"Analyse") with Biomarker Intelligence", textColor: .white, bgColor: .blue, imgName: "staroflife.fill", imgColor: .white, width: geo.size.width/1.2, radius: 10)
                            }
                            Text("\(supplement.name)'s analysis failed last time, tap to try again")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.top,3)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        
                        SupplementChartViewContainer(supplement: supplement)
                        
                        //Reminder and dosage information- in edit options
                        
                        //AI data being displayed
                        if supplement.aiAnalysisStage == .completed || supplement.aiAnalysisStage == .outdated{
                            SupplementDetailView.descriptionView("Please consult your doctor or a qualified healthcare professional for any advice regarding your supplements, food choices, and dosage recommendations.")
                        }
                        
                        
                        SupplementDetailView.aiInfoView(header: "Rating", description: supplement.aiRating)//should be in format x/10
                        
                        if supplement.aiRating != nil && Float(supplement.aiRating!) != nil{
                            ZStack(alignment: .leading) {
                                // Background rectangle
                                Rectangle()
                                    .fill(Color.secondary) // Default color for the background
                                    .frame(height: 30) // Height of the progress bar
                                    .cornerRadius(20) // Optional: Rounded corners
                                
                                // Filled rectangle based on the number
                                Rectangle()
                                    .fill(SupplementDetailView.colorForNumber(Float(supplement.aiRating!)!)) // Set the fill color based on the number
                                    .frame(width: min(CGFloat(Float(supplement.aiRating!)!) / 10 * geo.size.width, geo.size.width/1.2), height: 30) // Calculate width based on the number
                                    .cornerRadius(20) // Optional: Rounded corners
                            }.padding(.horizontal)
                        }
                        
                        SupplementDetailView.aiInfoView(header: "Report", description: supplement.aiReport)
                        SupplementDetailView.aiInfoView(header: "Recommendation", description: supplement.aiAdviceBasedUserHealthContext)
                        SupplementDetailView.aiInfoView(header: "Common reason for usage", description: supplement.aiUsageCommonReasonForUseAndAdvantage)
                        SupplementDetailView.aiInfoView(header: "Side effects", description: supplement.aiSideEffect)
                        SupplementDetailView.aiInfoView(header: "Common Dosage", description: supplement.aiCommonStrengthNumberAndUnits)
                        
                        SupplementDetailView.aiInfoView(header: "Calories", description: supplement.aiCalories)
                        SupplementDetailView.aiInfoView(header: "Common Name", description: supplement.aiCommonName)
                        SupplementDetailView.aiInfoView(header: "Category", description: supplement.aiCategory)
                            .padding(.bottom)
                        
                        
                        Divider().padding(.horizontal)
                        SupplementDetailView.aiInfoView(header: "Your notes", description: supplement.userNotes)
                            .padding(.bottom)
                        
                            .sheet(isPresented: $showSupplementEditView){
                                AddSupplementView(showSelf: $showSupplementEditView, supplementToEdit: supplement)
                            }
                        
                            .sheet(isPresented: $showSupplementHistoryView){
                                SupplementHistoryView(showSelf: $showSupplementHistoryView, supplement: supplement)
                            }
                        
                        
                        
                    }.animation(.default, value: 1)
                }.navigationTitle("\(supplement.supplementType == .food ? "Food" : "Supplement") Report")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // Your action here
                               // self.showSupplementEditView.toggle()//view history of this supplement
                                showSupplementHistoryView.toggle()
                            }) {
                                Image(systemName: "clock.arrow.circlepath")  // SF Symbol for search icon
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // Your action here
                                self.showSupplementEditView.toggle()
                            }) {
                                Image(systemName: "slider.horizontal.3")  // SF Symbol for search icon
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // Your action here
                                self.showActionSheet.toggle()
                            }) {
                                Image(systemName: "info.circle")  // SF Symbol for info icon
                            }
                            .actionSheet(isPresented: $showActionSheet) {
                                ActionSheet(
                                    title: Text("Actions"),
                                    message: Text(""),
                                    buttons: [
//                                        .default(Text("Share Original Document (PDF)")) {
//                                            // Navigate to chart view for separate tracking
//                                            //mergeSelectedGroups = false
//                                           // navigateToChartView()
//                                            //print("Each Test Separately")
//        //                                        showUpdateTestManuallyScreen.toggle()
//                                            isSharePresented.toggle()
//                                           // SharePDFView(pdfURL: doc.pdfDocumentUrl,width: system.fullWidth*0.2)
//                                        },
                                        .destructive(Text("Delete Supplement and its History")) {
        //                                        deleteTestRecord()
                                            //system.medicalDocuments
                                            //system.deleteDocument(document: doc)
                                            BMSupplementStackGL.removeSupplement(supplement)
                                            BiomarkerFileSystem.saveSystemMedicalDocuments()
                                            self.showSelf.toggle()
                                        },
                                        .cancel()
                                    ]
                                )
                            }
//                            .sheet(isPresented: $isSharePresented) {
//                                ShareSheet(activityItems: [doc.pdfDocumentUrl])
//                            }
                        }
                        
                    }
                    
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
    
    func analyseSupplementWithLLM(){
        
        if analysisInProgress{
            print("Cannot request a supplement analysis as the last one is in progress")
            return
        }
        analysisInProgress = true
        isAnimating = true
        
        
        UserHealthContext.analyzeSupplementWithLLM(supplement) { success, response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                //putting thing in here because we do not want abrupt stops in animation in case completion handler gets called very quicky
                //side effect is that we will show anlaying with biomarker for a few moments longer, but its fine
                isAnimating = false
                analysisInProgress = false
            })
            
            
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



struct SupplementHistoryView: View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL // Ensure this is an instance
    @Binding var showSelf: Bool
    var supplement: BMSupplement

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                //left to right chart from oldes to newest
                SupplementChartViewContainer(supplement: supplement)
                

                    VStack(alignment: .leading, spacing: 0) { // No spacing to connect items visually
                        // Assuming bmSupplementStackGL.supplements is an array of BMSupplement
                        let historyList = SupplementHistoryView.getHistoryList(supplement: supplement)
                        ForEach(historyList, id: \.id) { supp in
                            VStack{
                            SupplementRow(supplement: supp, showDateOfCreation: true, useHistoryViewMode: true,showImg: true)
                            
//                            if(supp.id == supplement.id){
//                                Text("Latest")
//                                    .multilineTextAlignment(.leading)
//                                    .font(.caption)
//                                    .fontWeight(.bold)
//                                    .padding(.vertical,5)
//                                    .padding(.horizontal,5)
//                                    .background(Color.pink)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                                    .padding(.horizontal,3)
//                                    //.padding(.bottom,3)
//                            }
                        }
                              //  .padding(.vertical, 5) // Add some vertical padding for spacing
                            Divider().padding([.horizontal,.bottom])
                            
                        }
                    }
                
                .navigationTitle("Change History")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
    
    static func getHistoryList(supplement: BMSupplement) -> [BMSupplement] {
        // Sorting history objects by date - latest at top
        var res = supplement.history.sorted(by: { $0.createdAt > $1.createdAt })
        res.insert(supplement, at: 0) // We know the current version is the latest one, so putting it at the top
        return res
    }
}


struct SupplementChartViewContainer: View {
    @ObservedObject var bmSupplementStackGL = BMSupplementStackGL
    var supplement: BMSupplement
    var body: some View {
        VStack{
            SupplementDetailView.aiInfoView(header: "Variation of dosage", description: "See how you dosage has varied across time for \(supplement.name)")
                .padding([.leading])
            SupplementChartView(supplements: SupplementHistoryView.getHistoryList(supplement: supplement).reversed())
                .padding([.horizontal,.bottom])
        }
    }
}

struct SupplementChartView: View {
    let supplements: [BMSupplement]
    var lineWidth: CGFloat = 10.0  // Customizable line width

    var segmentedData: [(startDate: Date, endDate: Date, dosageStrength: Double)] {
        let sorted = supplements.sorted { $0.createdAt < $1.createdAt }
        var result: [(startDate: Date, endDate: Date, dosageStrength: Double)] = []

        for i in 0..<sorted.count - 1 {
            result.append((startDate: sorted[i].createdAt,
                           endDate: sorted[i + 1].createdAt,
                           dosageStrength: Double(sorted[i].strengthNumber) ?? 0))
        }
        
        // Ensure the last supplement is plotted up to "now"
        if let last = sorted.last {
            result.append((startDate: last.createdAt,
                           endDate: Date(), // Extend to current date
                           dosageStrength: Double(last.strengthNumber) ?? 0))
        }
        
        return result
    }

    var body: some View {
        Chart {
            ForEach(segmentedData, id: \.startDate) { segment in
                LineMark(
                    x: .value("Date", segment.startDate),
                    y: .value("Dosage", segment.dosageStrength)
                )
                .lineStyle(StrokeStyle(lineWidth: lineWidth,lineCap: .round)) // Custom line width
                .foregroundStyle(.pink)

                LineMark(
                    x: .value("Date", segment.endDate),
                    y: .value("Dosage", segment.dosageStrength)
                )
                .lineStyle(StrokeStyle(lineWidth: lineWidth,lineCap: .round)) // Custom line width
                .foregroundStyle(.pink)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: supplements.count>1 ? 200 : 150)
        .padding()
    }
}
