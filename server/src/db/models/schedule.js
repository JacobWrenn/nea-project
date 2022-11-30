const query = require("../query").query

async function planRoute(origin, destinaion) {
  return (await query(`SELECT a.locationid, a.time AS time2, b.time AS time1, a.scheduleid AS scheduleid2, b.scheduleid AS scheduleid1, call.time AS time3, d.time AS time4, sc.carbonpermile AS cpm1, s.carbonpermile AS cpm2, sc.number as day1, s.number as day2
  FROM (
    SELECT c.* FROM call c
    INNER JOIN call c2 ON c2.scheduleid = c.scheduleid
    WHERE c.scheduleid IN (
      SELECT scheduleid FROM call WHERE locationid = $1
    )
    AND c2.locationid = $1 AND c2.time <= c.time
  ) a
  INNER JOIN (
    SELECT c.* FROM call c
    INNER JOIN call c2 ON c2.scheduleid = c.scheduleid
    WHERE c.scheduleid IN (
      SELECT scheduleid FROM call WHERE locationid = $2
    )
    AND c2.locationid = $2 AND c.time <= c2.time
  ) b
  ON a.locationid = b.locationid
  LEFT JOIN call
  ON b.scheduleid = call.scheduleid AND call.locationid = $2
  LEFT JOIN call d
  ON a.scheduleid = d.scheduleid AND d.locationid = $1
  LEFT JOIN (
    SELECT * FROM schedule x, dayofweek y, tractiontype t WHERE x.dayofweek = y.dayofweek AND x.tractionid = t.tractionid
    ) s
  ON a.scheduleid = s.scheduleid
  LEFT JOIN (
    SELECT * FROM schedule x, dayofweek y, tractiontype t WHERE x.dayofweek = y.dayofweek AND x.tractionid = t.tractionid
    ) sc
  ON b.scheduleid = sc.scheduleid
  WHERE (b.time < a.time OR s.number <> sc.number) OR a.scheduleid = b.scheduleid
  ORDER BY
  CASE
  WHEN s.number = sc.number AND b.time <= a.time THEN EXTRACT(EPOCH FROM d.time) / 100000
  WHEN s.number <> sc.number THEN ABS(s.number - sc.number)
  END ASC;
  `, [origin, destinaion])).rows[0]
}

async function getStarting(locationid) {
  return (await query(`SELECT c.time, y.name, s.scheduleid
  FROM call c
  INNER JOIN schedule s
  ON s.scheduleid = c.scheduleid
  INNER JOIN (
    SELECT c.locationid, c.scheduleid
    FROM call c
    INNER JOIN (
      SELECT scheduleid, MAX(time) FROM call GROUP BY scheduleid
    ) c2
    ON c2.max = c.time AND c2.scheduleid = c.scheduleid
  ) x
  ON x.scheduleid = s.scheduleid
  INNER JOIN location y
  ON y.locationid = x.locationid
  INNER JOIN dayofweek d
  ON d.dayofweek = s.dayofweek
  WHERE c.locationid = $1 AND c.distance = 0 AND s.startsondate <= CURRENT_DATE AND s.endsondate >= CURRENT_DATE AND ((d.number + 1) % 7) = EXTRACT(dow FROM CURRENT_DATE) AND s.scheduleid NOT IN (
    SELECT scheduleid FROM train t WHERE t.date = CURRENT_DATE
  );
  `, [locationid])).rows
}

async function getDistance(scheduleid, start, end) {
  return (await query(`SELECT SUM(c.distance) FROM call c
  WHERE c.scheduleid = $1
  AND c.time > (SELECT c.time FROM call c WHERE c.scheduleid = $1 AND c.locationid = $2)
  AND c.time <= (SELECT c.time FROM call c WHERE c.scheduleid = $1 AND c.locationid = $3);
  `, [scheduleid, start, end])).rows[0]
}

async function create(day, tractionid, start, end) {
  return (await query(`INSERT INTO schedule (dayofweek, tractionid, startsondate, endsondate)
  VALUES ($1, $2, $3, $4) RETURNING scheduleid;
  `, [day, tractionid, start, end])).rows[0]
}

async function addStop(id, locationid, time, distance) {
  return await query(`INSERT INTO call (scheduleid, locationid, time, distance)
  VALUES ($1, $2, $3, $4);
  `, [id, locationid, time, distance])
}

module.exports = { planRoute, getStarting, getDistance, create, addStop }