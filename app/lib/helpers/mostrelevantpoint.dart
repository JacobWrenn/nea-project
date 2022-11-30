getMostRelevantPoint(details) {
  dynamic rPoint = details[0];
  bool prevWasTrue = true;
  for (var point in details) {
    if (point["completed"] == null) point["completed"] = false;
    if (prevWasTrue && !point["completed"]) {
      rPoint = point;
      prevWasTrue = false;
    } else if (point["completed"]) {
      prevWasTrue = true;
    }
  }
  return rPoint;
}
