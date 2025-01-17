import SwiftUI

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListCell(dataSource: FolderCellDataSource(folder: Folder(name: "TestFolder", date: Date(), isPasswordProtected: false, uid: UUID(), files: [])), folderSelector: FolderSelector())
    }
}

struct ListCell: View {
    @StateObject var dataSource: FolderCellDataSource
    
    @State private var isSelected: Bool = false
    
    var folderSelector: FolderSelector
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "folder.fill")
                .resizable()
                .foregroundColor(isSelected ? Color(UIColor.systemRed) : Color(UIColor.systemBlue))
                .frame(maxWidth: 80, maxHeight: 60)
            VStack(alignment: .leading, spacing: 15) {
                Text(dataSource.folder.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.label))
                    .padding([.top, .leading, .trailing, .bottom], 5)
                    .offset(x: 0, y: /*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                HStack {
                    Text(dataSource.folder.date.toString)
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(Color(UIColor.systemGray))
                    .padding([.leading, .bottom], 5)
                    Text("(\(dataSource.folder.files.count) \(dataSource.folder.files.count == 1 ? "item" : "items"))")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(Color(UIColor.systemGray))
                    .padding([.trailing, .bottom], 5)
                }
            }
        }
        .onReceive(folderSelector.publisher) { selection in
            isSelected = selection.id == dataSource.folder.uid.uuidString && selection.selected
        }
    }
}
