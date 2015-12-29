http = require 'http'
_    = require 'lodash'
async = require 'async'
DeviceDatastore = require 'meshblu-core-datastore-device'

class SearchDevice
  constructor: ({@meshbluDatastore, @uuidAliasResolver}) ->

  do: (request, callback) =>
    {fromUuid, auth} = request.metadata
    fromUuid ?= auth.uuid

    @deviceDatastore = new DeviceDatastore
      meshbluDatastore: @meshbluDatastore
      uuid: fromUuid

    try
      deviceQuery = JSON.parse request.rawData
    catch error
      return callback null, @_getEmptyResponse 422

    @deviceDatastore.find(deviceQuery, (error, devices) =>
      response =
        metadata: code: 200
        rawData: JSON.stringify devices

      callback null, response
    ).limit(1000)

  _getEmptyResponse: (code) =>
    response =
      metadata:
        code: code
        status: http.STATUS_CODES[code]

module.exports = SearchDevice
