//
//  MemoView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/10/24.
//

import SwiftUI
import MapKit



@available(iOS 17.0, *)
struct MemoView: View {
    
    // 사용자 위치 값 가져오기
    @ObservedObject var locationsHandler = LocationsHandler.shared
    
    // 카메라 위치추적 변수 사용자를 추적
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    @State var memoTitle: String = ""
    @State var memoContents: String = ""
    
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
                        HStack(spacing: 200) {
                            Text("사진 등록하기")
                                .font(.title3)
                                .bold()
                            Button {
                                // Action
                                
                            } label: {
                                Text("나만보기")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(Color(.blue))
                            }
                            
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
                            .font(.title3)
                            .bold()
                        
                        TextField("제목을 입력해주세요", text: $memoTitle)
                            .textFieldStyle(.roundedBorder)
                        
                        // TexEditor 여러줄 - 긴글 의 text 를 입력할때 사용
                        TextEditor(text: $memoContents)
                            .frame(height: 250)
                            .cornerRadius(10)
                            .colorMultiply(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
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
        MemoView()
    }
}
#endif

