import org.locationtech.jts.geom.util.LinearComponentExtracter
import qupath.lib.objects.PathDetectionObject
import qupath.lib.objects.PathObject
import qupath.lib.regions.ImageRegion

import java.util.stream.Collectors

import static qupath.lib.gui.scripting.QPEx.*

setImageType('OTHER');

selectAnnotations();
clearSelectedObjects(true)

resetSelection();
def area_threshold = 1000.0
createDetectionsFromPixelClassifier("Vessel ID", area_threshold, 0.0, "SPLIT", "SELECT_NEW")

removeObjects(getDetectionObjects().findAll{it.getPathClass().toString().contains("not_vessel")},true)

// Define the distance in pixels from an annotation boundary
// Zero is a valid option for 'touching'

createFullImageAnnotation(true)
double distancePixels = 0.0

// Toggle whether to use the 'hierarchy' rule, i.e. only consider detections with centroids inside an annotation
boolean useHierarchyRule = false

// Get parent annotations
def hierarchy = getCurrentHierarchy()
def annotations = hierarchy.getAnnotationObjects()

// Loop through detections
def toRemove = new HashSet<PathObject>()
for (def annotation in annotations) {
    def roi = annotation.getROI()
    if (roi == null)
        continue // Shouldn't actually happen...
    Collection<? extends PathObject> detections
    if (useHierarchyRule)
        // Warning! This decides based upon centroids (the 'normal' hierarchy rule)
        detections = hierarchy.getObjectsForRegion(PathDetectionObject.class, ImageRegion.createInstance(roi), null)
    else
        // This uses bounding boxes (the 'normal' hierarchy rule)
        detections = hierarchy.getObjectsForROI(PathDetectionObject.class, roi)
    // We need to get separate line strings for each polygon (since otherwise we get distances of zero when inside)
    def geometry = roi.getGeometry()
    for (def line in LinearComponentExtracter.getLines(geometry)) {
        toRemove.addAll(
                detections.parallelStream()
                        .filter(d -> line.isWithinDistance(d.getROI().getGeometry(), distancePixels))
                        .collect(Collectors.toList())
        )
    }
}


def newClass = getPathClass("part")

toRemove.each { object ->
    object.setPathClass(newClass)
}

def detections = getDetectionObjects()
def newAnnotations = detections.collect {
    return PathObjects.createAnnotationObject(it.getROI(), it.getPathClass())
}

removeObjects(detections, true)
addObjects(newAnnotations)

getCurrentHierarchy().getSelectionModel(). setSelectedObjects(annotations, null)
addShapeMeasurements("AREA", "LENGTH", "CIRCULARITY")

selectAnnotations();
runPlugin('qupath.lib.plugins.objects.FillAnnotationHolesPlugin', '{}')
