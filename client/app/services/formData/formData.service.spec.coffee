'use strict'

describe 'Service: formData', ->

  # load the service's module
  beforeEach module 'greenApp'

  # instantiate service
  formData = undefined
  beforeEach inject (_formData_) ->
    formData = _formData_
