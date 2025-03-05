//
//  DetailView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:49 AM.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: DetailViewModel
    @Binding var item: SuruItem
    
    init(item: Binding<SuruItem>) {
        self._item = item
        self._viewModel = State(initialValue: DetailViewModel(text: item.wrappedValue.content))
    }
    
    var body: some View {
        NavigationStack {
            CustomForm {
                FormContent
            }
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .tint(DesignSystem.Colors.tint)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                        viewModel.set(for: $item)
                    } label: {
                        Text("Set")
                    }
                    .font(.title3)
                }
                ToolbarItem(placement: .principal) {
                    Text("Details")
                        .font(.title)
                }
            }
        }
        .onAppear {
            viewModel.initiateAlert(item.alert)
        }
    }
    
    @ViewBuilder private var FormContent: some View {
        TextField("Suru...", text: $viewModel.text, axis: .vertical)
            .onChange(of: viewModel.text) {
                viewModel.text.lengthEnforcer()
            }
        
        Group {
            Toggle("Alert", isOn: $viewModel.alert)
            
            DatePicker("Dueby:", selection: $item.dueDate)
                .tint(DesignSystem.Colors.primaryText)
            
            LabeledContent("Repeat:") {
                Picker("Repeat:", selection: $item.repeatFrequency) {
                    ForEach(Frequency.allCases) { frequency in
                        Text(frequency.rawValue)
                    }
                }
            }
            .tint(DesignSystem.Colors.primaryText)
        }
        .disabled(NotificationService.shared.notificationPermission ? false : true)
        .opacity(NotificationService.shared.notificationPermission ? 1.0 : 0.25)
        
        NotificationService.shared.alertText()
            .fontWeight(.regular)
    }
}

#Preview {
    DetailView(item: .constant(SuruItem()))
        .environment(UserData())
}
