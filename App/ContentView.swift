import SwiftUI

struct ContentView: View {
    @StateObject private var vm = SearchViewModel()
    @FocusState private var queryFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.bar)

            Divider()

            DictWebView(url: vm.currentURL)
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Picker("類型", selection: $vm.searchType) {
                ForEach(SearchType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 140)

            TextField("輸入字或詞", text: $vm.query)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .focused($queryFocused)
                .onSubmit { runSearch() }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            Button {
                runSearch()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title3.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button {
                vm.goHome()
                queryFocused = false
            } label: {
                Image(systemName: "house")
                    .font(.title3)
            }
            .buttonStyle(.bordered)
        }
    }

    private func runSearch() {
        vm.submit()
        queryFocused = false
    }
}

#Preview {
    ContentView()
}
