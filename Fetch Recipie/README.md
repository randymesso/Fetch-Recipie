#  Fetch Interview

### Steps to Run the App
    -Copy the repository link from GitHub
    -Open Xcode
    -Create a new project using the link copied from GitHub
    -Build and run (⌘ + R)
### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
    Architecture and Code Organization
        -Implemented MVVM architecture for clear separation of concerns and to emulate Fetch's future company desires 
        -Created a robust networking layer with proper error handling
        -Used protocol-oriented programming for better testability
    Performance and Efficiency
        -Implemented efficient image caching (both memory and disk)
        -Used async/await for modern concurrency
        -Implemented lazy loading of images in collection view
    User Experience/User Interface
        -Added pull-to-refresh functionality
        -Implemented search functionality that is compatible with recipes and cuisines
        -Added difficulty filtering
        -Added a cooking time to help with the user experience
        -Included a feature to press on each recipe and get the youtube link and web URL in a pop up detail view 
        -Smooth animations and transitions
        -Created some features/aspects of the app that could integrate with Fetch's app
### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent a weekend working on the project
    -The first chunk was spend on creating a design wireframe/drawing for the project based on requirements
    -The second part was spent setting up the networking and making sure the data was being received/accessed properly
    -The next chunk was spent setting up the UI based on the designs
    -The fourth chunk was spend optimizing/cleaning up the code and error handling
    -The last chunk of time was spent writing unit tests for the app
### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
    UIKit vs SwiftUI
        -Chose UIKit for better compatibility and performance
        -Used some SwiftUI components where beneficial
        -Included the hybrid model of using both to emulate Fetch's current position of supporting UIKit code but migrating to SwiftUI
    Image Caching
        -Built custom solution instead of using third-party libraries which cost me time spent developing but reduces dependencies
        -Provides better control but could be less robust than established libraries
    Testing Approach
        -Focused on unit tests for business logic and excluded focused testing on UI components
        -Changed accessibility of variables in the project to allow for more flexible testability
### Weakest Part of the Project: What do you think is the weakest part of your project?
    Error Handling UX
        -Error states could be more informative
        -Could add more retry mechanisms upon encountering errors
    Test Coverage 
        -UI layer could use more testing
        -Integration tests could be added
    Image Loading
        -Could implement progressive loading
        -Could add placeholder images during loading process
### External Code and Dependencies: Did you use any external code, libraries, or dependencies?
    No external dependencies were used. All functionality was implemented using native iOS frameworks:
        -UIKit
        -Foundation
        -XCTest (for testing)
### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
    iOS Requirements
        -Minimum iOS target: iOS 16.0 to emulate Fetch's current app support requirements 
    Future Improvements
        -Add offline support
        -Implement recipe favorites
        -Add more filtering options

