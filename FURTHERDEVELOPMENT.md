Ideas for further development:

- in future we should move api token into our own backend so it cannot be stolen from the device - now it's not safe
- WatchlistViewModel and QuoteViewModel have similar method turnOnTimer() - maybe it could be put into one place?
- BaseTableViewHeader and BaseTableViewCell use layoutSubviews method for updating the constraints - this isn't perfect solution as it updates too often - when timer fires so every 5 seconds
- we could check if stock market is closed when fetchin quote data - if so then we should't make calls - this logic should be put into quotesProvider that would just return last quote and not send request until the stock is open once again
- consider passing stockItem instead of just symbol from WatchlistViewModel into QuoteViewModel - so VM don't have to load data for itself or even can but at least have sth to show without loading indicator
- generally we don't support starting / stopping timers when going into background foreground
- errorLabels / loadingIndicators could be moved into BaseVC (logic for showing / hiding them too) - with use of StatefulViewModel
- add padding to the tableView in AddNewSymbolVC (both for horizontal and vertical orientation) as sometimes values on the bottom will not be available because are under the keyboard / or at least add button for collapsing the keyboard
- [AddNewSymbolViewController] we could use textFieldDidBeginEditing and create viewModel.onTextFieldFocused() which will check if the text is empty (after trimming) and remove it if so (as in AddNewWatchlistViewModel) - this is to be done in both UIKit and SwiftUI
- [AddNewSymbolViewController] would be nice to have info that the list is empty after typing too long string
- [WatchlistsViewController / WatchlistViewController] - it would be nice to be possible to edit the name for the watchlist
- [WatchlistsViewController / WatchlistViewController] - in both views you should add info when lists are empty - as it looks bad without it (especially in WatchlistViewController with empty header) - just some information that your list is empty to add sth click on + button
- add support for differrent languages 
- add support for changing time of the graph / swipes on it / bottom buttons like 1d 3d 5d 7d 1m 3m etc
