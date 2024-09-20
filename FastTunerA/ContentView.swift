//
//  ContentView.swift
//  tunerApp
//
//  Created by nakamori.emiri on 2024/09/17.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @AppStorage("tab") var tab = Tab.home
    @State var isBeating = false
    @State private var audioPlayer: AVAudioPlayer?
    @AppStorage("isPause") private var isPause = false
    @AppStorage("volume") private var volume: Double = 1.0

    var body: some View {
        ZStack {
            TabView(selection: $tab) {
                
                VStack(spacing: 0) {
                    Text("442hz")
                        .padding()
                        .foregroundColor(.black)
                    Image("music")
                        .scaleEffect(isBeating ? 1.5 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(), value: isBeating)
                        .onAppear { isBeating = true }
                    
                    Button {
                        isPause.toggle()
                        if isPause {
                            audioPlayer?.pause()
                        } else {
                            playAudio()
                        }
                    } label: {
                        Image(isPause ? "play": "pause")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(volume) },
                        set: { newValue in
                            volume = Double(newValue)
                            audioPlayer?.setVolume(Float(volume), fadeDuration: 0.0)
                        }
                    ), in: 0...1)
                    .padding()
                    .accentColor(.blue)

                }
                .font(.largeTitle)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if !isPause {
                        playAudio()
                    }
                }

                VStack {
                    List {
                        Section(header: Text(LocalizedStringKey("About"))) {
                            
                            HStack {
                                Image("book")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.green)
                                Text(LocalizedStringKey("Terms Of Service"))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            }
                            .onTapGesture {
                                openTermsURL()
                            }
                            
                            HStack {
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.blue)
                                Text(LocalizedStringKey("Privacy Policy"))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            }
                            .onTapGesture {
                                openPrivacyPolicyURL()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
        }
        .onAppear {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set audio session category: \(error)")
            }
        }
    }
    
    func playAudio() {
        guard let soundFile = NSDataAsset(name: "442") else {
            return
        }
        audioPlayer = try? AVAudioPlayer(data: soundFile.data, fileTypeHint: "wav")
        audioPlayer?.play()
        audioPlayer?.numberOfLoops = -1
    }
    
    func openPrivacyPolicyURL() {
        Task {
            let url = URL(string: "https://doc-hosting.flycricket.io/tunera-privacy-policy/da58ad16-59bb-4be5-a3c3-82d46e3c1d84/privacy")!
            await UIApplication.shared.open(url)
        }
    }
    
    func openTermsURL() {
        Task {
            let url = URL(string: "https://doc-hosting.flycricket.io/tunera-terms-of-use/3262f52a-69b7-4ca0-ad29-be5abe7aa237/terms")!
            await UIApplication.shared.open(url)
        }
    }
}

enum Tab : String, Hashable {
    case home, settings
}


#Preview {
    ContentView()
}
