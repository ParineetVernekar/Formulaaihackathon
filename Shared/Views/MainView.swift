//
//  Sessions.swift
//  F1 mac app
//
//  Created by Bogdan Farca on 23.09.2021.
//

import SwiftUI

struct MainView: View {
    @StateObject var dataModel = SessionsDataModel()
    @StateObject var appModel = AppModel.shared
    
    
    var body: some View {
        NavigationView {
            if appModel.appState == .loadingSessions {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                TabView {
                    VStack{
                HStack{
                    Button { dataModel.loadSessions() }
                label: { Image(systemName: "arrow.clockwise").font(.system(size: 20)) }
                    Spacer()

                    Menu("Sort") {
                        Button {
                            dataModel.sessions.sort(by: { $0.sessionLength < $1.sessionLength})
                        } label: {
                            Text("By time")
                        }
                        
                        Button {
                            dataModel.sessions.sort(by: { $0.laps < $1.laps})
                        } label: {
                            Text("By laps")
                        }
                        
                        Button {
                            dataModel.sessions.sort(by: { $0.sessionTime < $1.sessionTime})
                        } label: {
                            Text("By date")
                        }
                           
                    }
                }
                .padding(.horizontal,20)
                renderSessionsList()
                    }
                        .navigationTitle("View Cars")
                        .tabItem {Label("Improve", systemImage: "hare") }.tag(1)

                    ReplayView(dataModel: dataModel).navigationTitle("Cars").tabItem { Label("Replay", systemImage: "play") }.tag(2)
                    
                    CarARView().tabItem { Label("Cars", systemImage: "car") }.tag(2)
                }
               
            }
    
            renderMessage()
                .font(.headline)
                .foregroundColor(.gray)
        }.onAppear {
            if #available(iOS 13.0, *) {
                let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                tabBarAppearance.backgroundColor = UIColor(named: "tabColor")
                UITabBar.appearance().standardAppearance = tabBarAppearance

                let navigationBarAppearance: UINavigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithDefaultBackground()
                navigationBarAppearance.backgroundColor = UIColor(named: "tabColor")
                UINavigationBar.appearance().standardAppearance = navigationBarAppearance
                
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderMessage() -> some View {
        switch appModel.appState {
            case .loadingSessions:
                VStack(spacing: 10) {
                    Image(systemName: "cloud")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .opacity(0.5)
                    
                    Text("Loading sessions from Oracle Cloud")
                }
                
            case .waitToLoadTrack:
                VStack(spacing: 10) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .opacity(0.5)
                    
                    Text("Select your session from the left pane")
                }
                
            case let .error(msg):
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .opacity(0.5)
                    
                    Text("Error: \(msg)")
                }
            default: EmptyView()
        }
    }
    
    @ViewBuilder
    private func renderSessionsList() -> some View {
        List {
            ForEach( dataModel.sessions.sorted(by: { $0.sessionTime > $1.sessionTime}), id: \.mSessionid) { session in
                renderSessionRow(session)
            }
        }
        .refreshable {
            dataModel.loadSessions()
                   }
        .listStyle(SidebarListStyle())
    }
    
    @ViewBuilder
    private func renderSessionRow(_ session: Session) -> some View {
        NavigationLink(destination: LapReplayView(session: session)) {
            VStack(alignment: .leading) {
                Text("Session by \(session.driver)")
                    .font(.system(size: 20))
                Group {
                    HStack{
                        Image(systemName: "calendar")
                        Text("\(session.sessionTimeMeasurement)")
                    }
                    HStack{
                        Image(systemName: "clock")
                        Text("\(session.sessionLengthString)")
                    }
                    HStack{
                        Image(systemName: "arrow.clockwise")
                        Text("\(session.lapsString)")
                    }

                }
                .font(.system(size: 16, weight: .light))
                .padding(.vertical, 2)
                .opacity(0.7)
            }
        }
    }
}

struct ReplayView : View{
    @StateObject var dataModel : SessionsDataModel
    @StateObject var appModel = AppModel.shared
    var items: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 90)), count: 2)
    }

    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            HStack{
                Button { dataModel.loadSessions() }
            label: { Image(systemName: "arrow.clockwise").font(.system(size: 20)) }
                Spacer()

                Menu("Sort") {
                    Button {
                        dataModel.sessions.sort(by: { $0.sessionLength < $1.sessionLength})
                    } label: {
                        Text("By time")
                    }
                    
                    Button {
                        dataModel.sessions.sort(by: { $0.laps < $1.laps})
                    } label: {
                        Text("By laps")
                    }
                    
                    Button {
                        dataModel.sessions.sort(by: { $0.sessionTime < $1.sessionTime})
                    } label: {
                        Text("By date")
                    }
                       
                }
            }
            .padding(.horizontal,20)
            .padding(.bottom, 10)
            LazyVGrid(columns: items, spacing: 15) {
                ForEach(dataModel.sessions, id: \.mSessionid) { session in
                    NavigationLink(destination: LapReplayView(session: session)) {
                        VStack{
                        Image("\(session.imageName)")
                            .resizable()
                            .aspectRatio(1.65, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        Text("\(session.sessionTimeMeasurement)")
                                .font(.headline)
                        Text("by \(session.driver)")
                                .font(.subheadline)
                    }
                        .foregroundColor(Color.init(uiColor: UIColor(named: "textColor") ?? UIColor.black))
                    
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.init(uiColor: UIColor(named: "cellColor") ?? UIColor.white))
                        
                )
                    }
                }
            }
            .padding(.horizontal)
        }.background(Color.init(uiColor: UIColor(named: "backgroundColor") ?? UIColor.white))
        

    }
}

struct CarARView : View{
    let thecars = cars
    var body: some View{
        List{
        ForEach(thecars){ car in
            NavigationLink(destination: SingleCarView(car: car.imageName, carModel: car)) {

            HStack{
                VStack(alignment:.leading){
                    Text("\(car.name)")
                        .font(.title2)
                    Text("\(car.maker)")
                        .font(.callout)
                    Text(car.year)
                        .font(.callout)

                }
                Spacer()
                Image(car.imageName)
                    .resizable()
                    .aspectRatio(1.65, contentMode: .fill)
                    .frame(width: 150, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.vertical)
            }
            }
            
        }
//        .background(Color.init(red: 242/255, green: 241/255, blue: 246/255))
        }.navigationBarTitle(Text("Cars"))
    }
}


struct Sessions_Previews: PreviewProvider {
    static var previews: some View {
        ReplayView(dataModel: SessionsDataModel())
    }
}
