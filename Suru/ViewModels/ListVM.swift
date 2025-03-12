//
//  ListVM.swift
//  Suru
//
//  Created by Barreloofy on 2/19/25 at 9:02 PM.
//

import SwiftUI

@MainActor
@Observable
final class ListViewModel {
    var showSettings = false
    var scrollToItem: UUID?
    
    func scrollToItem(proxy: ScrollViewProxy, _ items: [SuruItem]? = nil, _ index: Int? = nil) {
        if let items = items, let index = index, items.indices.contains(index) {
            let uuid = items[index].id
            proxy.scrollTo(uuid, anchor: .bottom)
        }
        else {
            guard let stringUUID = NotificationService.shared.tappedNotification,
                  let uuid = UUID(uuidString: stringUUID) else { return }
            proxy.scrollTo(uuid, anchor: .center)
        }
    }
}

/*
 
 private func getItemID(_ uuid: UUID) -> String {
     var itemID = uuid.uuidString
     
     if itemID.hasSuffix("_repeating") {
         itemID = String(itemID.dropLast(10))
     }
     
     return itemID
 }
 
 func updateCompleted(_ suruItems: inout [SuruItem]) {
     guard let completedItems = UserDefaults.standard.stringArray(forKey: "completedItems") else { return }
     
     var completedItemsDict: [String: Int] = Dictionary(minimumCapacity: suruItems.count)
     
     suruItems.enumerated().forEach { index, item in
         completedItemsDict[getItemID(item.id)] = index
     }
     
     completedItems.forEach { completedID in
         guard let index = completedItemsDict[completedID] else { return }
         suruItems[index].completed = true
     }
 }
 
 */
