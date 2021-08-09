[![Swift](https://github.com/Tavernari/DIContainer/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/Tavernari/DIContainer/actions/workflows/swift.yml)

# 🏺 DIContainer Swift

It is an ultra-light dependency injection container made to help developers to handle dependencies easily.
We know that handle with dependency injection is hard and generates boilerplate code a lot. 
The main idea of this lib is to keep it simples and light, it should be direct and intuitive, even using the property wrapper.

#### What is Dependency Injection?

> The intent behind dependency injection is to achieve separation of concerns of construction and use of objects. This can increase readability and code reuse.
> Dependency injection is one form of the broader technique of inversion of control. A client who wants to call some services should not have to know how to construct those services. Instead, the client delegates to external code (the injector). The client is not aware of the injector.[2] The injector passes the services, which might exist or be constructed by the injector itself, to the client. The client then uses the services.
Font - [Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection)

#### What is DI Container?

> IoC Container (a.k.a. DI Container) is a framework for implementing automatic dependency injection. It manages object creation and it's life-time, and also injects dependencies to the class.
> The IoC container creates an object of the specified class and also injects all the dependency objects through a constructor, a property or a method at run time and disposes it at the appropriate time. This is done so that we don't have to create and manage objects manually.
Font - [tutorialsteacher](https://www.tutorialsteacher.com/ioc/ioc-container)

## Registering dependencies

To register something on Container, you can use the InjectIdentifier directly or make an extension to create helpers to identify it.

### Using key directly

```Swift
Container.standard.register(.by(key: "some_key")) { _ in SomeObjc() }
```

### Using type directly

```Swift
Container.standard.register(.by(type: FetchService.self)) { _ in GitHubService() }
``` 

### Using type with key variants

```Swift
Container.standard.register(.by(type: FetchService.self, key: "github")) { _ in GitHubService() }

Container.standard.register(.by(type: FetchService.self, key: "gitlab")) { _ in GitlabService() }
```

### Resolving using other dependencies

```Swift
Container.standard.register(.gitlabService) { resolver in

    let externalService = try resolver.resolve(.externalService)
    return GitlabService(externalService)
}
```

### Creating shortcuts to identify by extension

```Swift
extension InjectIdentifier {

    static var githubService: InjectIdentifier<FetchService> { .by(type: FetchService.self, key: "github") }
    static var gitlabService: InjectIdentifier<FetchService> { .by(type: FetchService.self, key: "gitlab") }
    static var externalService: InjectIdentifier<ExternalSingletonService> { .by(type: ExternalSingletonService.self) }
}
```

### Registering with shortcuts

```Swift
Container.standard.register(.githubService) { _ in GitHubService() }

Container.standard.register(.gitlabService) { _ in GitlabService() }

Container.standard.register(.externalService) { _ in ExternalSingletonService.shared }
```

## Resolving dependencies

To resolve your dependencies, you have two ways. You can access the `Container` directly or use `@Injected` to do it automatically.

### Using resolve from Container

```Swift
let githubService = try? Container.standard.resolve(.githubService)
let gitlabService = try? Container.standard.resolve(.by(type: FetchService.self, key: "gitlab"))
let externalService = try? Container.standard.resolve(.by(type: ExternalSingletonService.self))
```

### Using injection with @propertyWrapper

If you use `@Injected` and have not injected yet, it will call `fatalError` with an error message. If you do not want this behavior, you should use `@InjectedSafe`, but using `@InjectedSafe`, you will get an optional result.

```Swift
@Injected(.githubService)
var githubService: FetchService

@InjectedSafe(.by(type: FetchService.self, key: "gitlab"))
var gitlabService: FetchService?

@Injected
var externalService: ExternalSingletonService
```

## Instalation

### Swift Package Manager

in `Package.swift` add the following:

```swift
dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/Tavernari/DIContainer", from: "0.2.0")
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
pod 'DIContainer-swift', '~> 0.2.0'
```
