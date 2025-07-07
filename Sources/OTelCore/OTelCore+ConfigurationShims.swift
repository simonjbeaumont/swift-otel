//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OTel open source project
//
// Copyright (c) 2025 the Swift OTel project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Logging
import Tracing

@available(macOSAligned 13, *)
extension OTelResource {
    package init(configuration: OTel.Configuration) {
        let attributes = configuration.resourceAttributes.mapValues { $0.toSpanAttribute() }
        self.init(attributes: SpanAttributes(attributes))
    }
}

@available(macOSAligned 13, *)
extension OTelBatchLogRecordProcessorConfiguration {
    package init(configuration: OTel.Configuration.LogsConfiguration.BatchLogRecordProcessorConfiguration) {
        self.init(
            environment: [:],
            maximumQueueSize: UInt(configuration.maxQueueSize),
            scheduleDelay: configuration.scheduleDelay,
            maximumExportBatchSize: UInt(configuration.maxExportBatchSize),
            exportTimeout: configuration.exportTimeout
        )
    }
}

@available(macOSAligned 13, *)
extension OTelPeriodicExportingMetricsReaderConfiguration {
    package init(configuration: OTel.Configuration.MetricsConfiguration) {
        self.init(
            environment: [:],
            exportInterval: configuration.exportInterval,
            exportTimeout: configuration.exportTimeout
        )
    }
}

@available(macOSAligned 13, *)
extension OTelBatchSpanProcessorConfiguration {
    package init(configuration: OTel.Configuration.TracesConfiguration.BatchSpanProcessorConfiguration) {
        self.init(
            environment: [:],
            maximumQueueSize: UInt(configuration.maxQueueSize),
            scheduleDelay: configuration.scheduleDelay,
            maximumExportBatchSize: UInt(configuration.maxExportBatchSize),
            exportTimeout: configuration.exportTimeout
        )
    }
}

@available(macOSAligned 13, *)
extension Logging.Logger.Level {
    package init(_ level: OTel.Configuration.LogLevel) {
        switch level.backing {
        case .error: self = .error
        case .warning: self = .warning
        case .info: self = .info
        case .debug: self = .debug
        case .trace: self = .trace
        }
    }
}
