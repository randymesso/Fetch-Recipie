import UIKit


extension UIImageView 
{
    // Use NSObject wrapper for the Task
    private class TaskWrapper 
    {
        var task: Task<Void, Never>
        
        init(task: Task<Void, Never>) {
            self.task = task
        }
    }
    
    // Use the wrapper in the map table
    private static let loadingTasks = NSMapTable<UIImageView, TaskWrapper>.weakToStrongObjects()
    
    func loadImage(from urlString: String) 
    {
        // Cancel any existing load task for this image view
        if let existingWrapper = UIImageView.loadingTasks.object(forKey: self) {
            existingWrapper.task.cancel()
        }
        
        // Create new loading task
        let task = Task 
        {
            do
            {
                let image = try await ImageLoader.shared.loadImage(from: urlString)
                
                // Check if task was cancelled
                if !Task.isCancelled
                {
                    await MainActor.run 
                    {
                        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve)
                        {
                            self.image = image
                        }
                    }
                }
            } 
            catch
            {
                if !Task.isCancelled 
                {
                    await MainActor.run
                    {
                        // Set placeholder image
                        self.image = UIImage(systemName: "photo.fill")
                    }
                }
            }
            
            UIImageView.loadingTasks.removeObject(forKey: self)
        }
        
        // Wrap the task before storing
        let wrapper = TaskWrapper(task: task)
        UIImageView.loadingTasks.setObject(wrapper, forKey: self)
    }
}
