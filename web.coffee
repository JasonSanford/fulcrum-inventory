express    = require 'express'
logfmt     = require 'logfmt'
bodyParser = require 'body-parser'
request    = require 'request'
Fulcrum    = require 'fulcrum-app'

constants = require './constants'

port = Number process.env.PORT or 5000

app = express()

app.use logfmt.requestLogger()
app.use bodyParser.json()
app.use bodyParser.urlencoded()

app.get '/', (req, res) ->
  res.send 'You should POST to me'

app.post '/', (req, resp) ->
  payload = req.body
  processPayload payload
  resp.send "Thanks Fulcrum. You're the best!"

app.listen port, ->
  console.log 'Listening on port ' + port

fulcrum = new Fulcrum({api_key: constants.fulcrum_api_key, url: 'https://edge.fulcrumapp.com/api/v2/'})

processPayload = (payload) ->
  unless payload.data.form_id is constants.form_id
    console.log 'Ignoring webhook because form id'
    return

  unless payload.type is 'record.create'
    console.log 'Ignoring webhook because type was not record.create'
    return

  status = payload.data.status

  unless status is constants.statuses.NEW
    console.log "Ignoring record because status was not #{constants.status.NEW}"
    return

  processNewRecord(payload)

processNewRecord = (webhook_record) ->
  factualResponseCallback = (error, response, data) ->
    if error
      console.log "Error from factual: #{error}"
      return
    if data.response.total_row_count is 0
      console.log "No Factual records found for record: #{webhook_record.id}"
      setRecordNotFoundInFactual(webhook_record)
    else
      console.log "Got Factual response: #{JSON.stringify(data)}"
  filters =
    '$and': [
      {
        upc: {
          '$eq': webhook_record.data.form_values[constants.form_keys.upc]
        }
      }
    ]
  qs =
    KEY           : constants.factual_api_key
    include_count : 't'
    filters       : filters
  factualRequestOptions =
    uri  : 'https://api.factual.com/t/products-cpg-nutrition'
    json : true
    qs   : qs
  request(factualRequestOptions, factualResponseCallback)

setRecordNotFoundInFactual = (webhook_record) ->
  fulcrumRecordFoundCallback = (error, api_record) ->
    if error
      console.log "Error finding Fulcrum record: #{error}"
      return

    fulcrumRecordUpdatedCallback = (error, api_record) ->
      if error
        console.log "Error updating Fulcrum record: #{error}"
        return
      console.log "Updated Fulcrum record: #{api_record.record.id}"

    api_record.record.status = constants.statuses.NOT_FOUND
    fulcrum.records.update(api_record.record.id, api_record, fulcrumRecordUpdatedCallback)

  fulcrum.records.find(webhook_record.id, fulcrumRecordFoundCallback)
