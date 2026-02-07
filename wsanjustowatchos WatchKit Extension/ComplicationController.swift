//
//  ComplicationController.swift
//  wsanjustowatchos WatchKit Extension
//
//  Created by mgarciate on 12/6/22.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "wsanjusto-ios", supportedFamilies: CLKComplicationFamily.allCases)
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Fetch current temperature data
        Task {
            do {
                let measure = try await NetworkService<Measure>().get(endpoint: "weather/current")
                let template = self.createTemplate(for: complication.family, with: measure)
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(entry)
            } catch {
                print("Error fetching temperature: \(error)")
                // Return a placeholder template on error
                let template = self.createPlaceholderTemplate(for: complication.family)
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(entry)
            }
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler(nil)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let template = createSampleTemplate(for: complication.family)
        handler(template)
    }
    
    // MARK: - Template Creation
    
    private func createTemplate(for family: CLKComplicationFamily, with measure: Measure) -> CLKComplicationTemplate {
        let temperature = String(format: "%.1f°", measure.sensorTemperature1)
        
        switch family {
        case .modularSmall:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: temperature)
            )
            
        case .modularLarge:
            return CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Temperatura"),
                body1TextProvider: CLKSimpleTextProvider(text: temperature)
            )
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: temperature)
            )
            
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "Temp: \(temperature)")
            )
            
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: temperature)
            )
            
        case .extraLarge:
            return CLKComplicationTemplateExtraLargeSimpleText(
                textProvider: CLKSimpleTextProvider(text: temperature)
            )
            
        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerStackText(
                innerTextProvider: CLKSimpleTextProvider(text: "°C"),
                outerTextProvider: CLKSimpleTextProvider(text: String(format: "%.1f", measure.sensorTemperature1))
            )
            
        case .graphicBezel:
            let circularTemplate = CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: String(format: "%.1f", measure.sensorTemperature1)),
                line2TextProvider: CLKSimpleTextProvider(text: "°C")
            )
            
            return CLKComplicationTemplateGraphicBezelCircularText(
                circularTemplate: circularTemplate,
                textProvider: CLKSimpleTextProvider(text: "Temperatura")
            )
            
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: String(format: "%.1f", measure.sensorTemperature1)),
                line2TextProvider: CLKSimpleTextProvider(text: "°C")
            )
            
        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Temperatura"),
                body1TextProvider: CLKSimpleTextProvider(text: temperature)
            )
            
        case .graphicExtraLarge:
            if #available(watchOSApplicationExtension 7.0, *) {
                return CLKComplicationTemplateGraphicExtraLargeCircularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: String(format: "%.1f", measure.sensorTemperature1)),
                    line2TextProvider: CLKSimpleTextProvider(text: "°C")
                )
            } else {
                return CLKComplicationTemplateModularSmallSimpleText(
                    textProvider: CLKSimpleTextProvider(text: temperature)
                )
            }
            
        @unknown default:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: temperature)
            )
        }
    }
    
    private func createPlaceholderTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate {
        let placeholder = "--°"
        
        switch family {
        case .modularSmall:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: placeholder)
            )
            
        case .modularLarge:
            return CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Temperatura"),
                body1TextProvider: CLKSimpleTextProvider(text: placeholder)
            )
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: placeholder)
            )
            
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "Temp: \(placeholder)")
            )
            
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: placeholder)
            )
            
        case .extraLarge:
            return CLKComplicationTemplateExtraLargeSimpleText(
                textProvider: CLKSimpleTextProvider(text: placeholder)
            )
            
        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerStackText(
                innerTextProvider: CLKSimpleTextProvider(text: "°C"),
                outerTextProvider: CLKSimpleTextProvider(text: "--")
            )
            
        case .graphicBezel:
            let circularTemplate = CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "--"),
                line2TextProvider: CLKSimpleTextProvider(text: "°C")
            )
            
            return CLKComplicationTemplateGraphicBezelCircularText(
                circularTemplate: circularTemplate,
                textProvider: CLKSimpleTextProvider(text: "Temperatura")
            )
            
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "--"),
                line2TextProvider: CLKSimpleTextProvider(text: "°C")
            )
            
        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Temperatura"),
                body1TextProvider: CLKSimpleTextProvider(text: placeholder)
            )
            
        case .graphicExtraLarge:
            if #available(watchOSApplicationExtension 7.0, *) {
                return CLKComplicationTemplateGraphicExtraLargeCircularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "--"),
                    line2TextProvider: CLKSimpleTextProvider(text: "°C")
                )
            } else {
                return CLKComplicationTemplateModularSmallSimpleText(
                    textProvider: CLKSimpleTextProvider(text: placeholder)
                )
            }
            
        @unknown default:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: placeholder)
            )
        }
    }
    
    private func createSampleTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate {
        let sampleTemp = "21.5°"
        
        switch family {
        case .modularSmall:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: sampleTemp)
            )
            
        case .modularLarge:
            return CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Temperatura"),
                body1TextProvider: CLKSimpleTextProvider(text: sampleTemp)
            )
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: sampleTemp)
            )
            
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: CLKSimpleTextProvider(text: "Temp: \(sampleTemp)")
            )
            
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: sampleTemp)
            )
            
        case .extraLarge:
            return CLKComplicationTemplateExtraLargeSimpleText(
                textProvider: CLKSimpleTextProvider(text: sampleTemp)
            )
            
        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerStackText(
                innerTextProvider: CLKSimpleTextProvider(text: "°C"),
                outerTextProvider: CLKSimpleTextProvider(text: "21.5")
            )
            
        case .graphicBezel:
            let circularTemplate = CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "21.5"),
                line2TextProvider: CLKSimpleTextProvider(text: "°C")
            )
            
            return CLKComplicationTemplateGraphicBezelCircularText(
                circularTemplate: circularTemplate,
                textProvider: CLKSimpleTextProvider(text: "Temperatura")
            )
            
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "21.5"),
                line2TextProvider: CLKSimpleTextProvider(text: "°C")
            )
            
        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "Temperatura"),
                body1TextProvider: CLKSimpleTextProvider(text: sampleTemp)
            )
            
        case .graphicExtraLarge:
            if #available(watchOSApplicationExtension 7.0, *) {
                return CLKComplicationTemplateGraphicExtraLargeCircularStackText(
                    line1TextProvider: CLKSimpleTextProvider(text: "21.5"),
                    line2TextProvider: CLKSimpleTextProvider(text: "°C")
                )
            } else {
                return CLKComplicationTemplateModularSmallSimpleText(
                    textProvider: CLKSimpleTextProvider(text: sampleTemp)
                )
            }
            
        @unknown default:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: sampleTemp)
            )
        }
    }
}
