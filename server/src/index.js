process.env.TZ = 'Etc/UTC'

const fs = require("fs")
const path = require("path")
const express = require("express")
const cors = require("cors")

// Create HTTP server
const app = express()
const port = 8080

// Bring in my code
const auth = require("./modules/auth")
const authRouter = require("./routes/auth")
const adminRouter = require("./routes/admin")
const bookingRouter = require("./routes/booking")
const goodsRouter = require("./routes/goods")
const scheduleRouter = require("./routes/scheduler")

// Permit access to the server from the website
app.use(cors({
  origin: 'http://localhost:3000'
}))

// Decode the body of all API requests
app.use(express.urlencoded({ extended: true }))
app.use(express.json())

app.use(auth.middleware)

// Mount all my API routes and apply security rules
app.use("/auth", authRouter)
app.use("/admin", auth.protect("admin"), adminRouter)
app.use("/goods", auth.protect("staff"), goodsRouter)
app.use("/booking", auth.protect("user"), bookingRouter)
app.use("/train", auth.protect("staff"), scheduleRouter)

app.get("/main.css", (req, res) => {
  res.status(200);
  res.setHeader('Content-Type', 'text/css')
  fs.createReadStream(path.join(__dirname, 'static', 'main.css')).pipe(res)
})

// Fallback route handlers
app.use((req, res, next) => {
  res.status(404)
  res.setHeader("Content-Type", "text/html")
  fs.createReadStream(path.join(__dirname, "static/404.html")).pipe(res)
})

app.use((err, req, res, next) => {
  console.log(err)
  res.status(500)
  res.setHeader("Content-Type", "text/html")
  fs.createReadStream(path.join(__dirname, "static/500.html")).pipe(res)
})

app.listen(port, () => {
  console.log(`Listening on ${port}...`)
})