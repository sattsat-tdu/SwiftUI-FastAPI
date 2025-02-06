//
//  ContentView.swift
//  SwiftUIFastAPI
//  
//  Created by SATTSAT on 2025/02/04
//  
//

import SwiftUI

struct ContentView: View {
    
    private let apiClient = TestAPIClient()
    
    @State private var tasks: [TaskResponse] = []
    
    var body: some View {
        List(tasks, id: \.id) { task in
            HStack {
                Text(task.title)
                Spacer()
                if task.done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .onAppear {
            getTasks()
        }
    }
    
    private func getTasks() {
        Task {
            let result = await apiClient.fetchTasks()
            switch result {
            case .success(let tasksReponse):
                self.tasks = tasksReponse
            case .failure(let error):
                print("[ERROR] \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
