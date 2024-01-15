## Technical Decisions

### MVVM pattern 

I have chosen MVVM as this is the architecure I have most experience with. Except that MVVM is known be to a good fit for medium sized projects - VIP or VIPER are rather intended for more complicated ones where MVC is never a good choice in my opinion (maybe for something really simple and small).

### Coordinator

Additionally to MVVM there's Coordinator pattern used so the coordination layer is moved out from ViewControllers / ViewModels. I decided to use an experimental version of Coordinator here with execute(action:) method. I am rather used to many methods in coordinators such as: showThisScreen(), showThatScreen(). I personally like my solution more as it hides what is going to happen from viewModel that calls coordinator method. Now every viewModel just passes type of action that happened such as .itemTapped with apropriate data and coordinator do the rest.

### TestRetainCyclesViewController

In debug configuration there's TestRetainCyclesViewController that's first ViewController that's pushed from Coordintor to navigaton stack. In this configuration we also have print outs for every viewModel init and deinit - so we can clearly see we don't have any retain cycles withou opening XCode Instruments which takes time. 

In release configuration first viewController pushed to navigation stack in WatchlistsViewController, the print outs as well as TestRetainCyclesViewController are not available

### Single Responsibility Principle

I tried to split into as many classes as possible so every class / struct has only one purpose according to Single Responsibility Principle. 

### Dependency Inversion Principle

I'm pretty sure that I have satisfied Dependency Inversion principle with combining all the components in the app with use of protocols and with usage of dependency injection. 

Thanks to this I was able to create mocks for unit tests easily. And even not only for test as in default target there are also some mocks that were used for normal development - e.g. when api didn't produce expected results, api key was too old or for any other reason.

### DRY

I tried not to repeat myself and whenever (or almost whenever) I found a place that has some common code / or code that could be parametrized to be common I put it into one place. But probably there're still some places that could be refactored - tests / some common parts between viewModels / viewControllers / views



 
