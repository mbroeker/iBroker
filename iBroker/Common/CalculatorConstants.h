//
//  CalculatorConstants.h
//  iBroker
//
//  Created by Markus Bröker on 19.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#ifndef CalculatorConstants_h
#define CalculatorConstants_h

// Definition der verfügbaren Börsen
#define EXCHANGE_BITTREX @"BITTREX_EXCHANGE"
#define EXCHANGE_POLONIEX @"POLONIEX_EXCHANGE"

#define POLONIEX_ASK @"lowestAsk"
#define POLONIEX_BID @"highestBid"
#define POLONIEX_LOW24 @"low24hr"
#define POLONIEX_HIGH24 @"high24hr"
#define POLONIEX_QUOTE_VOLUME @"quoteVolume"
#define POLONIEX_BASE_VOLUME @"baseVolume"
#define POLONIEX_PERCENT @"percentChange"
#define POLONIEX_LAST @"last"

// ASSET KEYS
#define ASSET1 @"BTC"
#define ASSET2 @"BCC"
#define ASSET3 @"ETH"
#define ASSET4 @"XMR"
#define ASSET5 @"LTC"
#define ASSET6 @"DCR"
#define ASSET7 @"STRAT"
#define ASSET8 @"GAME"
#define ASSET9 @"XRP"
#define ASSET10 @"XEM"

// ASSET DESCRIPTION KEYS
#define DASHBOARD @"Dashboard"
#define ASSET1_DESC @"Bitcoin"
#define ASSET2_DESC @"BC Cash"
#define ASSET3_DESC @"Ethereum"
#define ASSET4_DESC @"Monero"
#define ASSET5_DESC @"Litecoin"
#define ASSET6_DESC @"Decred"
#define ASSET7_DESC @"Stratis"
#define ASSET8_DESC @"GameCredits"
#define ASSET9_DESC @"Ripple"
#define ASSET10_DESC @"New Eco"

// FIAT CURRENCY KEYS
#define EUR @"EUR"
#define USD @"USD"
#define GBP @"GBP"
#define JPY @"JPY"
#define CNY @"CNY"

// SHARED USER DEFAULTS KEYS
#define KEY_INITIAL_RATINGS @"initialRatings"
#define KEY_CURRENT_SALDO @"currentSaldo"
#define KEY_SALDO_URLS @"saldoUrls"

#define KEY_FIAT_CURRENCIES @"fiatCurrencies"
#define KEY_DEFAULT_EXCHANGE @"defaultExchange"
#define KEY_TRADING_WITH_CONFIRMATION @"tradingWithConfirmation"

// CHECKPOINT KEYS
#define CP_INITIAL_PRICE @"initialPrice"
#define CP_CURRENT_PRICE @"currentPrice"
#define CP_PERCENT @"percent"

// REAL_PRICE KEYS
#define RP_PRICE @"price"
#define RP_REALPRICE @"realPrice"
#define RP_CHANGE @"change"

// TEMPLATEVIEW KEYS
#define TV_APPLICATIONS @"applications"
#define TV_TRADERS @"traders"

#define TV_HOMEPAGE @"homepage"
#define TV_TRADER1 @"trader1"
#define TV_TRADER2 @"trader2"

#define TV_TICKER_PLACEHOLDER @"---"
#define OPTIONS_MENUBAR @"menubar"

#define COINCHANGE_PERCENTAGE @"coinchangePercentage"

#endif /* CalculatorConstants_h */
