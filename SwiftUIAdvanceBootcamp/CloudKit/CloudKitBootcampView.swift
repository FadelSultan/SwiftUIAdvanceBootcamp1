//
//  CloudKitBootcampView.swift
//  SwiftUIAdvanceBootcamp
//
//  Created by Fadel Sultan on 30/12/2023.
//

import SwiftUI
import CloudKit


struct Fruit {
    let name:String
    let record:CKRecord
}
class CloudKitBootcampDataService {
    
    func add(record:CKRecord) async throws {
        do {
            try await CKContainer.default().publicCloudDatabase.save(record)
//            print(result.value(forKey: "name"))
        }catch {
            throw error
        }
    }
    
    func fetch() async throws {
        let query = CKQuery(recordType: "Fruit", predicate: NSPredicate(value: true))
        
        do {
            let result = try await CKContainer.default().publicCloudDatabase.records(matching: query)
            let value = result.matchResults.first
        }catch {
            throw error
        }
    }
    
}

class CloudKitBootcampViewModel:ObservableObject {
    
    private let dataService = CloudKitBootcampDataService()
    private let recordName:String = "Fruit"
    @Published var errorMessage: String = ""
    
    
    func addNew(fruitName:String) {
        
        if fruitName.isEmpty {
            errorMessage = "The fruit name is empty!"
            return
        }
        
        let record = CKRecord(recordType: recordName)
        record["name"] = fruitName
        
        Task {
            do {
                try await dataService.add(record:record)
            }catch {
                print(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func fetch() async {
        Task {
            do {
               try await dataService.fetch()
            }catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct CloudKitBootcampView: View {
    
    @StateObject private var viewModel = CloudKitBootcampViewModel()
    
    @State private var text:String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                
                errorMessage
                                
                TextField(text: $text) {
                    Text("Fruit name ...")
                        .font(.headline)
                }
                .padding()
                .background(Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 10)))
                
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        viewModel.addNew(fruitName: text)
                    }
                }, label: {
                    Text("Save!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink.clipShape(RoundedRectangle(cornerRadius: 10)))
                        
                })
                
                
                Spacer()
            }.task {
                await viewModel.fetch()
            }
            .padding()
            .navigationTitle("CloudKit Fruit")
        }
    }
}

#Preview {
    CloudKitBootcampView()
}


extension CloudKitBootcampView {
    
    @ViewBuilder
    private var errorMessage:some View {
        if !viewModel.errorMessage.isEmpty {
            
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10)
                Text(viewModel.errorMessage)
                    .font(.headline)
                    .foregroundStyle(.red)
                Spacer()
            }.onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut) {
                        viewModel.errorMessage = ""
                    }
                }
            })
        }

    }
}
