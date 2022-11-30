const query = require("../query").query

async function getOnTrain(trainid) {
  return (await query(`SELECT a.goodid, b.locationid, c.origin, c.destination, g.goodtype, g.number, c.bookingid
  FROM loading a
  INNER JOIN good g
  ON g.goodid = a.goodid
  INNER JOIN booking c
  ON c.bookingid = g.bookingid
  LEFT JOIN loading b
  ON a.trainid = b.trainid AND a.goodid = b.goodid AND b.unload = true
  WHERE a.trainid = $1 AND a.unload = false AND a.completed = true AND (b.completed = false OR b.completed IS NULL);
  `, [trainid])).rows
}

async function create(type, id, volume) {
  return (await query(`INSERT INTO good (goodtype, bookingid, number, received, handedover, complete)
  VALUES ($1, $2, $3, false, false, false)
  RETURNING goodid;
  `, [type, id, volume])).rows[0]
}

async function confirmReceived(goodid) {
  return await query(`UPDATE good
  SET received = true
  WHERE goodid = $1;
  `, [goodid])
}

async function confirmHandedOver(goodid) {
  return await query(`UPDATE good
  SET handedover = true
  WHERE goodid = $1;
  `, [goodid])
}

async function confirmComplete(goodid) {
  return await query(`UPDATE good
  SET completed = true
  WHERE goodid = $1;
  `, [goodid])
}

async function getAt(locationid) {
  return (await query(`SELECT g.goodid, c.time
  FROM good g
  INNER JOIN loading l
  ON l.goodid = g.goodid
  INNER JOIN booking b
  ON b.bookingid = g.bookingid
  LEFT JOIN loading x
  ON x.locationid = l.locationid AND x.goodid = l.goodid AND x.unload = false
  LEFT JOIN train t
  ON t.trainid = x.trainid
  LEFT JOIN call c
  ON c.scheduleid = t.scheduleid AND c.locationid = x.locationid
  WHERE CURRENT_DATE IN (SELECT date FROM plannedloading p WHERE g.goodid = p.goodid) AND ((l.completed = true AND l.locationid = $1 AND g.handedover <> true AND (x.completed <> true OR x.completed IS NULL) AND l.unload = true)
  OR (b.origin = l.locationid AND l.locationid = $1 AND g.received = true AND g.goodid NOT IN (
    SELECT goodid FROM loading WHERE goodid = g.goodid AND completed = true)));
  `, [locationid])).rows
}

async function getDue(locationid) {
  return (await query(`SELECT g.goodid, c.time
  FROM good g
  INNER JOIN booking b
  ON g.bookingid = b.bookingid
  INNER JOIN plannedloading p
  ON b.origin = p.locationid and g.goodid = p.goodid
  INNER JOIN call c
  ON c.scheduleid = p.scheduleid AND c.locationid = p.locationid
  WHERE g.received = false AND b.origin = $1 AND CURRENT_DATE = p.date;
  `, [locationid])).rows
}

async function getDetails(goodid) {
  return (await query(`SELECT s.name, b.destination, g.received, g.handedover, g.complete, g.goodtype, g.number, l.completed, p.unload, x.name AS name2, d.name AS name3, c.time, p.date, t.trainid, x.locationid
  FROM good g
  INNER JOIN plannedloading p
  ON p.goodid = g.goodid
  LEFT JOIN loading l
  ON g.goodid = l.goodid AND p.locationid = l.locationid AND l.unload = p.unload
  INNER JOIN booking b
  ON b.bookingid = g.bookingid
  INNER JOIN location s
  ON s.locationid = b.origin
  INNER JOIN location x
  ON x.locationid = p.locationid
  INNER JOIN (
    SELECT c.locationid, c.scheduleid
    FROM call c
    INNER JOIN (
      SELECT scheduleid, MAX(time) FROM call GROUP BY scheduleid
    ) c2
    ON c2.max = c.time AND c2.scheduleid = c.scheduleid
  ) y
  ON y.scheduleid = p.scheduleid
  INNER JOIN location d
  ON y.locationid = d.locationid
  INNER join call c
  ON c.scheduleid = p.scheduleid AND p.locationid = c.locationid
  LEFT JOIN train t
  ON t.trainid = l.trainid AND t.date = CURRENT_DATE
  WHERE g.goodid = $1;
  `, [goodid])).rows
}

async function cancelLoadings(goodid) {
  return await query(`DELETE FROM loading
  WHERE goodid = $1 AND completed = false;
  `, [goodid])
}

async function cancelPlannedLoadings(goodid) {
  return await query(`DELETE FROM plannedloading p
  USING (
    SELECT p.goodid, p.locationid, p.unload
    FROM plannedloading p
    LEFT JOIN loading l
    ON p.goodid = l.goodid AND l.locationid = p.locationid AND p.unload = l.unload
    WHERE p.goodid = $1 AND (l.completed = false OR l.completed IS NULL)
  ) x
  WHERE x.goodid = p.goodid AND p.locationid = x.locationid AND p.unload = x.unload;
  `, [goodid])
}

module.exports = { getOnTrain, create, confirmComplete, confirmHandedOver, confirmReceived, getAt, getDue, getDetails, cancelLoadings, cancelPlannedLoadings }