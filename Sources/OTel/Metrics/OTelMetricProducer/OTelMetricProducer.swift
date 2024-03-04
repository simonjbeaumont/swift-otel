//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OTel open source project
//
// Copyright (c) 2024 Moritz Lang and the Swift OTel project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// A bridge from third-party metric sources, so they can be plugged into an OpenTelemetry MetricReader as a source of
/// aggregated metric data.
///
/// - Seealso: [](https://github.com/open-telemetry/opentelemetry-specification/blob/v1.29.0/specification/metrics/sdk.md#metricproducer)
@_spi(Metrics)
public protocol OTelMetricProducer: Sendable {
    /// Provides metrics from the MetricProducer to the caller.
    ///
    /// - Returns: a batch of metric points.
    /// - Seealso: [](https://github.com/open-telemetry/opentelemetry-specification/blob/v1.29.0/specification/metrics/sdk.md#produce-batch)
    /// - TODO: Consider adding metrics filter parameter (experimental in OTel 1.29.0)
    func produce() -> [OTelMetricPoint]

//    @_spi(Experimental)
//    func produce(filter: OTelMetricFilter) -> [OTelMetricPoint]
}

@_spi(Metrics)
@_spi(Experimental)
public struct OTelMetricFilterResult {
    private enum Result {
        case accept
        case drop
        case acceptPartial
    }
    private var result: Result
    public static let accept = Self(result: .accept)
    public static let drop = Self(result: .drop)
    public static let acceptPartial = Self(result: .acceptPartial)
}

@_spi(Metrics)
@_spi(Experimental)
public struct OTelAttributesFilterResult {
    private enum Result {
        case accept
        case drop
    }
    private var result: Result
    public static let accept = Self(result: .accept)
    public static let drop = Self(result: .drop)
}

@_spi(Metrics)
@_spi(Experimental)
public struct OTelMetricStreamKind {
    private enum Kind {
        case sum
        case gauge
        case histogram
    }
    private var kind: Kind
    public static let sum = Self(kind: .sum)
    public static let gauge = Self(kind: .gauge)
    public static let histogram = Self(kind: .histogram)
}


@_spi(Metrics)
@_spi(Experimental)
public protocol OTelMetricFilter: Sendable {
    func testMetric(
        instrumentationScope: String,
        name: String,
        kind: OTelMetricStreamKind,
        unit: String
    ) -> OTelMetricFilterResult

    func testAttributes(
        instrumentationScope: String,
        name: String,
        kind: OTelMetricStreamKind,
        unit: String,
        attributes: Set<OTelAttribute>
    ) -> OTelAttributesFilterResult
}
