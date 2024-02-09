// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "swift-otel-counter-example",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(name: "swift-otel", path: "../../"),

        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.4.1"),
        .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "1.0.0"),

        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.2"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "CounterExample",
            dependencies: [
                .product(name: "OTel", package: "swift-otel"),
                .product(name: "OTLPGRPC", package: "swift-otel"),

                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),

                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
            ]
        ),
    ]
)
