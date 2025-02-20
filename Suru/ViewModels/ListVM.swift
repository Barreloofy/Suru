//
//  ListVM.swift
//  Suru
//
//  Created by Barreloofy on 2/19/25 at 9:02 PM.
//

import Foundation
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
