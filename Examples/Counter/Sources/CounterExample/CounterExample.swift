//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OTel open source project
//
// Copyright (c) 2023 Moritz Lang and the Swift OTel project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import AsyncAlgorithms
import Atomics
import Logging
import Metrics
@_spi(Metrics) import OTel
@_spi(Metrics) import OTLPGRPC
import ServiceLifecycle
import Tracing

@main
enum CounterExample {
    static func main() async throws {
        // Bootstrap the logging backend with the OTel metadata provider which includes span IDs in logging messages.
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardError(label: label, metadataProvider: .otel)
            handler.logLevel = .trace
            return handler
        }

        // Configure OTel resource detection to automatically apply helpful attributes to events.
        let environment = OTelEnvironment.detected()
        let resourceDetection = OTelResourceDetection(detectors: [
            OTelProcessResourceDetector(),
            OTelEnvironmentResourceDetector(environment: environment),
            .manual(OTelResource(attributes: ["service.name": "counter"])),
        ])
        let resource = await resourceDetection.resource(environment: environment, logLevel: .trace)

        // Bootstrap the metrics backend to export metrics periodically in OTLP/gRPC.
        let registry = OTelMetricRegistry()
        let metricsExporter = try OTLPGRPCMetricExporter(configuration: .init(environment: environment))
        let metrics = OTelPeriodicExportingMetricsReader(
            resource: resource,
            producer: registry,
            exporter: metricsExporter,
            configuration: .init(
                environment: environment,
                exportInterval: .seconds(5) // NOTE: This is overridden for the example; the default is 60 seconds.
            )
        )
        MetricsSystem.bootstrap(OTLPMetricsFactory(registry: registry))

        // Bootstrap the tracing backend to export traces periodically in OTLP/gRPC.
        let exporter = try OTLPGRPCSpanExporter(configuration: .init(environment: environment))
        let processor = OTelBatchSpanProcessor(exporter: exporter, configuration: .init(environment: environment))
        let tracer = OTelTracer(
            idGenerator: OTelRandomIDGenerator(),
            sampler: OTelConstantSampler(isOn: true),
            propagator: OTelW3CPropagator(),
            processor: processor,
            environment: environment,
            resource: resource
        )
        InstrumentationSystem.bootstrap(tracer)

        let counter = CounterService(errorProbability: 0.1)

        try await ServiceGroup(
            services: [metrics, tracer, counter],
            gracefulShutdownSignals: [.sigint],
            logger: Logger(label: "CounterServiceGroup")
        ).run()
    }
}

struct CounterService: Service, CustomStringConvertible {
    let description = "CounterService"

    let counter: ManagedAtomic<Int>
    let errorProbability: Double
    let logger: Logger

    init(errorProbability: Double) {
        counter = .init(0)
        self.errorProbability = errorProbability
        logger = Logger(label: description)
    }

    func run() async {
        let ticks = AsyncTimerSequence(interval: .seconds(1), clock: .continuous).cancelOnGracefulShutdown()
        for await _ in ticks {
            withSpan("count") { span in
                guard .random(in: 0 ... 1) > errorProbability else {
                    logger.error("Failed to increment counter")
                    span.recordError(CounterError.failedIncrementing(value: counter.load(ordering: .relaxed)))
                    span.setStatus(.init(code: .error))
                    return
                }

                let newValue = counter.wrappingIncrementThenLoad(ordering: .relaxed)
                span.attributes["new_value"] = newValue
                logger.info("Incremented counter.", metadata: ["new_value": "\(newValue)"])
                Counter(label: "example_counter").increment()
                Gauge(label: "example_gauge").record(Double.random(in: 0 ..< 10))
                Recorder(label: "example_recorder").record(Int.random(in: 0 ..< 10))
                Timer(label: "example_timer").recordMilliseconds(Int.random(in: 50 ... 500))
            }
        }
    }
}

enum CounterError: Error {
    case failedIncrementing(value: Int)
}
