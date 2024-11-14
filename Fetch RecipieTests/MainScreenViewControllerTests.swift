import XCTest
@testable import Fetch_Recipie
@MainActor
class MainScreenViewControllerTests: XCTestCase
{
    var sut: MainScreenViewController!
    var mockViewModel: MockRecipeListViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockRecipeListViewModel()
        sut = MainScreenViewController(viewModel: mockViewModel)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initial Setup Tests
    func testInitialState() {
        XCTAssertFalse(sut.isSearching)
        XCTAssertNil(sut.currentDifficultyFilter)
        XCTAssertTrue(sut.recipesReceived.isEmpty)
        XCTAssertTrue(sut.filteredRecipes.isEmpty)
    }
    
    // MARK: - Data Loading Tests
//    func testLoadData_Success() async
//    {
//        // Given
//        let mockRecipes = [RecipeModel.mock()]
//        mockViewModel.mockRecipes = mockRecipes
//        
//        // When
//        await sut.loadData()
//        
//        // Then
//        XCTAssertEqual(sut.recipesReceived, mockRecipes)
//        XCTAssertEqual(sut.topFilterView.recipeCounter.text, "1 Recipes")
//    }
//    
//    func testLoadData_EmptyList() async {
//        // Given
//        mockViewModel.mockError = .emptyList
//        
//        // When
//        await sut.loadData()
//        
//        // Then
//        //XCTAssertTrue(sut.collectionView.isHidden)
//        XCTAssertNotNil(sut.emptyStateView)
//        XCTAssertEqual(sut.topFilterView.recipeCounter.text, "0 Recipes")
//    }
    
    // MARK: - Search Tests
    func testSearch_WithMatchingText() {
        // Given
        let mockRecipes = [
            RecipeModel.mock(name: "Pizza", cuisine: "Italian"),
            RecipeModel.mock(name: "Sushi", cuisine: "Japanese")
        ]
        sut.recipesReceived = mockRecipes
        
        // When
        sut.searchBar(sut.topFilterView.searchTextBox, textDidChange: "pizza")
        
        // Then
        XCTAssertTrue(sut.isSearching)
        XCTAssertEqual(sut.filteredRecipes.count, 1)
        XCTAssertEqual(sut.filteredRecipes.first?.name, "Pizza")
    }
    
    func testSearch_WithNoMatches() {
        // Given
        sut.recipesReceived = [RecipeModel.mock()]
        
        // When
        sut.searchBar(sut.topFilterView.searchTextBox, textDidChange: "nonexistent")
        
        // Then
        XCTAssertTrue(sut.isSearching)
        XCTAssertTrue(sut.filteredRecipes.isEmpty)
    }
    
    // MARK: - Filter Tests
    func testApplyDifficultyFilter_Easy()
    {
        // Given
        let mockRecipes = [
            RecipeModel.mock(difficulty: "Easy"),
            RecipeModel.mock(difficulty: "Hard")
        ]
        sut.recipesReceived = mockRecipes
        
        // When
        sut.applyDifficultyFilter("Easy")
        
        // Then
        XCTAssertTrue(sut.isSearching)
        XCTAssertEqual(sut.filteredRecipes.count, 1)
        XCTAssertEqual(sut.filteredRecipes.first?.difficulty, "Easy")
    }
    
    func testApplyDifficultyFilter_Clear()
    {
        // Given
        sut.recipesReceived = [RecipeModel.mock()]
        sut.isSearching = true
        sut.currentDifficultyFilter = "Easy"
        
        // When
        sut.applyDifficultyFilter("Clear")
        
        // Then
        XCTAssertFalse(sut.isSearching)
        XCTAssertNil(sut.currentDifficultyFilter)
        XCTAssertEqual(sut.filteredRecipes, sut.recipesReceived)
    }
    
    // MARK: - Collection View Tests
    func testCollectionViewDataSource() {
        // Given
        let mockRecipes = [RecipeModel.mock()]
        sut.recipesReceived = mockRecipes
        
        // When
        let cellCount = sut.collectionView(sut.collectionView, numberOfItemsInSection: 0)
        
        // Then
        XCTAssertEqual(cellCount, 1)
    }
    
    
//    func testRefreshControl_TriggersDataReload() async
//    {
//        // Given
//        let initialRecipes = [RecipeModel.mock(name: "Initial")]
//        let refreshedRecipes = [RecipeModel.mock(name: "Refreshed")]
//        sut.recipesReceived = initialRecipes
//        mockViewModel.mockRecipes = refreshedRecipes
//        
//        // When
//        await sut.refreshData()
//        
//        // Then
//        XCTAssertEqual(sut.recipesReceived, refreshedRecipes)
//        XCTAssertFalse(sut.refreshControl.isRefreshing)
//    }
    
    func testRefreshControl_ClearsFiltersAndSearch() async {
        // Given
        sut.currentDifficultyFilter = "Easy"
        sut.isSearching = true
        sut.topFilterView.searchTextBox.text = "search text"
        
        // When
        await sut.refreshData()
        
        // Then
        XCTAssertNil(sut.currentDifficultyFilter)
        XCTAssertFalse(sut.isSearching)
        XCTAssertEqual(sut.topFilterView.searchTextBox.text, "")
        XCTAssertEqual(sut.topFilterView.filterButton.title(for: .normal), "Filter")
    }
    
//    func testLoadingState_ShowsAndHidesIndicator() async {
//        // Given
//        mockViewModel.mockLoadingDelay = 0.1
//        
//        // When
//        let loadingTask = Task {
//            await sut.loadData()
//        }
//        
//        // Then - During Loading
//        XCTAssertTrue(sut.loadingIndicator.isAnimating)
//        
//        await loadingTask.value
//        
//        // Then - After Loading
//        XCTAssertFalse(sut.loadingIndicator.isAnimating)
//    }
//    
//    func testErrorState_ShowsEmptyStateView() async {
//        // Given
//        mockViewModel.mockError = .networkError(NSError(domain: "", code: -1))
//        
//        // When
//        await sut.loadData()
//        
//        // Then
//        XCTAssertNotNil(sut.emptyStateView)
//        XCTAssertTrue(sut.collectionView.isHidden)
//    }
//    
//    func testSuccessState_UpdatesUI() async {
//        // Given
//        let mockRecipes = [RecipeModel.mock()]
//        mockViewModel.mockRecipes = mockRecipes
//        
//        // When
//        await sut.loadData()
//        
//        // Then
//        XCTAssertFalse(sut.collectionView.isHidden)
//        XCTAssertNil(sut.emptyStateView)
//        XCTAssertEqual(sut.topFilterView.recipeCounter.text, "1 Recipes")
//    }
    
    func testRecipeSelection_PresentsDetailView() {
        // Given
        let mockRecipe = RecipeModel.mock()
        sut.recipesReceived = [mockRecipe]
        
        // When
        sut.collectionView(sut.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        
        // Then
        let presentedVC = sut.presentedViewController
        XCTAssertTrue(sut.view.subviews.last is UIView) // Container view
        XCTAssertTrue(sut.view.subviews.last?.subviews.last is RecipeDetailView)
    }
    
    func testDetailView_DismissesOnTap() {
        // Given
        sut.presentRecipeDetail(for: RecipeModel.mock())
        let containerView = sut.view.subviews.last
        
        // When
        sut.dismissPopup()
        
        // Then - Wait for animation
        let expectation = XCTestExpectation(description: "Dismiss animation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            XCTAssertNil(containerView?.superview)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
//    func testDataLoadTask_CancelsOnNewRequest() async {
//        // Given
//        let firstTask = Task {
//            await sut.loadData()
//        }
//        
//        // When
//        let secondTask = Task {
//            await sut.loadData()
//        }
//        
//        // Then
//        XCTAssertTrue(firstTask.isCancelled)
//        await secondTask.value
//    }
    
}

// MARK: - Mock Classes
class MockRecipeListViewModel: RecipeListViewModel
{
    var mockRecipes: [RecipeModel] = []
    var mockError: RecipeError?
    var mockLoadingDelay = 0.0
    
    override func fetchRecipes() async
    {
        if let error = mockError
        {
            self.error = error
            self.recipes = []
        }
        else
        {
            self.recipes = mockRecipes
        }
    }
}

extension RecipeModel {
    static func mock(
        name: String = "Test Recipe",
        cuisine: String = "Test Cuisine",
        difficulty: String = "Medium"
    ) -> RecipeModel {
        return RecipeModel(
            cuisine: cuisine,
            name: name,
            photoUrlLarge: "https://test.com/large.jpg",
            photoUrlSmall: "https://test.com/small.jpg",
            uuid: "test-uuid",
            sourceUrl: "https://test.com",
            youtubeUrl: "https://youtube.com/test",
            cookingTime: 30,
            difficulty: difficulty
        )
    }
}
