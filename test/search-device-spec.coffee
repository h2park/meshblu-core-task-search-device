mongojs = require 'mongojs'
moment = require 'moment'
Datastore = require 'meshblu-core-datastore'
SearchDevice = require '../'
_ = require 'lodash'
describe 'SearchDevice', ->
  beforeEach (done) ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    @datastore = new Datastore
      database: mongojs('meshblu-core-task-search-device')
      moment: moment
      collection: 'devices'

    @datastore.remove done

  beforeEach ->
    @sut = new SearchDevice {@datastore, @uuidAliasResolver}

  describe '->do', ->
    beforeEach 'insert auth device', (done)->
      @auth = uuid: 'archaeologist'

      @datastore.insert @auth, done
    describe 'when called without a query', ->
      beforeEach (done) ->
        request =
          metadata:
            auth: @auth
            responseId: 'archaeology-dig-1'
          rawData: ''

        @sut.do request, (error, @response) => done error

      it 'should respond with a 422 code', ->
        expect(@response.metadata.code).to.equal 422

      it 'should respond with an empty array', ->
        expect(@response.rawData).to.not.exist

    describe 'when called with a query', ->
      beforeEach 'insert records', (done)->
        record =
          uuid: 'velociraptors'
          token: 'are-awesome'
          name: 'bitey'
          type: 'dinosaur'
        @datastore.insert [record], done

      beforeEach (done) ->
        query = type: 'dinosaur'
        request =
          metadata:
            auth: @auth
            responseId: 'archaeology-dig-2'
          rawData: JSON.stringify query

        @sut.do request, (error, @response) => done error

      it 'should respond with a 200 code', ->
        expect(@response.metadata.code).to.equal 200

      it 'should respond with 1 device', ->
        dinosaurDevices = JSON.parse @response.rawData
        expect(dinosaurDevices.length).to.equal 1

    describe 'when called with a query that matches 3 devices', ->
      beforeEach 'insert records', (done)->
        velociraptor =
          uuid: 'velociraptors'
          token: 'are-awesome'
          name: 'bitey'
          type: 'dinosaur'

        trex =
          uuid: 'trex'
          token: 'are-also-awesome'
          name: 'bitey'
          type: 'dinosaur'

        hideosaur =
          uuid: 'hideosaur'
          token: 'are-also-awesome'
          name: 'Hidden'
          discoverWhitelist: []
          type: 'dinosaur'

        @datastore.insert [velociraptor, trex, hideosaur], done

      beforeEach (done) ->
        query = type: 'dinosaur'
        request =
          metadata:
            auth: @auth
            responseId: 'archaeology-dig-2'
          rawData: JSON.stringify query

        @sut.do request, (error, @response) => done error

      it 'should respond with a 200 code', ->
        expect(@response.metadata.code).to.equal 200

      it 'should respond with 2 devices', ->
        dinosaurDevices = JSON.parse @response.rawData
        expect(dinosaurDevices.length).to.equal 2

    describe 'when called with a query that returns 2000 devices', ->
      beforeEach 'insert records', (done)->
        dinosaurs = _.times 2000, =>
          uuid: _.uniqueId()
          token: 'are-awesome'
          name: 'bitey'
          type: 'dinosaur'

        @datastore.insert dinosaurs, done

      beforeEach (done) ->
        query = type: 'dinosaur'
        request =
          metadata:
            auth: @auth
            responseId: 'archaeology-dig-2'
          rawData: JSON.stringify query

        @sut.do request, (error, @response) => done error

      it 'should respond with a 200 code', ->
        expect(@response.metadata.code).to.equal 200

      it 'should respond with an empty array', ->
        dinosaurDevices = JSON.parse @response.rawData
        expect(dinosaurDevices.length).to.equal 1000
