//
//  ContentView.swift
//  GymTracker
//
//  Created by Baron on 2/2/22.
//

import SwiftUI
import Combine
import Foundation

struct Item: Identifiable {
    let id = UUID()
    var name = String()
    var typeCategory = String()
    @State public var readCategory = String()
    @State public var chapter = String()
}

struct ContentView: View {
    

    var body: some View {
        VStack {
            NavigationView {
                HomeView()
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func convertStruct (item: [Item]) -> String {
    var result: String = ""
    for i in item {
        let name = i.name
        let typeCat = i.typeCategory
        let readCat = i.readCategory
        let chapter = i.chapter
        result = result + "\(name)//\(typeCat)//\(readCat)//\(chapter)||"
    }
    return result
}

struct AddView: View {
    
    @AppStorage("collection") var collectionStorage: String = "Bye"
    
    @Binding public var collection: [Item]
    
    @State public var name: String = ""
    @State public var chapter: String = ""
    @State public var typeCategory: String = "Anime"
    @State public var finishedChecked: Bool = false
    @State public var futureChecked: Bool = false
    @State public var cat = "Unfinished"
    @State public var showAlert = false
    @State public var duplicateIndex: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text("Add a new item")) {
                TextField("Name", text: $name) {
                }
                TextField("Chapter", text: $chapter) {
                }.keyboardType(.decimalPad)
            }
            
            HStack {
                Image(systemName: finishedChecked ? "checkmark.square.fill" : "square")
                Spacer()
                Text("Finished")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.finishedChecked.toggle()
                self.futureChecked = false
                UIApplication.shared.endEditing()
            }

            HStack {
                Image(systemName: futureChecked ? "checkmark.square.fill" : "square")
                Spacer()
                Text("Interested")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.futureChecked.toggle()
                self.finishedChecked = false
                UIApplication.shared.endEditing()
            }
            
            Picker("Categories", selection: $typeCategory) {
                Text("Anime").tag("Anime")
                Text("Manga").tag("Manga")
                Text("Webtoon").tag("Webtoon")
                Text("Other").tag("Other")
            }
            .pickerStyle(.segmented)
                .frame(maxWidth: 340)
            
            Section() {
                if ((self.name != "" && self.chapter != "") || (self.name != "" && (self.futureChecked || self.finishedChecked))){
                    Button(action: {
                        addItem(name: self.name, chapter: self.chapter)
                    }, label: {Text("Add")})
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Item is already in collection"), message: Text("Would you like to replace it?"), primaryButton: .destructive(Text("Yes")){
                                self.collection.remove(at: self.duplicateIndex)
                                self.addItem(name: self.name, chapter: self.chapter)
                            },
                            secondaryButton: .cancel())
                    }
                    
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    func addItem(name: String, chapter: String) {
        if let i = collection.firstIndex(where: { $0.name.lowercased() + $0.typeCategory == name.lowercased() + self.typeCategory }) {
            self.showAlert = true
            self.duplicateIndex = i
        }
        else {
            if (finishedChecked) {
                cat = "Finished"
            }
            else if (futureChecked) {
                cat = "Interested"
            }
            UIApplication.shared.endEditing()
            let newItem: Item = Item(name: self.name, typeCategory: self.typeCategory, readCategory: self.cat, chapter: self.chapter)
            let convertedItem = convertStruct(item: [newItem])
            print(convertedItem)
            self.collection.append(newItem)
            self.collection = self.collection.sorted { $0.name.lowercased() < $1.name.lowercased() }
            self.name = ""
            self.chapter = ""
            self.finishedChecked = false
            self.futureChecked = false
            self.collectionStorage = self.collectionStorage + convertedItem
        }
    }
}

struct HomeView: View {
    
    @State public var collection: [Item] = [
        Item(name: "TestMangaUnfinished0", typeCategory: "Manga", readCategory: "Unfinished", chapter: "15"),
        Item(name: "TestMangaInterested0", typeCategory: "Manga", readCategory: "Interested", chapter: ""),
        Item(name: "TestMangaUnfinished1", typeCategory: "Manga", readCategory: "Unfinished", chapter: "82"),
        Item(name: "TestAnimeFinished0", typeCategory: "Anime", readCategory: "Finished", chapter: "56"),
        Item(name: "TestAnimeUnfinished0", typeCategory: "Anime", readCategory: "Unfinished", chapter: "34"),
        Item(name: "TestAnimeUnFinished1", typeCategory: "Anime", readCategory: "Unfinished", chapter: "1002"),
        Item(name: "TestAnimeUnFinished2", typeCategory: "Anime", readCategory: "Unfinished", chapter: "63"),
        Item(name: "TestInterestedWebtoon0", typeCategory: "Webtoon", readCategory: "Interested", chapter: "2")
    ]

    @AppStorage("collection") var collectionStorage: String = "Init"
    
    @State public var readCategory = 0
    @State public var typeCategory = 0
    let readArr = ["Unfinished", "Finished", "Interested"]
    let typeArr = ["Anime", "Manga", "Webtoon", "Other"]
    
    var body: some View {
        VStack {
            
            Text(collectionStorage)
            
            Picker("Categories", selection: $readCategory) {
                Text("Unfinished: " + "\(self.calculateItems(category: "Unfinished", filter: ""))").tag(0)
                Text("Finished: " + "\(self.calculateItems(category: "Finished", filter: ""))").tag(1)
                Text("Interested: " + "\(self.calculateItems(category: "Interested", filter: ""))").tag(2)
            }.pickerStyle(.segmented)
                .frame(maxWidth: 340)
            
            Picker("Categories", selection: $typeCategory) {
                Text("Anime: "  + "\(self.calculateItems(category: "\(readArr[readCategory])", filter: "Anime"))").tag(0)
                Text("Manga: "  + "\(self.calculateItems(category: "\(readArr[readCategory])", filter: "Manga"))").tag(1)
                Text("Webtoon: "  + "\(self.calculateItems(category: "\(readArr[readCategory])", filter: "Webtoon"))").tag(2)
                Text("Other: "  + "\(self.calculateItems(category: "\(readArr[readCategory])", filter: "Other"))").tag(2)
            }.pickerStyle(.segmented)
                .frame(maxWidth: 340)
            
            List {
                ForEach(collection) { item in
                    if (item.readCategory == self.readArr[self.readCategory]) &&
                        (item.typeCategory == self.typeArr[self.typeCategory]){
                        HStack {
                            Text(item.name)
                            Spacer()
                            if item.typeCategory == "Anime" {
                                Text("Ep. \(item.chapter)")
                            }
                            else if item.typeCategory == "Other" {
                                Text(item.chapter)
                            }
                            else {
                                Text("Ch. \(item.chapter)")
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            }   .navigationBarTitle("Your collection")
                .navigationBarItems(trailing:
                                        NavigationLink(destination: AddView(collection: $collection, name: ""), label: {Text("Add")})
                                        )
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        self.collection.remove(atOffsets: offsets)
    }
    
    func calculateItems(category: String, filter: String) -> String {
        var count: Int = 0
        if filter != "" {
            for m in self.collection {
                if m.readCategory == category && m.typeCategory == filter{
                    count += 1
                }
            }
        }
        else {
            for m in self.collection {
                if m.readCategory == category {
                    count += 1
                }
            }
        }
        return String(count)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
