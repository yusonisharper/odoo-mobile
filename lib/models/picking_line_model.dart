class PickingLineModel {
  //String pickingLocation;
  int id;
  String displayName;
  double quantity;
  bool picked;

  PickingLineModel({
    //required this.pickingLocation,
    required this.id,
    required this.displayName,
    required this.quantity,
    required this.picked,
  });
}

class PickingLine {
  List pickingLineList;
  PickingLine({required this.pickingLineList}) {
    getLocations();
  }
  List uniqueLocationList = [];

  List<dynamic> getLocations() {
    String tempLoc;
    for (Map line in pickingLineList) {
      tempLoc = line['location_id'][1];
      if (!uniqueLocationList.contains(tempLoc)) {
        uniqueLocationList.add(tempLoc);
      }
    }
    return uniqueLocationList;
  }

  List<PickingLineModel> getPickingLines(String currLocation) {
    List<PickingLineModel> pickingLines = [];
    for (Map line in pickingLineList) {
      if (currLocation == line['location_id'][1]) {
        pickingLines.add(PickingLineModel(
            id: line['id'],
            displayName: line['display_name'],
            quantity: line['quantity'],
            picked: line['picked']));
      }
    }
    return pickingLines;
  }

  void setPickingLine(int? id, bool bo) {
    for (Map line in pickingLineList) {
      if (id == line['id']) {
        line['picked'] = bo;
      }
    }
  }

  bool isAllPicked() {
    bool picked = true;
    for (Map line in pickingLineList) {
      if (!line['picked']) {
        picked = false;
        break;
      }
    }
    return picked;
  }
}
