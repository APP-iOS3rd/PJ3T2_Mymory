//
//  MemoView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/10/24.
//

import SwiftUI
import MapKit
import Combine


// 💁 사용자 위치추적 및 권한허용 싱글톤 구현 위치 임시지정
@MainActor class LocationsHandler: ObservableObject {
    
    static let shared = LocationsHandler()
    public let manager: CLLocationManager
    
    init() {
        self.manager = CLLocationManager()
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
}


@available(iOS 17.0, *)
struct PostView: View {
    
    // 사용자 위치 값 가져오기
    @ObservedObject var locationsHandler = LocationsHandler.shared
    
    // 카메라 위치추적 변수 사용자를 추적
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    @State var memoTitle: String = ""
    @State var memoContents: String = ""
    
    let minHeight: CGFloat = 250
    let maxHeight: CGFloat = 400
    let maxCharacterCount: Int = 1000
    
    // property
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                
                //💁 상단 MapView
                Map(position: $position){
                    UserAnnotation()
                }
                .frame(height: UIScreen.main.bounds.size.height * 0.2) // 화면 높이의 30%로 설정
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .background(.ultraThinMaterial)
                .padding(.bottom)
                
                //💁 사진 등록하기 View
                Group {
                    VStack(alignment: .leading, spacing: 10){
                        HStack {
                            Text("사진 등록하기")
                                .font(.bold20)
                            
                            Spacer()
                            
                        } //:HSTACK
                        SelectPhotos()
                    }//:VSTACK
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                
                // 💁 주소찾기 View
                Group {
                    FindAddressView()
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // 💁 메모하기 View 굳이 분리할 필요가 없어 보임
                Group {
                    VStack(alignment: .leading, spacing: 10){
                        Text("제목, 기록할 메모 입력")
                            .font(.bold20)
                            .bold()
                        
                        TextField("제목을 입력해주세요", text: $memoTitle)
                            .textFieldStyle(.roundedBorder)
                        
                        // TexEditor 여러줄 - 긴글 의 text 를 입력할때 사용
                        TextEditor(text: $memoContents)
                            .frame(minHeight: minHeight, maxHeight: maxHeight)
                            .cornerRadius(10)
                            .colorMultiply(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                        // 최대 1000자 까지만 허용
                            .onChange(of: memoContents) { newValue in
                                // Limit text input to maxCharacterCount
                                if newValue.count > maxCharacterCount {
                                    memoContents = String(newValue.prefix(maxCharacterCount))
                                }
                            }// Just는 Combine 프레임워크에서 제공하는 publisher 중 하나이며, SwiftUI에서 특정 이벤트에 반응하거나 값을 수신하기 위해 사용됩니다. 1000를 넘으면 입력을 더이상 할 수 없습니다.
                            .onReceive(Just(memoContents)) { _ in
                                // Disable further input if the character count exceeds maxCharacterCount
                                if memoContents.count > maxCharacterCount {
                                    memoContents = String(memoContents.prefix(maxCharacterCount))
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // 💁 Tag 선택 View
                Group {
                    SelectTagView()
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Button(action: {
                    // 임시로 로직 구현전 뒤로가기
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("작성완료")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                
                Spacer()
            } //:VSTACK
            
        } //: ScrollView
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            // 뒤로 가기 동작을 구현합니다
            // 예: PresentationMode를 사용하여 화면을 닫습니다
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
        })
    }
    
}

#if DEBUG
@available(iOS 17.0, *)
struct MemoView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
#endif
