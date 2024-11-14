import UIKit
import SwiftUI
import WebKit

class MainScreenViewController: UIViewController
{
    private var viewModel: RecipeListViewModel
    var recipesReceived: [RecipeModel] = [] //Received from the viewModel
    var filteredRecipes: [RecipeModel] = [] //For Search Results
    private var dataLoadTask: Task<Void, Never>?
    
    let topFilterView = TopDisplayView()
    let refreshControl = UIRefreshControl()
    var emptyStateView: EmptyStateView?
    
    var collectionView: UICollectionView!
    
    var isSearching = false  // To keep track of whether search is active
    var currentDifficultyFilter: String?  //Keep track of the current difficulty
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: RecipeListViewModel = RecipeListViewModel())
    {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor
        
        setUpNavigationBar()
        configureViews()
        configureCollectionView()
        setupRefreshControl()
        
        setupDismissKeyboardGesture()
        setupTextFieldDelegates()
        configureFilterButton()
        
        loadData()
        
    }
    
    private func setUpNavigationBar()
    {
        let titleLabel = UILabel()
        titleLabel.text = "Recipes"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = Colors.textColor
        
        // Create a container view for left alignment title
        let containerView = UIView()
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Set as navigation item's titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
    
    func configureViews()
    {
        view.addSubview(topFilterView)
        topFilterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topFilterView.heightAnchor.constraint(equalToConstant: 125)
        ])
    }
    
    func configureCollectionView()
    {
        // Calculate item width for 2 columns
        let spacing: CGFloat = 16 // Space between cells
        let horizontalInset: CGFloat = 16 // Left and right edge insets
        let totalHorizontalSpacing = horizontalInset * 2 + spacing // Total horizontal spacing
        let itemWidth = (UIScreen.main.bounds.width - totalHorizontalSpacing) / 2
        
        let layout = UICollectionViewFlowLayout()

        // Set item size (making it square or adjust height as needed)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.3) // Adjust multiplier for desired height
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10 // Spacing between rows
        layout.minimumInteritemSpacing = 10 // Spacing between items
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delaysContentTouches = false
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        collectionView.backgroundView = loadingIndicator
        
        collectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: "RecipeCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topFilterView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func loadData()
    {
        dataLoadTask?.cancel()
        dataLoadTask = Task 
        {
            await viewModel.fetchRecipes()
            await MainActor.run 
            {
                handleDataLoadResult()
            }
        }
    }
    
    func setupDismissKeyboardGesture()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard()
    {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    private func setupTextFieldDelegates()
    {
        topFilterView.searchTextBox.delegate = self
    }
    
    private func configureFilterButton()
    {
        
        topFilterView.filterButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        
    }
    
    @objc func filterButtonPressed()
    {
        topFilterView.searchTextBox.resignFirstResponder()  // Dismiss the keyboard
        let filterView = FilterPopupView(currentFilter: currentDifficultyFilter)
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        filterView.onFilterSelected = { [weak self] difficulty in
            self?.applyDifficultyFilter(difficulty)
            self?.dismissPopup()
        }
        
        view.addSubview(containerView)
        containerView.addSubview(filterView)
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filterView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            filterView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            filterView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
        ])
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    func applyDifficultyFilter(_ difficulty: String) 
    {
        if difficulty == "Clear"
        {
            currentDifficultyFilter = nil
            topFilterView.filterButton.setTitle("Filter", for: .normal)
            isSearching = false
            filteredRecipes = recipesReceived
            
            // Reapply search if active
            if let searchText = topFilterView.searchTextBox.text, !searchText.isEmpty 
            {
                isSearching = true
                filteredRecipes = recipesReceived.filter { recipe in
                    let matchesName = recipe.name.lowercased().contains(searchText.lowercased())
                    let matchesCuisine = recipe.cuisine.lowercased().contains(searchText.lowercased())
                    return matchesName || matchesCuisine //Display both of the results
                }
            }
        } 
        else 
        {
            // Apply new filter
            currentDifficultyFilter = difficulty
            topFilterView.filterButton.setTitle(difficulty, for: .normal)
            isSearching = true
            
            // Apply both difficulty and search filters if search is active
            if let searchText = topFilterView.searchTextBox.text, !searchText.isEmpty 
            {
                filteredRecipes = recipesReceived.filter { recipe in
                    let matchesDifficulty = recipe.difficulty == difficulty
                    let matchesName = recipe.name.lowercased().contains(searchText.lowercased())
                    let matchesCuisine = recipe.cuisine.lowercased().contains(searchText.lowercased())
                    let matchesSearch = matchesName || matchesCuisine // Use OR operator
                    return matchesDifficulty && matchesSearch
                }
            } 
            else
            {
                // Apply only difficulty filter
                filteredRecipes = recipesReceived.filter { $0.difficulty == difficulty }
            }
        }
        
        DispatchQueue.main.async 
        {
            self.collectionView.reloadData()
            if self.isSearching {
                self.topFilterView.recipeCounter.text = "\(self.filteredRecipes.count) Recipes"
            } else {
                self.topFilterView.recipeCounter.text = "\(self.recipesReceived.count) Recipes"
            }
        }
    }
    
    private func setupRefreshControl()
    {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        // Customize appearance
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(
            string: "Pull to refresh",
            attributes: [
                .foregroundColor: Colors.textColor,
                .font: UIFont.systemFont(ofSize: 12)
            ]
        )
        
        collectionView.refreshControl = refreshControl
    }
    
    @objc func refreshData()
    {
        // Reset filters
        currentDifficultyFilter = nil
        topFilterView.filterButton.setTitle("Filter", for: .normal)
        topFilterView.searchTextBox.text = ""
        isSearching = false
        
        // Reload data
        Task
        {
            await viewModel.fetchRecipes()
            await MainActor.run {
                self.recipesReceived = viewModel.recipes
                self.filteredRecipes = []
                self.collectionView.reloadData()
                self.topFilterView.recipeCounter.text = "\(self.recipesReceived.count) Recipes"
                self.refreshControl.endRefreshing() // Stop the refresh animation
            }
        }
    }
    
    private func handleDataLoadResult()
    {
        // Remove existing empty state view if any
        emptyStateView?.removeFromSuperview()
        
        if let error = viewModel.error 
        {
            switch error 
            {
            case .emptyList:
                showEmptyState(
                    title: "No Recipes Available",
                    message: "Check back later for delicious recipes!",
                    showRetryButton: true
                )
            case .malformedData:
                showEmptyState(
                    title: "Something Went Wrong",
                    message: "We're having trouble loading the recipes. Please try again.",
                    showRetryButton: true
                )
            case .networkError:
                showEmptyState(
                    title: "Connection Error",
                    message: "Please check your internet connection and try again.",
                    showRetryButton: true
                )
            }
            
            // Hide collection view
            collectionView.isHidden = true
            topFilterView.recipeCounter.text = "0 Recipes"
            
        } 
        else
        {
            // Show data
            self.recipesReceived = viewModel.recipes
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
            self.topFilterView.recipeCounter.text = "\(self.recipesReceived.count) Recipes"
        }
    }
    
    private func showEmptyState(title: String, message: String, showRetryButton: Bool = true)
    {
        let emptyView = EmptyStateView(title: title, message: message, showRetryButton: showRetryButton)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.onRetryTapped = { [weak self] in
            self?.loadData()
        }
        
        view.addSubview(emptyView)
        self.emptyStateView = emptyView
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: topFilterView.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func presentRecipeDetail(for recipe: RecipeModel) 
    {
        // Create and present popup
        let detailView = RecipeDetailView(recipe: recipe)
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.addSubview(detailView)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            detailView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            detailView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            detailView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),
            detailView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5)
        ])
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() 
    {
        super.didReceiveMemoryWarning()
        ImageLoader.shared.clearMemoryCache()
    }
    
    deinit
    {
        dataLoadTask?.cancel()
    }
    
}

extension MainScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredRecipes.count : recipesReceived.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath) as? RecipeCollectionViewCell else { return UICollectionViewCell()}
        
        let recipe = isSearching ? filteredRecipes[indexPath.row] : recipesReceived[indexPath.row]
        cell.configure(with: recipe)
        switch cell.difficultyTagView.title.text
        {
        case "Hard":
            cell.difficultyTagView.backgroundColor = .red
        case "Medium":
            cell.difficultyTagView.backgroundColor = .yellow
        case "Easy":
            cell.difficultyTagView.backgroundColor = .green
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionView.deselectItem(at: indexPath, animated: true)
            
        let selectedRecipe = isSearching ? filteredRecipes[indexPath.row] : recipesReceived[indexPath.row]
        presentRecipeDetail(for: selectedRecipe)
    }
    
    @objc func dismissPopup()
    {
        if let containerView = view.subviews.last 
        {
            UIView.animate(withDuration: 0.3) {
                containerView.alpha = 0
            } completion: { _ in
                containerView.removeFromSuperview()
            }
        }
    }
    
}

extension MainScreenViewController: UICollectionViewDataSourcePrefetching 
{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let recipe = isSearching ? filteredRecipes[indexPath.row] : recipesReceived[indexPath.row]
            if let urlString = recipe.photoUrlLarge {
                Task {
                    try? await ImageLoader.shared.loadImage(from: urlString)
                }
            }
        }
    }
}
extension MainScreenViewController: UISearchBarDelegate
{
    // Called when the search button on the keyboard is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)  // Dismiss the keyboard
        if let searchText = topFilterView.searchTextBox.text, !searchText.isEmpty {
            isSearching = true
            filteredRecipes = recipesReceived.filter { recipe in
                let matchesName = recipe.name.lowercased().contains(searchText.lowercased())
                let matchesCuisine = recipe.cuisine.lowercased().contains(searchText.lowercased())
                return matchesName || matchesCuisine // Use OR operator instead of AND
            }
        } else {
            isSearching = false
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.topFilterView.recipeCounter.text = "\(self.filteredRecipes.count) Recipes"
        }
    }

    
    // Called whenever the text in the search bar changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = currentDifficultyFilter != nil
            filteredRecipes = currentDifficultyFilter != nil ?
                recipesReceived.filter { $0.difficulty == currentDifficultyFilter } :
                recipesReceived
        } 
        else 
        {
            isSearching = true
            filteredRecipes = recipesReceived.filter { recipe in
                let matchesName = recipe.name.lowercased().contains(searchText.lowercased())
                let matchesCuisine = recipe.cuisine.lowercased().contains(searchText.lowercased())
                let matchesSearch = matchesName || matchesCuisine // Use OR operator here
                let matchesDifficulty = currentDifficultyFilter == nil || recipe.difficulty == currentDifficultyFilter
                return matchesSearch && matchesDifficulty
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.topFilterView.recipeCounter.text = "\(self.filteredRecipes.count) Recipes"
        }
    }
    
    // Called when the cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        topFilterView.searchTextBox.text = ""
        searchBar.resignFirstResponder()  // Dismiss the keyboard
        isSearching = false
        filteredRecipes = recipesReceived // Reset the search
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.topFilterView.recipeCounter.text = "\(self.filteredRecipes.count) Recipes"
        }
    }

}
