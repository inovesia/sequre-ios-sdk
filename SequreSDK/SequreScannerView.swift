//
//  SequreCameraView.swift
//  Sequre
//
//  Created by Kazao TM on 24/05/23.
//

import SwiftUI

public struct SequreScannerView: View {
    @AppStorage("language")
    private var language = LocalizationService.shared.language
    let cameraService = SequreCameraService()
    @Environment(\.presentationMode) private var presentationMode
    @State var isTorchOn: Bool = false
    @State var onEventColor: Color = Color.white
    @State var onEventMessage: String = ""
    @State var onEventDebug: String = ""
    @State var zoomLevel: CGFloat = SequreConfig.zoomLevel
    @State var cameraViewTopPos: CGFloat = 0
    
    var resultCallback: SequreResultCallback
    public init(resultCallback: SequreResultCallback) {
        self.resultCallback = resultCallback
    }
    
    
    public var body: some View {
        ZStack {
            GeometryReader { geometry in
                Group {
                    let screenSize = geometry.size
                    let height = screenSize.width / (3 / 4)
                    let margin = (screenSize.height - height) / 2
                    let navBarHeight = (48 + statusBarHeight()) / 2
                    // Camera view
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
                            //                            NSLog("self.qrcode: \(self.qrcode)");
                            if result.genuine ?? false {
//                                self.result.label = "original"
                            } else {
                                if (result.label == nil || result.label == "" ? "-" : result.label) == "-" {
//                                    result.label = "poor_image_quality"
                                }
                            }
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            print("No image found")
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        resultCallback.onResult(result: result)
                    } onEvent: { color, message, debug in
                        onEventColor = color
                        onEventMessage = message
                        onEventDebug = debug
                    }
                    .onAppear(perform: {
                        cameraViewTopPos = margin + navBarHeight
                    })
                    .padding(.top, margin + navBarHeight)
                    .padding(.bottom, margin - navBarHeight)
                }
                .edgesIgnoringSafeArea(.all)
                ZStack {
                    Group {
                        let screenSize = geometry.size
                        let ratio = 1.0 / 2.0
                        let percentage = 0.7
                        let width = screenSize.width * percentage
                        let height = width / ratio
                        let vertical = screenSize.height - ((screenSize.height - height) / 2)
                        let horizontal = screenSize.width - ((screenSize.width - width) / 2)
                        let navBarHeight = (48 + statusBarHeight()) / 2
                        // Black transparent background views
                        Group {
                            Rectangle()
                                .fill(Color.clr_preview_background)
                                .padding(.bottom, vertical - statusBarHeight() - navBarHeight)
                            Rectangle()
                                .fill(Color.clr_preview_background)
                                .padding(.top, vertical - statusBarHeight() + navBarHeight)
                            Rectangle()
                                .fill(Color.clr_preview_background)
                                .padding(.leading, horizontal)
                                .padding(.top, vertical - height + geometry.safeAreaInsets.bottom + statusBarHeight() + navBarHeight)
                                .padding(.bottom, vertical - height + geometry.safeAreaInsets.bottom + statusBarHeight() - navBarHeight)
                            Rectangle()
                                .fill(Color.clr_preview_background)
                                .padding(.trailing, horizontal)
                                .padding(.top, vertical - height + geometry.safeAreaInsets.bottom + statusBarHeight() + navBarHeight)
                                .padding(.bottom, vertical - height + geometry.safeAreaInsets.bottom + statusBarHeight() - navBarHeight)
                        }
                        
                        // White frame views
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
                        .padding(.top, vertical - height + geometry.safeAreaInsets.bottom - 3 + statusBarHeight() + navBarHeight)
                        .padding(.bottom, vertical - height + geometry.safeAreaInsets.bottom - 3 + statusBarHeight() - navBarHeight)
                        .padding(.horizontal, horizontal - width - 3)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Text("Adjust QR to the area".localized(language))
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.top, cameraViewTopPos - 37 - 10)
                Text("Scanning will begin automatically".localized(language))
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                Spacer()
                let x = print("Scanning will begin automatically".localized(language))
            }
            if (onEventMessage != "") {
                let x = print(onEventMessage.localized(language))
                VStack {
                    Spacer()
                    HStack {
                        Text(onEventMessage.localized(language))
                            .font(.system(size: 24, weight: .bold))
                        //                    .foregroundColor(onEventColor)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.clr_orange)
                    .cornerRadius(20)
                    Spacer()
                }
            }
            VStack {
                HStack {
                    HStack {
                        Button(action: {
                            cameraService.stop()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image("ic-back", bundle: Bundle(for: SequreCameraService.self))
                                .foregroundColor(Color.white)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
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
                    .padding(.top, statusBarHeight())
                }
                .background(Color.clr_black2)
                Spacer()
            }
        }
        .background(Color.clr_preview_background)
//        .onAppear() {
//            print("onAppear")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
////                if UserDefaults.standard.object(forKey: "torch") == nil {
////                    UserDefaults.standard.set(true, forKey: "torch")
////                }
////                isTorchOn = UserDefaults.standard.bool(forKey: "torch")
////                cameraService.torch(isOn: isTorchOn)
////                zoomLevel = CGFloat(UserDefaults.standard.float(forKey: "zoom"));
////                if zoomLevel < 1 {
////                    zoomLevel = 1
////                }
////                cameraService.setZoom(level: 4)
//            }
//        }
    }
    
    func statusBarHeight() -> CGFloat {
        guard let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first else { return 0 }
        let statusBarFrame = window.windowScene?.statusBarManager?.statusBarFrame
        return statusBarFrame?.height ?? 0
    }
}
