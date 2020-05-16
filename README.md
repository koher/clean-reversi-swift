# CleanReversi

This is a reversi library and an app implemented in Swift applying [the Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html).

This repository does not include the layer of *Frameworks and Drivers*. Check [koher/clean-reversi-ios](https://github.com/koher/clean-reversi-ios) (iOS) and [koher/clean-reversi-macos](https://github.com/koher/clean-reversi-macos) (macOS) for the implementations of the layer.

Also, *CleanReversi* simplifies some parts of the Clean Architecture. For example, some parts of *Presenters* and *Controllers* are implemented in the `CleanReversiApp` which mainly implements *Use Cases* because the cost to implement them in different modules is too much compared to the benefit.

Relations between the modules in this package and the layers in the Clean Architecture are shown below.

- *Enterprise Business Rules*:
  - *Entities*: `CleanReversi`
- *Application Business Rules*:
  - *Use Cases*: `CleanReversiApp`
- *Interface Adapters*:
  - *Presenters*: `CleanReversiApp`
  - *Controllers*: `CleanReversiApp`
  - *Gateways*: `CleanReversiGateway`
- *Frameworks and Drivers*: does not included in this repo

Though some layers are omitted, *the Dependency Rule* applies strictly. The dependencies between the modules are specified as below in [Package.swift](Package.swift) to conform to the requirements: *"source code dependencies can only point inwards"*.

```swift
.target(
    name: "CleanReversi",
    dependencies: []),
...
.target(
    name: "CleanReversiApp",
    dependencies: ["CleanReversi", ...]),
.target(
    name: "CleanReversiGateway",
    dependencies: ["CleanReversiApp"]),
```

## LICENSE

[MIT License](LICENSE)
