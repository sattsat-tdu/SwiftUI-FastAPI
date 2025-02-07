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
        List {
            ForEach(tasks, id: \.id) { task in
                HStack {
                    Text(task.title)
                    Spacer()
                    Button(action: {
                        toggleTaskDone(task)
                    }, label: {
                        Image(systemName: task.done ? "checkmark.square" : "square")
                    })
                }
            }
            .onDelete(perform: deleteTask)
        }
        .onAppear {
            getTasks()
        }
        .refreshable {
            getTasks()
        }
        .overlay(alignment: .bottom) {
            Button("追加") {
                createTask(request: TaskRequest(title: "Hello World"))
            }
        }
    }
    
    @MainActor
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
    
    @MainActor
    private func toggleTaskDone(_ task: TaskResponse) {
        Task {
            let result = await apiClient.updateTaskDoneState(taskId: task.id, isDone: !task.done)
            switch result {
            case .success:
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index].done.toggle()
                }
            case .failure(let error):
                print("[ERROR] \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let taskId = tasks[index].id
            Task {
                let result = await apiClient.deleteTask(taskId: taskId)
                switch result {
                case .success:
                    tasks.remove(at: index)
                case .failure(let error):
                    print("[ERROR] \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func createTask(request: TaskRequest) {
        Task {
            let result = await apiClient.createTask(request: request)
            switch result {
            case .success(let response):
                let newTask = TaskResponse(
                    title: response.title,
                    id: response.id,
                    done: false
                )
                self.tasks.append(newTask)
            case .failure(let error):
                print("[ERROR] \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
