form_keys =
  upc : 'e932'
  name: '0446'

statuses =
  NEW       : 'new'
  FOUND     : 'found'
  NOT_FOUND : 'not_found'

constants =
  form_id         : 'a93dc290-8206-48d6-96be-242c98e5f1ec'
  form_keys       : form_keys
  statuses        : statuses
  factual_api_key : process.env.FACTUAL_API_KEY
  fulcrum_api_key : process.env.FULCRUM_API_KEY

module.exports = constants
