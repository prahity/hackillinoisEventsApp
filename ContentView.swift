//
//  ContentView.swift
//  HackIllinoisApp
//
//  Created by Prahit Yaugand on 9/15/24.
//

import SwiftUI

struct EventResponse : Codable {
    let events : [Event]
}

struct Event: Codable {
    let eventId: String
    let name: String
    let description: String
    let startTime: TimeInterval
    let endTime: TimeInterval
}
func getEvents() async throws -> [Event] {
    let url = URL(string:"https://adonix.hackillinois.org/event/")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoded = try JSONDecoder().decode(EventResponse.self, from: data)
    return decoded.events
}


func getTime(_ startTime:TimeInterval,_ endTime:TimeInterval) -> String {
    let start = Date(timeIntervalSince1970: startTime)
    let end  = Date(timeIntervalSince1970: endTime)
    let startFormat = DateFormatter()
    startFormat.timeZone = TimeZone(identifier: "America/Chicago")
    startFormat.dateFormat = "(EEEE h:mm a - "
    let endFormat = DateFormatter()
    endFormat.timeZone = TimeZone(identifier: "America/Chicago")
    endFormat.dateFormat = "h:mm a)"
    let startString = startFormat.string(from: start)
    let endString = endFormat.string(from: end)
    return startString + endString
}

func getDay(_ t:TimeInterval) -> String {
    let time = Date(timeIntervalSince1970: t)
    let timeFormat = DateFormatter()
    timeFormat.timeZone = TimeZone(identifier: "America/Chicago")
    timeFormat.dateFormat = "EEEE"
    return timeFormat.string(from:time)
}

struct SearchBody : View {
    @Binding var searchText:String
    @State var events: [Event]?
    @Binding var favoriteEvents:Set<Int>
    @State var showDescription:Set<Int> = []
    var body : some View {
        ScrollView(.vertical) {
            if let events {
                let eventNum = events.count
                ForEach(0..<eventNum, id: \.self) { i in
                    if(((events[i].name).lowercased()).contains(searchText.lowercased()) || searchText == "") {
                        VStack {
                            Text(events[i].name)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .bold()
                                .font(.system(size: 24))
                                .onTapGesture {
                                    if(showDescription.contains(i)) {
                                        showDescription.remove(i)
                                    } else {
                                        showDescription.insert(i)
                                    }
                                }
                            
                            Text(getTime(events[i].startTime,events[i].endTime))
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .multilineTextAlignment(.center)
                                .onTapGesture {
                                    if(showDescription.contains(i)) {
                                        showDescription.remove(i)
                                    } else {
                                        showDescription.insert(i)
                                    }
                                }
                            Button {
                                if(favoriteEvents.contains(i)) {
                                    favoriteEvents.remove(i)
                                } else {
                                    favoriteEvents.insert(i)
                                }
                            } label: {
                                if(favoriteEvents.contains(i)) {
                                    Image(systemName:"suit.heart.fill")
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName:"suit.heart")
                                        .foregroundColor(.red)
                                }
                            }
                            if(showDescription.contains(i)) {
                                Text(events[i].description)
                                    .foregroundColor(.white)
                            }
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.blue)
                                .frame(height: 10)
                                .padding(3)
                        }
                        .background(.blue)
                    }
                    
                }
                
            }
        }
        .task {
            do {
                events = try await getEvents()
                events = events?.sorted(by: {(e1:Event,e2:Event) -> Bool in return e2.startTime > e1.startTime})
            } catch {
                events = nil
            }
        }
    }
}


struct ScrollBody : View {
    let day:String
    @State var events: [Event]?
    @Binding var favoriteEvents:Set<Int>
    @State var showDescription:Set<Int> = []
    var body : some View {
        ScrollView(.vertical) {
            if let events {
                let eventNum = events.count
                ForEach(0..<eventNum, id: \.self) { i in
                    let favorite:Bool = favoriteEvents.contains(i) && day == "Favorites"
                    if(getDay(events[i].startTime) == day || favorite) {
                        VStack {
                            Text(events[i].name)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .bold()
                                .font(.system(size: 24))
                                .onTapGesture {
                                    if(showDescription.contains(i)) {
                                        showDescription.remove(i)
                                    } else {
                                        showDescription.insert(i)
                                    }
                                }
                            
                            Text(getTime(events[i].startTime,events[i].endTime))
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .multilineTextAlignment(.center)
                                .onTapGesture {
                                    if(showDescription.contains(i)) {
                                        showDescription.remove(i)
                                    } else {
                                        showDescription.insert(i)
                                    }
                                }
                            Button {
                                if(favoriteEvents.contains(i)) {
                                    favoriteEvents.remove(i)
                                } else {
                                    favoriteEvents.insert(i)
                                }
                            } label: {
                                if(favoriteEvents.contains(i)) {
                                    Image(systemName:"suit.heart.fill")
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName:"suit.heart")
                                        .foregroundColor(.red)
                                }
                            }
                            if(showDescription.contains(i)) {
                                Text(events[i].description)
                                    .foregroundColor(.white)
                            }
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.blue)
                                .frame(height: 10)
                                .padding(3)
                        }
                        .background(.blue)
                    }
                    
                }
                
            }
        }
        .task {
            do {
                events = try await getEvents()
                events = events?.sorted(by: {(e1:Event,e2:Event) -> Bool in return e2.startTime > e1.startTime})
            } catch {
                events = nil
            }
        }
    }
}

struct SearchView : View {
    @State var searchText:String = ""
    @Binding var favoriteEvents:Set<Int>
    var body : some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.top)
            VStack {
                ZStack {
                    if searchText == "" {
                        Text("Search Here")
                            .foregroundStyle(.white)
                            .font(.system(size: 30))
                    }
                    TextField("", text: $searchText)
                        .padding(.horizontal, 10)
                        .padding()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                SearchBody(searchText: $searchText, favoriteEvents: $favoriteEvents)

            }
        }
    }
}



struct MainView : View {
    let day:String
    @Binding var favoriteEvents:Set<Int>
    var body : some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.top)
            VStack {
                
                Text("HackIllinois Events")
                    .foregroundColor(.white)
                    .font(.system(size: 40))
                ScrollBody(day:day, favoriteEvents:$favoriteEvents)
            }
            .padding()
            
        }
    }
}




struct ContentView: View {
    @State var favoriteEvents: Set<Int> = []
    var body: some View {
        TabView {
            MainView(day: "Friday",favoriteEvents: $favoriteEvents)
                .tabItem {
                    Label("Friday",systemImage: "1.circle")
                        
                }
            MainView(day: "Saturday",favoriteEvents: $favoriteEvents)
                .tabItem {
                    Label("Saturday",systemImage: "2.circle")

                }
            MainView(day: "Sunday",favoriteEvents: $favoriteEvents)
                .tabItem {
                    Label("Sunday",systemImage: "3.circle")

                }
            MainView(day: "Favorites",favoriteEvents: $favoriteEvents)
                .tabItem {
                    Label("Favorites",systemImage: "suit.heart.fill")
                }
            SearchView(favoriteEvents: $favoriteEvents)
                .tabItem {
                    Label("Search",systemImage: "magnifyingglass")
                }
        }
    }
}

