http = require 'http'
_    = require 'lodash'
async = require 'async'
WhitelistManager = require 'meshblu-core-manager-whitelist'
class SearchDevice
  constructor: ({@datastore,@uuidAliasResolver}) ->
    @whitelistManager = new WhitelistManager {@datastore, @uuidAliasResolver}

  do: (request, callback) =>
    {fromUuid, auth} = request.metadata
    fromUuid ?= auth.uuid

    try
      deviceQuery = JSON.parse request.rawData
    catch error
      return callback null, @_getEmptyResponse 422

    @datastore.find deviceQuery, (error, devices) =>
      discoverFilter = @_getCanDiscoverFilter fromUuid

      async.filter devices, discoverFilter, (discoverableDevices) =>
        response =
          metadata: code: 200
          rawData: JSON.stringify discoverableDevices
        callback null, response
    
  _getCanDiscoverFilter: (fromUuid) =>
    return (device, callback) =>
      return @whitelistManager.canDiscover fromUuid: fromUuid, toUuid: device.uuid, (error, canDiscover) => callback canDiscover

  _getEmptyResponse: (code) =>
    response =
      metadata:
        code: code
        status: http.STATUS_CODES[code]

module.exports = SearchDevice
