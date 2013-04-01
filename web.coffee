async   = require("async")
coffee  = require("coffee-script")
dd      = require("./lib/dd")
express = require("express")
log     = require("./lib/logger").init("template")
stdweb  = require("./lib/stdweb")

app = stdweb("template")

app.get "/", (req, res) ->
  res.send "ok"

app.start (port) ->
  console.log "listening on #{port}"
