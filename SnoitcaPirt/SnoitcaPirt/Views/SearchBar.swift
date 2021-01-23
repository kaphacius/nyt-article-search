//
//  SearchBar.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchString: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 6)
            TextField("Search...", text: $searchString)
        }
        .padding(7)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#if DEBUG
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchString: .constant("elections"))
    }
}
#endif
