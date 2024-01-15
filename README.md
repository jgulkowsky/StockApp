# StockApp

## Project overview

The goal of this app is to provide a way for a user to manage watchlists of quotes. 

There are 5 screens: 

- Watchlists Screen - first screen presenting a collection of all the watchlists added by user

- Watchlist Screen - can be accessed by tapping on one of the watchlists on Watchlists Screen - it presents a collection of all the symbols related to the selected watchlist and their quotes

- Quote Screen - can be accessend by tapping on one of the symbols on Watchlist Screen - it presents chart data for last 30 days as well as quote related to the selected symbol

- Add New Watchlist Screen - can be accessed by tapping on + button on Watchlists Screen - it allows to add new watchlist

- Add New Symbol Screen - can be accessed by tapping on + button on Watchlist Screen - it allows to browse through available stock symbols and add one of them 

Pattern used is MVVM with Coordinator. Combine and async / await are in use too. There are also unit tests, darkmode and orientation changes support as well as support for different screen sizes (iPhone / iPad). UI is created with UIKit / SnapKit. Charts are created using DGCharts package.   

## H2 Installation 

- Note that project uses 2 build configurations: debug and release - and that behaviour is different

- When debug is selected then app starts with additional screen - TestRetainCyclesViewController - it's purpose is to check if all the other screens deinits well without leaving any retain cycles - to go to default starting point the Watchlists Screen just tap on + button on the top

- When release is selected then app starts normally from Watchlists Screen

- To switch configurations click on Edit Scheme / go to Run tab / under info tab select build configuration you need

- You need also to get the api key from IEX Cloud API (https://iexcloud.io/ -> Start a Free Trial - you don’t need to enter any credit card information) and create environment variable with the api key

- To create environment variable click on Edit Scheme / go to Run tab / under arguments tab in environment variables section add new value with name 'API_TOKEN' and value equal to the api key obtained from IEX Cloud API (use publishable key)

- After these steps you should be set up to run the project
