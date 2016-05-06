http          = require 'http'
_             = require 'lodash'
DeviceManager = require 'meshblu-core-manager-device'

class SearchDevice
  constructor: ({@datastore, @uuidAliasResolver}) ->
    @deviceManager = new DeviceManager {@datastore, @uuidAliasResolver}

  do: (request, callback) =>
    {fromUuid, auth, projection} = request.metadata
    fromUuid ?= auth.uuid

    try
      query = JSON.parse request.rawData
    catch error
      return callback null, @_getEmptyResponse request, 422

    @deviceManager.search {uuid: fromUuid, query, projection}, (error, devices) =>
      return callback error if error?
      callback null, @_getDevicesResponse request, 200, devices

  _getEmptyResponse: (request, code) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]

  _getDevicesResponse: (request, code, devices) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
      rawData: JSON.stringify devices

module.exports = SearchDevice
