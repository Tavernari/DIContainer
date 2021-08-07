[![Swift](https://github.com/Tavernari/DIContainer/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/Tavernari/DIContainer/actions/workflows/swift.yml)

# 🏺 DIContainer Swift

It is an ultra-light dependency injection container made to help developers to handle dependencies easily.

## Registering dependencies

To register something on Container, you can use the InjectIdentifier directly or make an extension to create helpers to identify it.

### Using key directly

```Swift
Container.standard.register(.by(key: "some_key")) { _ in
    return SomeObjc()
}
```

### Using type directly

```Swift
Container.standard.register(.by(type: FetchService.self)) { _ in
    return GitHubService()
}
``` 

### Using type with key variants

```Swift
Container.standard.register(.by(type: FetchService.self, withKey: "github")) { _ in
    return GitHubService()
}

Container.standard.register(.by(type: FetchService.self, withKey: "gitlab")) { _ in
    return GitlabService()
}
```

### Resolving using other dependencies

```Swift
Container.standard.register(.gitlabService) { resolver in
    let externalService = resolver.resolve(.externalService)
    return GitlabService(externalService)
}
```

### Creating shortcuts to identify by extension

```Swift
extension InjectIdentifier {
    static var githubService: InjectIdentifier<FetchService> { .by(type: FetchService.self, withKey: "github") }
    static var gitlabService: InjectIdentifier<FetchService> { .by(type: FetchService.self, withKey: "gitlab") }
    static var externalService: InjectIdentifier<ExternalSingletonService> { .by(type: ExternalSingletonService.self) }
}
```

### Registering with shortcuts

```Swift
Container.standard.register(.githubService) { _ in
    
    GitHubService()
}

Container.standard.register(.gitlabService) { _ in
    
    GitlabService()
}

Container.standard.register(.externalService) { _ in
    
    ExternalSingletonService.shared
}
```

## Resolving dependencies

To resolve your dependencies, you have two ways. You can access the `Container` directly or use `@Injected` to do it automatically.

### Using resolve from Container

```Swift
let githubService = try? Container.standard.resolve(.githubService)
let gitlabService = try? Container.standard.resolve(.by(type: FetchService.self, withKey: "gitlab"))
let externalService = try? Container.standard.resolve(.by(type: ExternalSingletonService.self))
```

### Using injection with @propertyWrapper

If you use `@Injected` and have not injected yet, it will call `fatalError` with an error message. If you do not want this behavior, you should use `@InjectedSafe`, but using `@InjectedSafe`, you will get an optional result.

```Swift
@Injected(.githubService)
var githubService: FetchService

@Injected(.by(type: FetchService.self, withKey: "gitlab"))
var gitlabService: FetchService

@InjectedSafe
var externalService: ExternalSingletonService?
```

## Instalation

### Swift Package Manager

in `Package.swift` add the following:

```swift
dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/Tavernari/DIContainer", from: "0.1.0")
],
targets: [
    .target(
        name: "MyProject",
        dependencies: [..., "DIContainer"]
    )
    ...
]
```

### Cocoapds

```ruby
pod 'DIContainer-swift', '~> 0.1.0'
```
