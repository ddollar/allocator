async   = require("async")
coffee  = require("coffee-script")
dd      = require("./lib/dd")
express = require("express")
log     = require("./lib/logger").init("allocator")
stdweb  = require("./lib/stdweb")

recalc_target_value = (assets, amount) ->
  assets[klass].target_value = asset.target_alloc * amount for klass, asset of assets

recalc_current_total = (assets) ->
  total = 0
  total += asset.value for klass, asset of assets
  total

find_optimal_purchase = (assets) ->
  sorted = dd.values(assets).sort (a, b) ->
    ((b.target_value - b.value) - (a.target_value - a.value))
  sorted[0]

app = stdweb("allocator")

app.locals =
  format_currency: (num) ->
    "$#{num.toFixed(2)}"

app.get "/", (req, res) ->
  res.render "index.jade"

app.post "/allocate", (req, res) ->
  old_total = 0
  assets = dd.reduce req.body.data.split("\n"), {}, (ax, line) ->
    parts = line.split("\t")
    ax[parts[0]] =
      klass: parts[0]
      target_alloc: parseFloat(parts[1]) / 100
      value: parseFloat(parts[4].replace(/[$,]/g, ""))
      ticker: parts[5]
      price: parseFloat(parts[7].replace(/[$,]/g, ""))
    old_total += ax[parts[0]].value
    ax

  new_total = old_total + parseFloat(req.body.amount)
  done = false
  purchases = {}

  until done
    current_total = recalc_current_total(assets)
    recalc_target_value assets, new_total
    optimal = find_optimal_purchase assets
    if optimal.price > (new_total - current_total)
      done = true
    else
      purchases[optimal.ticker] ||= 0
      purchases[optimal.ticker] +=  1
      assets[optimal.klass].value += optimal.price

  purchase_array = []
  purchase_array.push(ticker:ticker, amount:amount) for ticker, amount of purchases
  res.render "purchases.jade", purchases:purchase_array, current_total:current_total, new_total:new_total

app.start (port) ->
  console.log "listening on #{port}"
