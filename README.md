# 🏺 Slight DI Container

It is an ultra-light dependency injection container made to help developers to handle dependencies easily.

## Registering dependencies

To register something on container you can use directy the InjectIdentifier, or you can make an extension to create helpers to identify it.

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

### Creating shortcuts to identify by extension

```Swift
extension InjectIdentifier {
    static var githubService: InjectIdentifier<FetchService> { .by(type: FetchService.self, withKey: "github") }
    static var gitlabService: InjectIdentifier<FetchService> { .by(type: FetchService.self, withKey: "gitlab") }
    static var externalService: InjectIdentifier<ExternalSingletonService> { .by(type: ExternalSingletonService.self) }
}
```

Registering with shortcuts

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

To resolve your dependencies you have two ways, you can access the `Container` directly or you can use `@Injected` to do it automaticly.

### Using resolve from Container

```Swift
let githubService = try? Container.standard.resolve(.githubService)
let gitlabService = try? Container.standard.resolve(.by(type: FetchService.self, withKey: "gitlab"))
let externalService = try? Container.standard.resolve(.by(type: ExternalSingletonService.self))
```

### Using injection with @propertyWrapper

If you use `@Injected` and not have injected yet, it will call `fatalError` with an error message, if you do not want this behaviour you should use `@InjectedSafe`, but using `@InjectedSafe` you will get an optional result.

```Swift
@Injected(.githubService)
var githubService: FetchService

@Injected(.by(type: FetchService.self, withKey: "gitlab"))
var gitlabService: FetchService

@InjectedSafe
var externalService: ExternalSingletonService?
```
