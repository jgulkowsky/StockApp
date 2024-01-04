Ideas for further development:

- in future we should move api token into our own backend so it cannot be stolen from the device - now it's not safe
- WatchlistViewModel and QuoteViewModel have similar method turnOnTimer() - maybe it could be put into one place?
- BaseTableViewHeader and BaseTableViewCell use layoutSubviews method for updating the constraints - this isn't perfect solution as it updates too often - when timer fires so every 5 seconds
- we could check if stock market is closed when fetchin quote data - if so then we should't make calls - this logic should be put into quotesProvider that would just return last quote and not send request until the stock is open once again
- consider passing stockItem instead of just symbol from WatchlistViewModel into QuoteViewModel - so VM don't have to load data for itself or even can but at least have sth to show without loading indicator
- generally we don't support starting / stopping timers when going into background foreground
- errorLabels / loadingIndicators could be moved into BaseVC (logic for showing / hiding them too) - with use of StatefulViewModel
