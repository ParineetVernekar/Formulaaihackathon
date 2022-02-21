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
//                TabView {
                HStack{
                    Button { dataModel.loadSessions() }
                label: { Image(systemName: "arrow.clockwise.circle").font(.system(size: 20)) }
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
                       
                        .navigationTitle("Drive sessions")

                
//                        .tabItem {Label("View races", systemImage: "hare") }.tag(1)
//
//                    Text("Tab Content 2").navigationTitle("Cars").tabItem { Label("View Cars", systemImage: "car") }.tag(2)
//                }
               
            }
    
            renderMessage()
                .font(.headline)
                .foregroundColor(.gray)
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

struct Sessions_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
