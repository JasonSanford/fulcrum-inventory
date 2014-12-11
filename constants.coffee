form_keys =
  upc : '3116'
  name: 'a0ed'

statuses =
  NEW       : 'new'
  FOUND     : 'found'
  NOT_FOUND : 'not_found'

constants =
  form_id         : '7f0f1048-b948-4629-8388-87c09199154c'
  form_keys       : form_keys
  statuses        : statuses
  factual_api_key : process.env.FACTUAL_API_KEY
  fulcrum_api_key : process.env.FULCRUM_API_KEY

module.exports = constants
