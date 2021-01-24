//
//  ArticleListElement.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI

struct ArticleListElement: View {
    @Binding var vm: ArticleVM
    let isPad = UIDevice.current.userInterfaceIdiom == .pad

    var body: some View {
        HStack(alignment: .top) {
            thumbnail
            VStack(alignment: .leading) {
                headline
                Divider()
                leadParagraph
            }
        }.animation(.easeOut(duration: 0.1))
    }

    var thumbnail: some View {
        Group {
            vm.img.map { img in
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75.0, height: 75.0)
                    .transition(.slide)
            }
        }
    }

    var loadingIndicator: some View {
        Rectangle()
            .foregroundColor(Color(.lightGray))
            .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle()))
    }

    var headline: some View {
        Text(vm.headline)
            .font(isPad ? .title : .headline)
            .padding(.bottom, 1.0)
            .layoutPriority(1)
    }

    var leadParagraph: some View {
        Text(vm.leadParagraph)
            .font(isPad ? .title3 : .subheadline)
            .padding(.top, 1.0)
            .layoutPriority(-1)
    }
}
