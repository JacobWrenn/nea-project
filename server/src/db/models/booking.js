const query = require("../query").query

async function getTracking(bookingid) {
  return (await query(`SELECT g.received, l.completed, g.handedover, g.complete, y.name, b.destination, p.date, d.delay, c.time, s.lat, s.long, b.price, p.unload
  FROM plannedloading p
  INNER JOIN good g
  ON g.goodid = p.goodid
  INNER JOIN booking b
  ON b.bookingid = g.bookingid
  LEFT JOIN train t
  ON t.scheduleid = p.scheduleid AND t.date = p.date
  LEFT JOIN timings d
  ON d.trainid = t.trainid AND p.locationid = d.locationid AND d.scheduleid = p.scheduleid
  LEFT JOIN loading l
  ON l.trainid = t.trainid AND l.locationid = p.locationid AND l.goodid = g.goodid
  INNER JOIN location s
  ON s.locationid = p.locationid
  INNER JOIN location y
  ON y.locationid = b.origin
  INNER JOIN call c
  ON c.scheduleid = p.scheduleid AND c.locationid = p.locationid
  WHERE b.bookingid = $1;
  `, [bookingid])).rows
}

async function getByUsername(username) {
  return (await query(`SELECT bookingid, label
  FROM booking
  WHERE username = $1;
  `, [username])).rows
}

async function create(origin, username, destination, label, price) {
  return (await query(`INSERT INTO booking (origin, username, destination, label, price)
  VALUES ($1, $2, $3, $4, $5)
  RETURNING bookingid;
  `, [origin, username, destination, label, price])).rows[0]
}

module.exports = {getTracking, getByUsername, create}