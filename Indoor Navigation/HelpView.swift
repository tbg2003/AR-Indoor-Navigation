//
//  HelpView.swift
//  Indoor Navigation
//
//  Created by Rosie Gomez on 17/02/2023.
//

import Foundation
import SwiftUI

struct HelpView: View{
   @State  private var currentIndex = 0
    let images: [String] = ["logo", "AppIcon"]
    
    var body: some View{
        VStack{
            Image(images[currentIndex])
                .resizable()
                .scaledToFit()
            HStack{
                ForEach(0..<images.count){index in
                    Circle()
                        .fill(self.currentIndex == index ? Color.red :
                                Color.brown)
                        .frame(width: 10, height: 10)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear{
            print("Appear")
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true){timer in
                if self.currentIndex + 1 == self.images.count{
                    self.currentIndex = 0
                }else{
                    self.currentIndex += 1
                }
            }
        }
    }
}

//struct HelpView_Previews: PreviewProvider{
 //   static var previews: some View{
   //     HelpView()
    //}
//}
