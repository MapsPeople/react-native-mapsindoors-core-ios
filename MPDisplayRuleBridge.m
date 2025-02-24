#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(DisplayRule, NSObject)
RCT_EXTERN_METHOD(requiresMainQueueSetup)
// End of head

    // GetterBridge isVisible->visible
    RCT_EXTERN_METHOD(isVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setVisible->visible
    RCT_EXTERN_METHOD(setVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge isIconVisible->iconVisible
    RCT_EXTERN_METHOD(isIconVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setIconVisible->iconVisible
    RCT_EXTERN_METHOD(setIconVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge isPolygonVisible->polygonVisible
    RCT_EXTERN_METHOD(isPolygonVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonVisible->polygonVisible
    RCT_EXTERN_METHOD(setPolygonVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge isLabelVisible->labelVisible
    RCT_EXTERN_METHOD(isLabelVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setLabelVisible->labelVisible
    RCT_EXTERN_METHOD(setLabelVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge isModel2DVisible->model2DVisible
    RCT_EXTERN_METHOD(isModel2DVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setModel2DVisible->model2DVisible
    RCT_EXTERN_METHOD(setModel2DVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge isWallVisible->wallsVisible
    RCT_EXTERN_METHOD(isWallVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setWallVisible->wallsVisible
    RCT_EXTERN_METHOD(setWallVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge isExtrusionVisible->extrusionVisible
    RCT_EXTERN_METHOD(isExtrusionVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setExtrusionVisible->extrusionVisible
    RCT_EXTERN_METHOD(setExtrusionVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getZoomFrom->zoomFrom
    RCT_EXTERN_METHOD(getZoomFrom: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setZoomFrom->zoomFrom
    RCT_EXTERN_METHOD(setZoomFrom: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getZoomTo->zoomTo
    RCT_EXTERN_METHOD(getZoomTo: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setZoomTo->zoomTo
    RCT_EXTERN_METHOD(setZoomTo: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getIconUrl->iconURL
    RCT_EXTERN_METHOD(getIconUrl: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setIcon->iconURL
    RCT_EXTERN_METHOD(setIcon: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getIconSize->iconSize
    RCT_EXTERN_METHOD(getIconSize: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setIconSize->iconSize
    RCT_EXTERN_METHOD(setIconSize: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getLabel->label
    RCT_EXTERN_METHOD(getLabel: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setLabel->label
    RCT_EXTERN_METHOD(setLabel: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getLabelZoomFrom->labelZoomFrom
    RCT_EXTERN_METHOD(getLabelZoomFrom: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setLabelZoomFrom->labelZoomFrom
    RCT_EXTERN_METHOD(setLabelZoomFrom: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getLabelZoomTo->labelZoomTo
    RCT_EXTERN_METHOD(getLabelZoomTo: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setLabelZoomTo->labelZoomTo
    RCT_EXTERN_METHOD(setLabelZoomTo: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getLabelMaxWidth->labelMaxWidth
    RCT_EXTERN_METHOD(getLabelMaxWidth: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setLabelMaxWidth->labelMaxWidth
    RCT_EXTERN_METHOD(setLabelMaxWidth: (NSString *) displayRuleId
                      value:(NSInteger) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getPolygonZoomFrom->polygonZoomFrom
    RCT_EXTERN_METHOD(getPolygonZoomFrom: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonZoomFrom->polygonZoomFrom
    RCT_EXTERN_METHOD(setPolygonZoomFrom: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getPolygonZoomTo->polygonZoomTo
    RCT_EXTERN_METHOD(getPolygonZoomTo: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonZoomTo->polygonZoomTo
    RCT_EXTERN_METHOD(setPolygonZoomTo: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getPolygonStrokeWidth->polygonStrokeWidth
    RCT_EXTERN_METHOD(getPolygonStrokeWidth: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonStrokeWidth->polygonStrokeWidth
    RCT_EXTERN_METHOD(setPolygonStrokeWidth: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getPolygonStrokeColor->polygonStrokeColor
    RCT_EXTERN_METHOD(getPolygonStrokeColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonStrokeColor->polygonStrokeColor
    RCT_EXTERN_METHOD(setPolygonStrokeColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getPolygonStrokeOpacity->polygonStrokeOpacity
    RCT_EXTERN_METHOD(getPolygonStrokeOpacity: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonStrokeOpacity->polygonStrokeOpacity
    RCT_EXTERN_METHOD(setPolygonStrokeOpacity: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getPolygonFillColor->polygonFillColor
    RCT_EXTERN_METHOD(getPolygonFillColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonFillColor->polygonFillColor
    RCT_EXTERN_METHOD(setPolygonFillColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getPolygonFillOpacity->polygonFillOpacity
    RCT_EXTERN_METHOD(getPolygonFillOpacity: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setPolygonFillOpacity->polygonFillOpacity
    RCT_EXTERN_METHOD(setPolygonFillOpacity: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getWallColor->wallsColor
    RCT_EXTERN_METHOD(getWallColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setWallColor->wallsColor
    RCT_EXTERN_METHOD(setWallColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getWallHeight->wallsHeight
    RCT_EXTERN_METHOD(getWallHeight: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setWallHeight->wallsHeight
    RCT_EXTERN_METHOD(setWallHeight: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getWallZoomFrom->wallsZoomFrom
    RCT_EXTERN_METHOD(getWallZoomFrom: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setWallZoomFrom->wallsZoomFrom
    RCT_EXTERN_METHOD(setWallZoomFrom: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getWallZoomTo->wallsZoomTo
    RCT_EXTERN_METHOD(getWallZoomTo: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setWallZoomTo->wallsZoomTo
    RCT_EXTERN_METHOD(setWallZoomTo: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getExtrusionColor->extrusionColor
    RCT_EXTERN_METHOD(getExtrusionColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setExtrusionColor->extrusionColor
    RCT_EXTERN_METHOD(setExtrusionColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getExtrusionHeight->extrusionHeight
    RCT_EXTERN_METHOD(getExtrusionHeight: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setExtrusionHeight->extrusionHeight
    RCT_EXTERN_METHOD(setExtrusionHeight: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getExtrusionZoomFrom->extrusionZoomFrom
    RCT_EXTERN_METHOD(getExtrusionZoomFrom: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setExtrusionZoomFrom->extrusionZoomFrom
    RCT_EXTERN_METHOD(setExtrusionZoomFrom: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getExtrusionZoomTo->extrusionZoomTo
    RCT_EXTERN_METHOD(getExtrusionZoomTo: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setExtrusionZoomTo->extrusionZoomTo
    RCT_EXTERN_METHOD(setExtrusionZoomTo: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getModel2DZoomFrom->model2DZoomFrom
    RCT_EXTERN_METHOD(getModel2DZoomFrom: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setModel2DZoomFrom->model2DZoomFrom
    RCT_EXTERN_METHOD(setModel2DZoomFrom: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getModel2DZoomTo->model2DZoomTo
    RCT_EXTERN_METHOD(getModel2DZoomTo: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setModel2DZoomTo->model2DZoomTo
    RCT_EXTERN_METHOD(setModel2DZoomTo: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getModel2DWidthMeters->model2DWidthMeters
    RCT_EXTERN_METHOD(getModel2DWidthMeters: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setModel2DWidthMeters->model2DWidthMeters
    RCT_EXTERN_METHOD(setModel2DWidthMeters: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getModel2DHeightMeters->model2DHeightMeters
    RCT_EXTERN_METHOD(getModel2DHeightMeters: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setModel2DHeightMeters->model2DHeightMeters
    RCT_EXTERN_METHOD(setModel2DHeightMeters: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getModel2DBearing->model2DBearing
    RCT_EXTERN_METHOD(getModel2DBearing: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setModel2DBearing->model2DBearing
    RCT_EXTERN_METHOD(setModel2DBearing: (NSString *) displayRuleId
                      value:(CGFloat) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // GetterBridge getModel2DModel->model2DModel
    RCT_EXTERN_METHOD(getModel2DModel: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // SetterBridge setModel2DModel->model2DModel
    RCT_EXTERN_METHOD(setModel2DModel: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBadgeFillColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeFillColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBadgeStrokeColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeStrokeColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBadgeRadius: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeRadius: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
        
    RCT_EXTERN_METHOD(getBadgeStrokeWidth: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeStrokeWidth: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBadgePosition: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgePosition: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getIconPlacement: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setIconPlacement: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelType: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelType: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStyleTextSize: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleTextSize: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
        
    RCT_EXTERN_METHOD(getLabelStyleTextColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleTextColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStyleHaloColor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleHaloColor: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStyleTextOpacity: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleTextOpacity: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStyleHaloWidth: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleHaloWidth: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStyleHaloBlur: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleHaloBlur: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStyleBearing: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleBearing: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStylePosition: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStylePosition: (NSString *) displayRuleId
                        value:(nonnull NSNumber *) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLabelStyleGraphic: (NSString *) displayRuleId
                      value:(NSString *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLabelStyleGraphic: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getPolygonLightnessFactor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setPolygonLightnessFactor: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getWallLightnessFactor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setWallLightnessFactor: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getExtrusionLightnessFactor: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setExtrusionLightnessFactor: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getIconScale: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setIconScale: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBadgeScale: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeScale: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBadgeZoomFrom: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeZoomFrom: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBadgeZoomTo: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeZoomTo: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(isBadgeVisible: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setBadgeVisible: (NSString *) displayRuleId
                      value:(BOOL) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getModel3DModel: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
    
    RCT_EXTERN_METHOD(setModel3DModel: (NSString *) displayRuleId
                        value:(NSString *) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)
    
    RCT_EXTERN_METHOD(getModel3DRotationX: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
    
    RCT_EXTERN_METHOD(setModel3DRotationX: (NSString *) displayRuleId
                      value:(nonnull NSNumber *) value
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getModel3DRotationY: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setModel3DRotationY: (NSString *) displayRuleId
                        value:(nonnull NSNumber *) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getModel3DRotationZ: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setModel3DRotationZ: (NSString *) displayRuleId
                        value:(nonnull NSNumber *) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getModel3DScale: (NSString *) displayRuleId
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setModel3DScale: (NSString *) displayRuleId
                        value:(nonnull NSNumber *) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)
    
    RCT_EXTERN_METHOD(getModel3DZoomFrom: (NSString *) displayRuleId
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setModel3DZoomFrom: (NSString *) displayRuleId
                        value:(nonnull NSNumber *) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)
    
    RCT_EXTERN_METHOD(getModel3DZoomTo: (NSString *) displayRuleId
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setModel3DZoomTo: (NSString *) displayRuleId
                        value:(nonnull NSNumber *) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(isModel3DVisible: (NSString *) displayRuleId
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setModel3DVisible: (NSString *) displayRuleId
                        value:(BOOL) value
                        resolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject)

// Start of tail

    RCT_EXTERN_METHOD(reset: (NSString *) displayRuleId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

@end
