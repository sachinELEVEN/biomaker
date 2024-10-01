//
//  IndependentUI.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

//
//  independentUI.swift
//  eleutheria_app
//
//  Created by sachin jeph on 12/06/22.
//

import Foundation
import SwiftUI

struct bgDepthEffect: ViewModifier {
    var color : Color = Color.init("appdefaultbgcolor")
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(self.color)
            .cornerRadius(20, antialiased: true)
            .shadow(color: Color.secondary.opacity(0.1), radius: 2)
            .shadow(color: Color.primary.opacity(0.2), radius: 2)
        
        // .padding()
    }
}

struct bgSolid: ViewModifier {
    var color : Color = Color.init("appdefaultbgcolor")
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(self.color)
            .cornerRadius(20, antialiased: true)
            //.shadow(color: Color.secondary.opacity(0.1), radius: 2)
            //.shadow(color: Color.primary.opacity(0.2), radius: 2)
        
        // .padding()
    }
}

struct CustomBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

func label(_ text : String,textColor : Color = Color.secondary, bgColor : Color = Color.secondary.opacity(0.15) , imgName : String = "", imgColor : Color = .primary, width : CGFloat = 300, radius: CGFloat = 10, font: Font = Font.headline, fontWeight: Font.Weight = .bold, alignment : Alignment = .center)->some View{
    return HStack{
        
        if alignment == .center {
           view()
            
        }else if alignment == .leading{
            
           view()
                .padding(.leading,5)
            Spacer()
            
        }else if alignment == .trailing{
            
            
        Spacer()
            view()
                .padding(.trailing,5)
        }
        
        
        
    }
    .frame(width:width)
    .padding()
    .background(bgColor)
    .cornerRadius(radius)
   // .padding(.top,5)
    
    func view()-> some View{
        return HStack{
            if imgName != ""{
                
                imageView(systemName: imgName,color: imgColor)
                    //.foregroundColor(textColor)
            }
            Text(text)
                .fontWeight(fontWeight)
                .font(font)
                .foregroundColor(textColor)
        }
    }
}


func imageView(systemName : String,color : Color = Color.primaryInvert.opacity(0.4), size : CGFloat = 25)->some View{
    return   VStack{
        Image(systemName  : systemName)
        //.resizable()
            .font(.system(size: size))
            .foregroundColor(color)
            
    }
}

func customImageView(imgName : String,color : Color = .orange, size : CGFloat = 25)->some View{
    return   VStack{
        Image(uiImage: UIImage(named: imgName)!)
            .font(.system(size: size))
            
           
            .foregroundColor(color)
            
    }
}

func profileImageView(image: UIImage, size : CGFloat = 40)->some View{
    return   VStack{
        Image(uiImage : image)
            .renderingMode(.original)
            .resizable()
            .frame(width:size,height:size)
            .clipShape(Circle())
    }
}

struct ThickDivider: View{
    var body: some View{
        Divider()
               // .frame(minHeight: 9)
               // .cornerRadius(20)
               // .background(Color.gray.opacity(0.1))
                .padding()

    }
}

struct ActivityIndicator: UIViewRepresentable {
    // Code will go here
    @Binding var shouldAnimate: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        // Create UIActivityIndicatorView
        return UIActivityIndicatorView()
    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        // Start and stop UIActivityIndicatorView animation
        if self.shouldAnimate {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

import UIKit

func randomColor() -> UIColor {
    let red = CGFloat.random(in: 0...1)
    let green = CGFloat.random(in: 0...1)
    let blue = CGFloat.random(in: 0...1)
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}

func generateRandomGradientImage(size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    defer { UIGraphicsEndImageContext() }
    
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    
    let gradientColors: [CGColor] = [randomColor().cgColor, randomColor().cgColor]
    let gradientLocations: [CGFloat] = [0.0, 1.0]
    
    if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: gradientLocations) {
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: size.width, y: size.height)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
        if let gradientImage = UIGraphicsGetImageFromCurrentImageContext() {
            return gradientImage
        }
    }
    
    return nil
}

//generic view which can be used by anyone to input custom text
struct EnterTextView: View{
    @Binding var showSelf : Bool
    @Binding var text : String
    var title : String
    var placeHolder : String
    var imgName : String
    var description : String
    var buttonTitle : String = "Save"
    var buttonImgName: String = "checkmark"
    var action : () -> ()
    
    var body: some View{
        
        ScrollView(showsIndicators: false){
            
            
            
            
            if true{
                
                VStack{
                   
                    
                    
                    HStack{
                        imageView(systemName: imgName, color: .primary, size: 40)
                        
                        Text(TextLocalisation.getLocalisedString(title))
                            .fontWeight(.heavy)
                            .font(.largeTitle)
                        Spacer()
                        
                        
                        
                    }.padding()
                    /*
                    HStack{Spacer()
                    Button(action :{
                        //save contact
                        
                        // showContactAddingView.toggle()
                        self.showSelf = false
                        
                    }){
                        label(TextLocalisation.getLocalisedString("Close"), textColor: .white, bgColor: .red, imgName: "x.circle.fill", imgColor: .white, width: 200)
                        
                    }
                }
                 */
                } .padding()
                   // .padding(.top,20)
                
            }else{
                
                HStack{
                    HStack{
                        imageView(systemName: imgName, color: .primary, size: 40)
                        
                        Text(TextLocalisation.getLocalisedString(title))
                            .fontWeight(.heavy)
                            .font(.largeTitle)
                        Spacer()
                        
                    }.padding()
                    Spacer()
                    Button(action :{
                        //save contact
                        
                        // showContactAddingView.toggle()
                        self.showSelf = false
                        
                    }){
                        label(TextLocalisation.getLocalisedString("Close"), textColor: .white, bgColor: .red, imgName: "x.circle.fill", imgColor: .white, width: 200)
                        
                    }
                    
                    Spacer()
                } .padding()
                    .padding(.top,20)
            }
      
            
            //Your Name
            
            
            
            Text(TextLocalisation.getLocalisedString(description))
                .fontWeight(.regular)
                .padding()
                .foregroundStyle(.secondary)
            
            
            //Self Name adding screen
            TextField(TextLocalisation.getLocalisedString(placeHolder), text: $text, onEditingChanged:{ isEditing in
            }, onCommit: {
                UIApplication.shared.endEditing()
            })
            .onChange(of: text) { newValue in
            }
            .frame(height: 30)
            .modifier(TextFieldNeumorphicModifier(text:$text,isTyping: .constant(false), imageName: "person.text.rectangle"))
            
            
            HStack{
                
                Button(action :{
                    //save name changes
                    if isTextName(text) {
                        UIApplication.shared.endEditing()
                        print("/EnterTextView -> execution action")
                        action()
                        showSelf = false
                    }
                    
                }){
                    label(TextLocalisation.getLocalisedString(buttonTitle), textColor: .white, bgColor: isTextName(text) ? .blue : .secondary, imgName: buttonImgName, imgColor: .white, width: 200)
                    
                }
                
                Spacer()
            } .padding()
                .padding(.bottom,20)
            
            
        }
        
        
    }
    
    private func isTextName(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        return !trimmedName.isEmpty
    }
}


//
//  TextFieldView.swift
//  MapSearch
//
//  Created by sachin jeph on 14/06/22.
//

import Foundation
import SwiftUI

struct TextFieldNeumorphicModifier: ViewModifier {
    @Binding var text : String
    @Binding var isTyping : Bool
        var imageName: String
        
    
    func body(content: Content) -> some View {
       
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(.darkShadow)
                
                content
                    .foregroundColor(.darkShadow)
                
                if text != ""{
                Button(action:{
                    text = ""
                    UIApplication.shared.endEditing()
                }){
                    Image(systemName : "x.circle.fill")
                        .font(.headline)
                        .foregroundColor(.secondary.opacity(0.15))
                }
                }
                    
              
                }
                .padding()
                .foregroundColor(.neumorphictextColor)
                .background(CustomBlur(style: .prominent))
                .cornerRadius(10)
                //.shadow(color: Color.darkShadow, radius: 3, x: 2, y: 2)
                //.shadow(color: Color.lightShadow, radius: 3, x: -2, y: -2)
                .padding()
                
            
           
    }
}



extension Color {
    static let lightShadow = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color(red: 224 / 255, green: 229 / 255, blue: 236 / 255)
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
    static let dashboardM3OrangeBar = Color(rgbaRed: 254, green: 90, blue: 7, alpha: 255)
    static let dashboardM3OrangeTicks = Color(rgbaRed: 75, green: 36, blue: 22, alpha: 255)
}

extension Color {
    /// Initialize a Color with an RGBA value
    /// - Parameters:
    ///   - red: Red component (0-255)
    ///   - green: Green component (0-255)
    ///   - blue: Blue component (0-255)
    ///   - alpha: Alpha component (0-255)
    init(rgbaRed red: Int, green: Int, blue: Int, alpha: Int = 255) {
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}


