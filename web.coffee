async   = require("async")
dd      = require("ddollar")
express = require("express")
log     = require("logfmt")
stdweb  = require("stdweb")

app = stdweb("allocator")

app.get "/", (req, res) ->
  res.send "ok"

app.post "/allocate", (req, res) ->
  console.log "req.body", req.body

  remaining = parseFloat(req.body.amount)

  desired = req.body.desired.split(",")
  totals  = req.body.totals.split(",")
  tickers = req.body.tickers.split(",")
  prices  = req.body.prices.split(",")

  securities = dd.reduce tickers, {}, (ax, ticker, i) ->
    ax[ticker] = index:i, price:parseFloat(prices[i]), total:parseFloat(totals[i]), desired:parseFloat(desired[i]), qty:0
    ax

  while true
    total = dd.reduce dd.values(securities), 0, (ax, data) -> ax + data.total
    securities[ticker].target    = total * security.desired for ticker, security of securities
    securities[ticker].imbalance = security.target - security.total for ticker, security of securities
    sorted = dd.keys(securities).sort (a, b) -> securities[b].imbalance - securities[a].imbalance
    eligible = dd.reduce sorted, [], (ax, ticker) -> ax.push(ticker) if securities[ticker].price < remaining; ax
    buy = eligible[0]
    console.log "buy", buy
    break unless buy
    securities[buy].qty += 1
    securities[buy].total += securities[buy].price
    remaining -= securities[buy].price

  allocate = dd.reduce dd.keys(securities), {}, (ax, ticker) ->
    ax[ticker] = securities[ticker].qty
    ax

  res.send JSON.stringify(remaining:remaining.toFixed(2), allocate:allocate, null, 2)

app.start (port) ->
  console.log "listening on #{port}"
