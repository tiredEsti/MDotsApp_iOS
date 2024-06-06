//
//  ChartView.swift
//  MDots
//
//  Created by Estela Alvarez on 22/4/24.
//
import SwiftUI
import Charts

/// Struct representing data for a line chart.
struct LineChartData {
    
    var id = UUID()
    var date: Date
    var value: Double
    
    var type: LineChartType
}

/// Enum representing different types of line charts.
enum LineChartType: String, CaseIterable, Plottable {
    case optimal = "Optimal"
    case outside = "Outside range"
    
    var color: Color {
        switch self {
        case .optimal: return .green
        case .outside: return .blue
        }
    }
    
}

/// Converts MovementData array to LineChartData array.
/// - Parameter movementData: Array of MovementData.
/// - Returns: Array of LineChartData.
func convertToLineChartData(movementData: [MovementData]) -> [LineChartData] {
    return movementData.map { movementData in
        return LineChartData(date: movementData.testDate, value: movementData.value, type: .outside)
    }
}

/// Formats a double value to a string with two decimal places.
/// - Parameter value: Double value.
/// - Returns: Formatted string.
func formatDouble(value: Double) -> String {
    return String(format: "%.2f", value)
}

/// View representing the chart.
struct ChartView: View {
    private let chartDataS: [LineChartData]
    private let chartDataR: [LineChartData]
    private let chartDataL: [LineChartData]
    private let chartDataRi: [LineChartData]
    private let chartDataLi: [LineChartData]
    private let chartDataRe: [LineChartData]
    private let chartDataLe: [LineChartData]
    private var allCharts : [String] = []
    private var allColors : [Color] = []


    /// Initializes the view with movement data.
    /// - Parameter data: Array of MovementData.    
    init(data: [MovementData]) {
        
        var dataDict: [String: [MovementData]] = [
            "S": [],
            "R": [],
            "L": [],
            "Ri": [],
            "Li": [],
            "Re": [],
            "Le": []
        ]
        for movementData in data {
            let side = movementData.side
            if dataDict[side] != nil {
                dataDict[side]?.append(movementData)
            } else {
                dataDict["S"]?.append(movementData)
            }
        }
       
       self.chartDataS = convertToLineChartData(movementData: dataDict["S"] ?? [])
       self.chartDataR = convertToLineChartData(movementData: dataDict["R"] ?? [])
       self.chartDataL = convertToLineChartData(movementData: dataDict["L"] ?? [])
       self.chartDataRi = convertToLineChartData(movementData: dataDict["Ri"] ?? [])
       self.chartDataLi = convertToLineChartData(movementData: dataDict["Li"] ?? [])
       self.chartDataRe = convertToLineChartData(movementData: dataDict["Re"] ?? [])
       self.chartDataLe = convertToLineChartData(movementData: dataDict["Le"] ?? [])
        
        // Check which charts are not empty and add the name and color to allCharts and allColors
        if !chartDataS.isEmpty {
            allCharts.append("Single")
            allColors.append(Color.blue) // Add the corresponding color
        }
        if !chartDataR.isEmpty {
            allCharts.append("Right")
            allColors.append(Color.green) 
        }
        if !chartDataL.isEmpty {
            allCharts.append("Left")
            allColors.append(Color.red)
        }
        if !chartDataRi.isEmpty {
            allCharts.append("Right Internal Rotation")
            allColors.append(Color.green)
        }
        if !chartDataLi.isEmpty {
            allCharts.append("Left Internal Rotation")
            allColors.append(Color.red)
        }
        if !chartDataRe.isEmpty {
            allCharts.append("Right External Rotation")
            allColors.append(Color.teal)
        }
        if !chartDataLe.isEmpty {
            allCharts.append("Left External Rotation")
            allColors.append(Color.orange)
        }
   
    }
    
    var body: some View {
        
        VStack {
            Text("Angle measurements by date")
                .font(.system(size: 16, weight: .medium))
            
            HStack {
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)){
                    Text("Euler degrees")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(-90))
                        .padding(.leading, -30)
                    
                    /*
                    Chart {
                        // Single
                        if !chartDataS.isEmpty {
                            ForEach(chartDataS, id: \.id) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("Single", "s")
                                )
                                .foregroundStyle(.blue)
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value)
                                )
                                .foregroundStyle(.blue)
                                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                    Text(formatDouble(value: item.value))
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        // Left
                        if !chartDataL.isEmpty {
                            ForEach(chartDataL, id: \.id) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("Left", "l")
                                )
                                .foregroundStyle(.red)
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value)
                                )
                                .foregroundStyle(.red)
                                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                    Text(formatDouble(value: item.value))
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        // Right
                        if !chartDataR.isEmpty {
                            ForEach(chartDataR, id: \.id) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("Right", "r")
                                )
                                .foregroundStyle(.green)
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value)
                                )
                                .foregroundStyle(.green)
                                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                    Text(formatDouble(value: item.value))
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        // Left Interior
                        if !chartDataLi.isEmpty {
                            ForEach(chartDataLi, id: \.id) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("Left Interior", "li")
                                )
                                .foregroundStyle(.red)
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value)
                                )
                                .foregroundStyle(.red)
                                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                    Text(formatDouble(value: item.value))
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        // Left Exterior
                        if (!chartDataLe.isEmpty) {
                            ForEach(chartDataLe, id: \.id) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("Left Exterior", "le")
                                )
                                .foregroundStyle(.orange)
                                .foregroundStyle(.secondary)
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value)
                                )
                                .foregroundStyle(.orange)
                                .foregroundStyle(.secondary)
                                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                    Text(formatDouble(value: item.value))
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        // Right Interior
                        if (!chartDataRi.isEmpty) {
                            ForEach(chartDataRi, id: \.id) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("Right Interior", "ri")
                                )
                                .foregroundStyle(.green)
                                .foregroundStyle(.secondary)
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value)
                                )
                                .foregroundStyle(.green)
                                .foregroundStyle(.secondary)
                                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                    Text(formatDouble(value: item.value))
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        // Right Exterior
                        if (!chartDataRe.isEmpty) {
                            ForEach(chartDataRe, id: \.id) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("Right Exterior", "re")
                                )
                                .foregroundStyle(.teal)
                                .foregroundStyle(.tertiary)
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value)
                                )
                                .foregroundStyle(.teal)
                                .foregroundStyle(.tertiary)
                                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                                    Text(formatDouble(value: item.value))
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 7)) { value in
                            AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                            AxisValueLabel() {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue) º")
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                    .chartForegroundStyleScale(
                        domain: allCharts,
                        range: allColors
                    )
                    .padding(.trailing, 20)
                    .padding(.leading, 20) */
                    Chart {
                        createLineMark(chartData: chartDataS, seriesName: "Single", color: .blue)
                        createLineMark(chartData: chartDataR, seriesName: "Right", color: .green)
                        createLineMark(chartData: chartDataL, seriesName: "Left", color: .red)
                        createLineMark(chartData: chartDataRi, seriesName: "Right Internal Rotation", color: .green)
                        createLineMark(chartData: chartDataLi, seriesName: "Left Internal Rotation", color: .red)
                        createLineMark(chartData: chartDataRe, seriesName: "Right External Rotation", color: .teal)
                        createLineMark(chartData: chartDataLe, seriesName: "Left External Rotation", color: .orange)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 7)) { value in
                            AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                            AxisValueLabel() {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue) º")
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                    .chartForegroundStyleScale(
                        domain: allCharts,
                        range: allColors
                    )
                    .padding(.trailing, 20)
                    .padding(.leading, 20)

                }
            
            }
        }
        //.frame(height: 360)
    }

    /// Creates a LineMark for the chart.
    /// - Parameters:
    ///   - item: The LineChartData item.
    ///   - seriesName: The series name.
    ///   - color: The color for the line and points.
    /// - Returns: A LineMark view.
    @ChartContentBuilder
    private func createLineMark(chartData: [LineChartData], seriesName: String, color: Color) -> some ChartContent {
        if (!chartData.isEmpty) {
            ForEach(chartData, id: \.id) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value),
                    series: .value(seriesName, seriesName)
                )
                .foregroundStyle(color)
                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(color)
                .annotation(position: .overlay, alignment: .bottom, spacing: 10) {
                    Text(formatDouble(value: item.value))
                        .font(.footnote)
                }
            }
        }
    }
}

