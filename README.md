# CleanReversi

This is a reversi library and an app implemented in Swift applying [the Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html).

This repository does not include the layer of *Frameworks and Drivers*. Also, because business logics and presentation logics in this app are closely related to each other, both *Use Cases* and *Presenters* are implemented in one module: `CleanReversiApp`.

Relations between the modules in this package and the layers in the Clean Architecture are shown below.

- *Enterprise Business Rules*:
  - *Entities*: `CleanReversi`
- *Application Business Rules*:
  - *Use Cases*: `CleanReversiApp`
- *Interface Adapters*:
  - *Presenters*: `CleanReversiApp`
  - *Gateways*: `CleanReversiGateway`
- *Frameworks and Drivers*: does not included in this repo

The dependencies between the modules are specified as below in [Package.swift](Package.swift) to conform to the requirements of the Clean Architecture: *"source code dependencies can only point inwards"*.

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
