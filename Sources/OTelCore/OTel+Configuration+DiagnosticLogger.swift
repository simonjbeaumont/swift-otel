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

package import Logging

extension OTel.Configuration {
    package func diagnosticsLogger(component: String) -> Logger {
        var logger = switch self.logger.backing {
        case .console:
            Logger(label: "swift-otel", factory: { label in StreamLogHandler.standardError(label: label) })
        case .custom(let logger):
            logger
        }
        logger.logLevel = Logger.Level(self.logLevel)
        return logger
    }
}

fileprivate extension Logger.Level {
    init(_ level: OTel.Configuration.LogLevel) {
        switch level.backing {
        case .debug:
            self = .debug
        case .info:
            self = .info
        case .warning:
            self = .warning
        case .error:
            self = .error
        }
    }
}
