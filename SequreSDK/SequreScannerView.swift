//
//  SequreCameraView.swift
//  Sequre
//
//  Created by Kazao TM on 24/05/23.
//

import SwiftUI

public struct SequreScannerView: View {
 
    let cameraService = SequreCameraService()
    @Environment(\.presentationMode) private var presentationMode
    @Binding var result: SequreResult
    @State var isTorchOn: Bool = false
    @State var onEventColor: Color = Color.white
    @State var onEventMessage: String = ""
    @State var onEventDebug: String = ""
    @State var zoomLevel: CGFloat = 4
    
    public init(result: Binding<SequreResult>) {
        self._result = result
    }
    
    
    public var body: some View {
        ZStack {
            GeometryReader { geometry in
                Group {
                    let screenSize = geometry.size
                    let height = screenSize.width / (3 / 4)
                    let margin = (screenSize.height - height) / 2
                    let result = SequreResult()
                    SequreCameraView(cameraService: cameraService) { result in
                        if let error = result.error {
                            print(error.localizedDescription)
                            return
                        }
                        cameraService.stop()
                        if let data = result.image {
//                            self.capturedImage = UIImage(cgImage: data)
//                            if let image = result.image {
//                                self.labelImage = UIImage(cgImage: image)
//                            }
                            self.result.qr = result.qr
                            self.result.genuine = result.genuine
                            self.result.score = result.score
                            self.presentationMode.wrappedValue.dismiss()
                            //                            NSLog("self.qrcode: \(self.qrcode)");
                            if result.genuine ?? false {
                                self.result.label = "original"
//                                API.scanQr(parameters: ["qrcode": self.qrcode ?? "", "score": self.score, "scanResult": result]) { response in
//                                    NSLog("response: \(response)")
//                                    self.data = response
//                                    contentView.load()
//                                }
                            } else {
                                if (result.label == nil || result.label == "" ? "-" : result.label) == "-" {
                                    self.result.label = "poor_image_quality"
                                }
//                                API.scanLog(parameters: ["qrcode": self.qrcode ?? "", "score": self.score, "scanResult": result]) { response in
//                                    NSLog("response: \(response)")
//                                    contentView.load()
//                                }
                            }
                        } else {
                            print("No image found")
                            self.result.label = "Fake"
                            self.result.genuine = false
                            self.result.score = 0.0001
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } onEvent: { color, message, debug in
                        NSLog("onEvent: \(message)")
                        onEventColor = color
                        onEventMessage = message
                        onEventDebug = debug
                    }
                    .padding(.top, margin)
                    .padding(.bottom, margin)
                }
                .edgesIgnoringSafeArea(.all)
                ZStack {
                    Group {
                        let screenSize = geometry.size
                        let ratio = 2.0 / 4.0
                        let percentage = 0.6
                        let width = screenSize.width * percentage
                        let height = width / ratio
                        let vertical = screenSize.height - ((screenSize.height - height) / 2)
                        let horizontal = screenSize.width - ((screenSize.width - width) / 2)
                        Group {
                            Rectangle()
                                .fill(Color("clr_preview_background"))
                                .padding(.bottom, vertical)
                            Rectangle()
                                .fill(Color("clr_preview_background"))
                                .padding(.top, vertical)
                            Rectangle()
                                .fill(Color("clr_preview_background"))
                                .padding(.leading, horizontal)
                                .padding(.vertical, vertical - height + geometry.safeAreaInsets.bottom)
                            Rectangle()
                                .fill(Color("clr_preview_background"))
                                .padding(.trailing, horizontal)
                                .padding(.vertical, vertical - height + geometry.safeAreaInsets.bottom)
                        }
                        ZStack {
                            HStack {
                                VStack {
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 6, height: 40)
                                    Spacer()
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 6, height: 40)
                                }
                                Spacer()
                                VStack {
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 6, height: 40)
                                    Spacer()
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 6, height: 40)
                                }
                            }
                            VStack {
                                HStack {
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 40, height: 6)
                                    Spacer()
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 40, height: 6)
                                }
                                Spacer()
                                HStack {
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 40, height: 6)
                                    Spacer()
                                    Rectangle()
                                        .fill(onEventColor)
                                        .frame(width: 40, height: 6)
                                }
                            }
                        }
                        .padding(.vertical, vertical - height + geometry.safeAreaInsets.bottom - 3)
                        .padding(.horizontal, horizontal - width - 3)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Text("Posisikan QR ke dalam Area")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.top, 70)
                Text("Scaning akan dimulai otomatis")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                Spacer()
                Text(onEventMessage)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(onEventColor)
                    .padding(.bottom, 70)
            }
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.white)
                            .padding()
                            .onTapGesture {
                                cameraService.stop()
                                presentationMode.wrappedValue.dismiss()
                            }
                        Spacer()
//                        Image(systemName: isTorchOn ? "bolt.fill" : "bolt.slash.fill")
//                            .foregroundColor(Color.white)
//                            .padding()
//                            .onTapGesture {
//                                isTorchOn.toggle()
//                                UserDefaults.standard.set(isTorchOn, forKey: "torch")
//                                cameraService.torch(isOn: isTorchOn)
//                            }
                    }
                    .padding([.leading, .trailing])
                }
                .background(Color.clr_black2)
                Spacer()
            }
        }
        .background(Color("clr_preview_background"))
        .onAppear() {
            print("onAppear")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                if UserDefaults.standard.object(forKey: "torch") == nil {
//                    UserDefaults.standard.set(true, forKey: "torch")
//                }
//                isTorchOn = UserDefaults.standard.bool(forKey: "torch")
//                cameraService.torch(isOn: isTorchOn)
//                zoomLevel = CGFloat(UserDefaults.standard.float(forKey: "zoom"));
//                if zoomLevel < 1 {
//                    zoomLevel = 1
//                }
//                cameraService.setZoom(level: 4)
            }
        }
    }
    
}
