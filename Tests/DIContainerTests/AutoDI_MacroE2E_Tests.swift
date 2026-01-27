import Testing
import DIContainer

/// End-to-End tests using REAL macro tags.
/// This file demonstrates the complete "magical" workflow with @AutoRegister and @AutoInjected.
@Suite("AutoDI_MacroE2E_Tests", .serialized)
struct AutoDI_MacroE2E_Tests {
    
    // MARK: - E2E with Different Init Parameter Counts
    
    /// E2E test with ZERO parameters init
    @Test func e2eWithZeroParameters() throws {
        Container.standard.bootstrap(ConfigService.self)
        
        let config: ConfigProtocol = try Container.standard.resolve(type: ConfigProtocol.self)
        #expect(config.getEnvironment() == "production")
    }
    
    /// E2E test with ONE parameter init
    @Test func e2eWithOneParameter() throws {
        Container.standard.bootstrap(
            ConfigService.self,
            LoggerService.self
        )
        
        let logger: LoggerProtocol = try Container.standard.resolve(type: LoggerProtocol.self)
        #expect(logger.log("test") == "[production] test")
    }
    
    /// E2E test with THREE parameters init
    @Test func e2eWithThreeParameters() throws {
        Container.standard.bootstrap(
            ConfigService.self,
            LoggerService.self,
            DatabaseService.self,
            AppService.self
        )
        
        let app: AppProtocol = try Container.standard.resolve(type: AppProtocol.self)
        let result = app.run()
        
        #expect(result.contains("Config: production"))
        #expect(result.contains("Logger: ready"))
        #expect(result.contains("DB: connected"))
    }
    
    /// Complete E2E: Chain with 0, 1, and 3 params working together
    @Test func completeChainE2E() throws {
        Container.standard.bootstrap(
            ConfigService.self,      // 0 params
            LoggerService.self,      // 1 param
            DatabaseService.self,    // 1 param
            AppService.self          // 3 params
        )
        
        let app: AppProtocol = try Container.standard.resolve(type: AppProtocol.self)
        
        // Verify the entire chain works
        #expect(app.run() == "App running | Config: production | Logger: ready | DB: connected")
    }
    
    /// E2E with @AutoInjected for lazy/circular dependencies
    @Test func circularE2EWithMacros() throws {
        Container.standard.bootstrap(
            ServiceX.self,
            ServiceY.self
        )
        
        let x: ProtocolX = try Container.standard.resolve(type: ProtocolX.self)
        #expect(x.callY() == "Y says: Hello from X")
    }
}

// MARK: - Protocols

/// Config - no dependencies (0 params)
protocol ConfigProtocol {
    func getEnvironment() -> String
}

/// Logger - depends on Config (1 param)
protocol LoggerProtocol {
    func log(_ message: String) -> String
}

/// Database - depends on Config (1 param)
protocol DatabaseProtocol {
    func isConnected() -> Bool
}

/// App - depends on Config, Logger, Database (3 params)
protocol AppProtocol {
    func run() -> String
}

protocol ProtocolX {
    func getName() -> String
    func callY() -> String
}

protocol ProtocolY {
    func respond(to message: String) -> String
}

// MARK: - Implementations with @AutoRegister

/// ZERO parameters - no dependencies
@AutoRegister(ConfigProtocol.self)
struct ConfigService: ConfigProtocol {
    init() {}
    
    func getEnvironment() -> String {
        "production"
    }
}

/// ONE parameter - depends on Config
@AutoRegister(LoggerProtocol.self)
struct LoggerService: LoggerProtocol {
    let config: ConfigProtocol
    
    init(config: ConfigProtocol) {
        self.config = config
    }
    
    func log(_ message: String) -> String {
        "[\(config.getEnvironment())] \(message)"
    }
}

/// ONE parameter - depends on Config
@AutoRegister(DatabaseProtocol.self)
struct DatabaseService: DatabaseProtocol {
    let config: ConfigProtocol
    
    init(config: ConfigProtocol) {
        self.config = config
    }
    
    func isConnected() -> Bool {
        true
    }
}

/// THREE parameters - depends on Config, Logger, Database
@AutoRegister(AppProtocol.self)
struct AppService: AppProtocol {
    let config: ConfigProtocol
    let logger: LoggerProtocol
    let database: DatabaseProtocol
    
    init(config: ConfigProtocol, logger: LoggerProtocol, database: DatabaseProtocol) {
        self.config = config
        self.logger = logger
        self.database = database
    }
    
    func run() -> String {
        let configStatus = "Config: \(config.getEnvironment())"
        let loggerStatus = "Logger: ready"
        let dbStatus = "DB: \(database.isConnected() ? "connected" : "disconnected")"
        return "App running | \(configStatus) | \(loggerStatus) | \(dbStatus)"
    }
}

// MARK: - Circular Dependency with @AutoInjected

@AutoRegister(ProtocolX.self)
class ServiceX: ProtocolX {
    @AutoInjected var y: ProtocolY
    
    init() {}
    
    func getName() -> String { "X" }
    
    func callY() -> String {
        y.respond(to: "Hello from X")
    }
}

@AutoRegister(ProtocolY.self)
class ServiceY: ProtocolY {
    @AutoInjected var x: ProtocolX
    
    init() {}
    
    func respond(to message: String) -> String {
        "Y says: \(message)"
    }
}
