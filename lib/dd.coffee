module.exports =

  delay: (ms, cb) ->
    setTimeout cb, ms

  every: (ms, cb) ->
    setInterval cb, ms
