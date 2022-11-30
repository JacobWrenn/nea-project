const query = require("../query").query

async function create(scheduleid) {
  return (await query(`INSERT INTO train (scheduleid, iscancelled, date)
  VALUES ($1, false, CURRENT_DATE)
  RETURNING trainid;
  `, [scheduleid])).rows[0]
}

async function transferLoadings(scheduleid, trainid) {
  return await query(`INSERT INTO loading (trainid, locationid, goodid, unload, completed)
  SELECT $1, locationid, goodid, unload, false
  FROM plannedloading
  WHERE scheduleid = $2 AND date = CURRENT_DATE;
  `, [trainid, scheduleid])
}

async function transferTimings(scheduleid, trainid) {
  return await query(`INSERT INTO timings (trainid, locationid, scheduleid, delay)
  SELECT $1, locationid, scheduleid, 0
  FROM call
  WHERE scheduleid = $2;
  `, [trainid, scheduleid])
}

async function getDue(locationid) {
  return (await query(`SELECT t.trainid, c.time, y.name
  FROM train t
  INNER JOIN schedule s
  ON t.scheduleid = s.scheduleid
  INNER JOIN call c
  ON c.scheduleid = t.scheduleid
  INNER JOIN timings d
  ON d.trainid = t.trainid AND c.locationid = d.locationid
  INNER JOIN (
    SELECT c.locationid, c.scheduleid
    FROM call c
    INNER JOIN (
      SELECT scheduleid, MAX(time) FROM call GROUP BY scheduleid
    ) c2
    ON c2.max = c.time AND c2.scheduleid = c.scheduleid
  ) x
  ON x.scheduleid = t.scheduleid
  INNER JOIN location y
  ON y.locationid = x.locationid
  WHERE c.locationid = $1 AND CURRENT_DATE = t.date;
  `, [locationid])).rows
}

async function cancel(trainid) {
  return await query(`UPDATE train
  SET iscancelled = true
  WHERE train.trainid = $1
  `, [trainid])
}

async function appendDelay(trainid, delay) {
  return await query(`UPDATE timings
  SET delay = delay + $2
  WHERE trainid = $1;
  `, [trainid, delay])
}

async function getAllRunning() {
  return (await query(`SELECT t.trainid, l.name FROM train t
  INNER JOIN (
  SELECT scheduleid, MAX(time) FROM call GROUP BY scheduleid
  ) x
  ON x.scheduleid = t.scheduleid
  INNER JOIN call z
  ON z.scheduleid = x.scheduleid AND z.time = x.max
  INNER JOIN location l
  ON l.locationid = z.locationid
  INNER JOIN (
  SELECT scheduleid, MIN(time) FROM call GROUP BY scheduleid
  ) y
  ON y.scheduleid = t.scheduleid
  WHERE t.date = CURRENT_DATE AND x.max > CURRENT_TIME AND t.iscancelled <> true;
  `, [])).rows
}

async function getNextStation(trainid) {
  return (await query(`SELECT l.locationid FROM train t
  INNER JOIN schedule s
  ON s.scheduleid = t.scheduleid
  INNER JOIN (
  SELECT scheduleid, MIN(time) FROM call
  WHERE call.time > CURRENT_TIME
  GROUP BY scheduleid
  ) x
  ON x.scheduleid = t.scheduleid
  INNER JOIN call l
  ON l.scheduleid = x.scheduleid AND l.time = x.min
  WHERE t.trainid = $1;
  `, [trainid])).rows[0]
}

module.exports = { create, transferLoadings, transferTimings, getDue, cancel, appendDelay, getAllRunning, getNextStation }