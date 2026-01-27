import Testing
@testable import DIContainer

/// End-to-End tests demonstrating the complete "magical" DI workflow.
/// These tests use actual macro-generated code patterns to simulate real usage.
@Suite("AutoDI_E2E_Tests", .serialized)
struct AutoDI_E2E_Tests {
    
    // MARK: - Real-World E2E Scenario
    
    /// Complete E2E test simulating a real app architecture:
    /// - Repository layer (data access)
    /// - Service layer (business logic)  
    /// - ViewModel layer (presentation)
    /// All using the "magical" auto-registration pattern.
    @Test func completeAppArchitectureE2E() throws {
        // 1. Bootstrap all dependencies at "app launch"
        Container.standard.bootstrap(
            UserRepositoryImpl.self,
            AuthServiceImpl.self,
            AnalyticsServiceImpl.self,
            LoginViewModelImpl.self
        )
        
        // 2. Resolve the top-level ViewModel (like SwiftUI would)
        let viewModel: LoginViewModel = try Container.standard.resolve(type: LoginViewModel.self)
        
        // 3. Verify the entire dependency chain works
        let result = viewModel.login(email: "test@example.com", password: "secret123")
        
        #expect(result.success == true)
        #expect(result.message == "User test@example.com authenticated successfully")
        #expect(result.analyticsTracked == true)
    }
    
    /// E2E test with circular dependencies resolved via lazy injection
    @Test func circularDependencyE2E() throws {
        // Bootstrap services that reference each other
        Container.standard.bootstrap(
            NotificationServiceImpl.self,
            UserSessionServiceImpl.self
        )
        
        // Resolve NotificationService
        let notificationService: NotificationService = try Container.standard.resolve(type: NotificationService.self)
        
        // Call method that uses the circular dependency
        let message = notificationService.sendWelcomeNotification()
        
        #expect(message == "Welcome, Guest! Your notifications are enabled.")
    }
    
    /// E2E test with keyed dependencies (multiple implementations)
    @Test func keyedDependenciesE2E() throws {
        // Register different storage implementations with keys
        Container.standard.register(type: StorageService.self, key: "local") { _ in
            LocalStorageService()
        }
        Container.standard.register(type: StorageService.self, key: "cloud") { _ in
            CloudStorageService()
        }
        
        // Resolve using keys
        let local: StorageService = try Container.standard.resolve(.by(type: StorageService.self, key: "local"))
        let cloud: StorageService = try Container.standard.resolve(.by(type: StorageService.self, key: "cloud"))
        
        #expect(local.save("data") == "Saved to local: data")
        #expect(cloud.save("data") == "Saved to cloud: data")
    }
    
    /// E2E test: resolveAll with real service types
    @Test func resolveAllRealServicesE2E() throws {
        // Register real services
        Container.standard.bootstrap(
            UserRepositoryImpl.self,
            AnalyticsServiceImpl.self
        )
        
        // Resolve multiple at once (like a factory would)
        let (repo, analytics): (UserRepository, AnalyticsService) = try Container.standard.resolveAll()
        
        #expect(repo.findUser(email: "test@test.com") != nil)
        #expect(analytics.track(event: "test") == true)
    }
}

// MARK: - Protocols (Domain Layer)

protocol UserRepository {
    func findUser(email: String) -> User?
    func authenticate(email: String, password: String) -> Bool
}

protocol AuthService {
    func login(email: String, password: String) -> AuthResult
}

protocol AnalyticsService {
    func track(event: String) -> Bool
}

protocol LoginViewModel {
    func login(email: String, password: String) -> LoginResult
}

protocol NotificationService {
    func sendWelcomeNotification() -> String
}

protocol UserSessionService {
    func getCurrentUser() -> String
}

protocol StorageService {
    func save(_ data: String) -> String
}

// MARK: - Models

struct User {
    let email: String
    let name: String
}

struct AuthResult {
    let success: Bool
    let user: User?
}

struct LoginResult {
    let success: Bool
    let message: String
    let analyticsTracked: Bool
}

// MARK: - Implementations with AutoRegistrable

struct UserRepositoryImpl: UserRepository, AutoRegistrable {
    func findUser(email: String) -> User? {
        User(email: email, name: "Test User")
    }
    
    func authenticate(email: String, password: String) -> Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: UserRepository.self) { _ in
            UserRepositoryImpl()
        }
    }
}

struct AuthServiceImpl: AuthService, AutoRegistrable {
    let userRepository: UserRepository
    
    func login(email: String, password: String) -> AuthResult {
        if userRepository.authenticate(email: email, password: password) {
            return AuthResult(success: true, user: userRepository.findUser(email: email))
        }
        return AuthResult(success: false, user: nil)
    }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: AuthService.self) { c in
            let repo: UserRepository = try c.resolveAll()
            return AuthServiceImpl(userRepository: repo)
        }
    }
}

struct AnalyticsServiceImpl: AnalyticsService, AutoRegistrable {
    func track(event: String) -> Bool {
        true // Always succeeds in test
    }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: AnalyticsService.self) { _ in
            AnalyticsServiceImpl()
        }
    }
}

struct LoginViewModelImpl: LoginViewModel, AutoRegistrable {
    let authService: AuthService
    let analytics: AnalyticsService
    
    func login(email: String, password: String) -> LoginResult {
        let result = authService.login(email: email, password: password)
        let tracked = analytics.track(event: "login_attempt")
        
        if result.success {
            return LoginResult(
                success: true,
                message: "User \(email) authenticated successfully",
                analyticsTracked: tracked
            )
        }
        return LoginResult(success: false, message: "Login failed", analyticsTracked: tracked)
    }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: LoginViewModel.self) { c in
            let (auth, analytics): (AuthService, AnalyticsService) = try c.resolveAll()
            return LoginViewModelImpl(authService: auth, analytics: analytics)
        }
    }
}

// MARK: - Circular Dependency Implementations

class NotificationServiceImpl: NotificationService, AutoRegistrable {
    @Injected(.by(type: UserSessionService.self)) var sessionService: UserSessionService
    
    func sendWelcomeNotification() -> String {
        "Welcome, \(sessionService.getCurrentUser())! Your notifications are enabled."
    }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: NotificationService.self) { _ in
            NotificationServiceImpl()
        }
    }
}

class UserSessionServiceImpl: UserSessionService, AutoRegistrable {
    @Injected(.by(type: NotificationService.self)) var notificationService: NotificationService
    
    func getCurrentUser() -> String {
        "Guest"
    }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: UserSessionService.self) { _ in
            UserSessionServiceImpl()
        }
    }
}

// MARK: - Keyed Storage Implementations

struct LocalStorageService: StorageService {
    func save(_ data: String) -> String {
        "Saved to local: \(data)"
    }
}

struct CloudStorageService: StorageService {
    func save(_ data: String) -> String {
        "Saved to cloud: \(data)"
    }
}
