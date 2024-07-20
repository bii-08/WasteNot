//
//  AddEditView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import SwiftUI
import PhotosUI
import UIKit
import SwiftData

struct AddEditView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedItem: Item?
    
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var expiryDate = Date.now
    @State private var purchasedDate = Date.now
    
    @State private var showingPhotoSelectionSheet = false
    @State private var showingImagePicker = false
    
    @State private var selection: ItemIcon?
    var enumCaseString: String? {
        return selection?.rawValue
    }

    @State private var selectedImage: UIImage?
  
    @State private var searchText = ""
    
    let columns = [GridItem(.adaptive(minimum: 44), spacing: 40)]

    let itemIcons: [ItemIcon] = ItemIcon.allCases
    var results: [ItemIcon] {
        searchText.isEmpty ? itemIcons : itemIcons.filter { $0.name.contains(searchText.lowercased()) }
    }
    
    var body: some View {
       
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                // Item name
                HStack {
                    Image(systemName: "pencil.and.scribble")
                    Text("Item :")
                        .padding(.trailing, 30)
                    
                    TextField("Eg. Apple", text: $itemName)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.gray.opacity(0.35)))
                }
                // Item quantity
                HStack {
                    Image(systemName: "cart.fill")
                    Text("Quantity :")
                        .padding(.trailing, 60)
                    Stepper("\(quantity)", value: $quantity, in: 1...100)
                }
                // Purchased Date
                HStack {
                    Image(systemName: "calendar")
                    Text("Purchased Date :")
                    DatePicker("", selection: $purchasedDate, displayedComponents: .date)
                    
                }
                // Expiry Date
                HStack {
                    Image(systemName: "calendar")
                    Text("Expiry Date :")
                    DatePicker("", selection: $expiryDate, displayedComponents: .date)
                }
                // Item's photo
                HStack {
                    Image(systemName: "photo")
                    Text("Item's photo :")
                    Spacer()
                    
                    Menu {
                        Button("Choose from Icons") {
                            showingPhotoSelectionSheet = true
                        }
                        
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("Take a Photo", systemImage: "camera")
                        }
                        
                    } label: {
                        if selection == nil && selectedImage == nil {
                            Image(systemName: "photo.badge.plus")
                                .scaleEffect(2)
                                .frame(maxWidth: 150, maxHeight: 150)
                                .background(.gray.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            if let selectedIcon = selection {
                                Image("\(selectedIcon)")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .frame(maxWidth: 200, maxHeight: 200)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.primary, lineWidth: 1))
                            } else if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 200, maxHeight: 200)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                Spacer()
                
                HStack {
                    // Add/ Edit Button
                    Button {
                        if selectedItem == nil {
                            let newItemImageData: Data
                            if let selectedIcon = selection {
                                if let iconImage = UIImage(named: "\(selectedIcon)") {
                                    newItemImageData = iconImage.pngData() ?? Data()
                                } else {
                                    newItemImageData = UIImage(systemName: "photo")!.pngData()!
                                }
                            } else if let selectedImage = selectedImage {
                                newItemImageData = selectedImage.pngData()!
                            } else {
                                newItemImageData = UIImage(systemName: "photo")!.pngData()!
                            }
                            
                            let newItem = Item(name: itemName, quantity: quantity, purchasedDate: purchasedDate, expiryDate: expiryDate, image: newItemImageData, enumCaseString: enumCaseString)
                            modelContext.insert(newItem)
                        } else {
                            selectedItem?.name = itemName
                            selectedItem?.quantity = quantity
                            selectedItem?.expiryDate = expiryDate
                            selectedItem?.purchasedDate = purchasedDate
                             
                            if let selection = selection {
                                selectedItem?.image = UIImage(named: "\(selection)")?.pngData() ?? Data()
                                selectedItem?.enumCaseString = enumCaseString
                            } else if let selectedImage = selectedImage {
                                selectedItem?.image = selectedImage.pngData() ?? Data()
                            }
                        }
                        
                        dismiss()
                    } label: {
                        Label(selectedItem != nil ? "Change" : "Add", systemImage: "pencil")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(itemName.isEmpty)
                    
                    // Cancel Button
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $showingPhotoSelectionSheet, content: {
                photoSelectionSheet()
                
            })
            .fullScreenCover(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                if let selectedItem = selectedItem {
                    
                    itemName = selectedItem.name
                    quantity = selectedItem.quantity
                    purchasedDate = selectedItem.purchasedDate
                    expiryDate = selectedItem.expiryDate
                    if selectedItem.enumCaseString == nil {
                        selectedImage = UIImage(data: selectedItem.image)
                    } else {
                        selection = ItemIcon(rawValue: selectedItem.enumCaseString ?? "")
                    }
                }
            }
            .onDisappear {
                selectedItem = nil
            }
            .padding()
            .navigationTitle(selectedItem != nil ? "Editing Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder private func photoSelectionSheet() -> some View {
        VStack(alignment: .leading) {
            
            Text("Select an icon")
                .font(.title3)
                .padding()
            
            Divider()
            
            List {
                LazyVGrid(columns: columns) {
                    ForEach(results) { icon in
                        VStack {
                            Image("\(icon)")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 80, height: 80)
                                .background(RoundedRectangle(cornerRadius: 5).stroke(Color.primary, lineWidth: 2))
                                .onTapGesture {
                                    selection = icon
                                    print(selection as Any)
                                    showingPhotoSelectionSheet = false
                                }
                            
                            Text(icon.name)
                                .frame(width: 100,height: 50)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Look for your item")
            .listStyle(PlainListStyle())
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .camera

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}


#Preview {
    AddEditView(selectedItem: .constant(Item.init(name: "Apple", quantity: 2, purchasedDate: Date.now, expiryDate: Date.now, image: Data(), enumCaseString: "")))
}
