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

import class Foundation.ProcessInfo
package import Logging
import NIOConcurrencyHelpers

@available(macOSAligned 13, *)
extension OTel {
    fileprivate static let lockedDiagnosticsLogger = NIOLockedValueBox(Logger(label: "swift-otel", factory: { label in StreamLogHandler.standardError(label: label) }))
    package static var diagnosticsLogger: Logger {
        get {
            lockedDiagnosticsLogger.withLockedValue { $0 }
        }
        set {
            lockedDiagnosticsLogger.withLockedValue { $0 = newValue }
        }
    }
}

@available(macOSAligned 13, *)
extension OTel.Configuration {
    package var _diagnosticLogger: Logger {
        var logger = switch self.diagnosticLogger.backing {
        case .console:
            Logger(label: "swift-otel", factory: { label in StreamLogHandler.standardError(label: label) })
        case .custom(let logger):
            logger
        }
        // Environment variable overrides may not have been applied, so we explicitly check here.
        logger.logLevel = Self.logLevelEnvironmentOverride ?? Logger.Level(self.diagnosticLogLevel)
        return logger
    }

    fileprivate static let logLevelEnvironmentOverride: Logger.Level? = {
        switch ProcessInfo.processInfo.environment.getStringValue(.logLevel) {
        case "trace": .trace
        case "debug": .debug
        case "info": .info
        case "notice": .notice
        case "warning": .warning
        case "error": .error
        case "critical": .critical
        default: nil
        }
    }()
}

@available(macOSAligned 13, *)
extension Logger {
    package init(configuration: OTel.Configuration) {
        self = switch configuration.diagnosticLogger.backing {
        case .console:
            Logger(label: "swift-otel", factory: { label in StreamLogHandler.standardError(label: label) })
        case .custom(let logger):
            logger
        }
        // Environment variable overrides may not have been applied, so we explicitly check here.
        self.logLevel = Self.logLevelEnvironmentOverride ?? Logger.Level(configuration.diagnosticLogLevel)
    }

    fileprivate static let logLevelEnvironmentOverride: Logger.Level? = {
        switch ProcessInfo.processInfo.environment.getStringValue(.logLevel) {
        case "trace": .trace
        case "debug": .debug
        case "info": .info
        case "notice": .notice
        case "warning": .warning
        case "error": .error
        case "critical": .critical
        default: nil
        }
    }()
}
