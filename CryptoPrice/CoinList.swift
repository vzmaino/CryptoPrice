//
//  ContentView.swift
//  CryptoPrice
//
//  Created by Vinicius Maino on 28/01/21.
//

import SwiftUI
import Combine

struct CoinList: View {
    
    @ObservedObject private var  viewModel = CoinListViewModel()
    
    var body: some View {
        
        NavigationView {
            List(viewModel.coinViewModels, id: \.self) { coinViewModel in
                Text(coinViewModel.displayText)
            }.onAppear {
                self.viewModel.fetchCoins()
            }.navigationBarTitle("Coins")
            
        }
    }
}

struct CoinList_Previews: PreviewProvider {
    static var previews: some View {
        CoinList()
    }
}

class CoinListViewModel: ObservableObject {
    
    private let cryptoService = CryptoService()
    
    @Published var coinViewModels = [CoinViewModel]()
    
    var cancellable: AnyCancellable?
    
    func fetchCoins() {
        cancellable = cryptoService.fetchCoins().sink(receiveCompletion: { _ in
            
        }, receiveValue: { cryptoContainer in
            self.coinViewModels = cryptoContainer.data.coins.map { CoinViewModel($0) }
            print(self.coinViewModels)
        })
    }
}

struct CoinViewModel: Hashable {
    private let coin: Coin
    
    var name: String {
        return coin.name
    }
    
    var formattedPrice: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        guard let price = Double(coin.price), let formattedPrice = numberFormatter.string(from: NSNumber(value: price)) else { return ""}
        
        return formattedPrice
    }
    
    var displayText: String {
        return name + " - " + formattedPrice
    }
    
    init(_ coin: Coin) {
        self.coin = coin
    }
}

