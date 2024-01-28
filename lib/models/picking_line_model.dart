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

  List<dynamic> getLocations() {
    List uniqueLocationList = [];
    String tempLoc;
    for (Map line in pickingLineList) {
      tempLoc = line['location_id'][1];
      if (!uniqueLocationList.contains(tempLoc)) {
        uniqueLocationList.add(tempLoc);
      }
    }
    uniqueLocationList.sort();
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
    pickingLines.sort((a, b) => a.displayName.compareTo(b.displayName));
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

  int getLineCount() {
    return pickingLineList.length;
  }

  int getPickedLineCount() {
    int count = 0;
    for (Map line in pickingLineList) {
      if (line['picked']) {
        count++;
      }
    }
    return count;
  }
}
