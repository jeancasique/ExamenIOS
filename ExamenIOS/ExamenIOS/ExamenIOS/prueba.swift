
/* import SwiftUI


struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct TaskListView: View {
    @ObservedObject var viewModel: TaskListViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRowView(task: task)
                }
                .onDelete(perform: viewModel.deleteTask)
            }
            .navigationBarTitle("Tasks")
            .navigationBarItems(trailing: Button(action: {
                viewModel.addTask()
            }) {
                Image(systemName: "plus")
            })
        }
    }
}

struct TaskRowView: View {
    var task: Task

    var body: some View {
        HStack {
            Text(task.title)
            Spacer()
            if task.isCompleted {
                Image(systemName: "checkmark")
            }
        }
    }
 }*/
