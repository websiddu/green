'use strict'

angular.module 'greenApp'
.controller 'CreateController', ($scope, $http, $routeParams) ->

  formId = $routeParams.id
  $scope.originalForm = {}
  $scope.form = {}
  $scope.sections = []



  # Main Form
  master =
    title: ''
    description: ''
    form_type: ''
    results_viewable: true
    template: false
    fields: []

  # Fields
  field =
    label: null
    help_text: ''
    type: ''
    required: ''
    sequence: 0
    edit_mode: true
    choices: [
      label: "Option"
    ]
    validation:
      required: false
      type: ''
      category: ''
      data: ''
      message: ''

  # Choices
  choice =
    label: ''


  $scope.init = ->
    return unless formId
    $scope.getCurrenForm()

  $scope.getCurrenForm = ->
    $http.get("api/forms/#{formId}")
      .success( (data) ->
        $scope.originalForm = angular.copy(data)
        $scope.form = data
        $scope.form.sections = []
        $scope.loadSections()
      )

  $scope.loadFromCreate = ->
    # master.fields.push angular.copy(field)
    $scope.form.sections[0].fields = []
    $scope.form.sections[0].fields.push("Siidd")

  $scope.loadSections = ->
    i = 0
    len = $scope.originalForm.sections.length
    console.log $scope.originalForm
    while i < len
      $http.get("api/sections/#{$scope.originalForm.sections[i]}")
        .success (data, status) ->
          data.fields.push(angular.copy(field))
          $scope.form.sections.push(data)

          if i is len - 2
            $scope.loadFromCreate()

      i++

  $scope.addSectionToForm = (sectionId, formId) ->
    $http.put("api/forms/s/#{formId}", {
        sections: sectionId._id
      }).success( (data, status) ->
        console.log data
      )

  $scope.removeSection = (section) ->
    $http.delete("api/forms/s/#{formId}", {
        sections: section._id
      }).success( (data, status) ->
        $scope.form.sections.splice($scope.form.sections.indexOf(section), 1)
        console.log data
      )

  $scope.addNewSection = ->
    newSection = {
      name: $scope.newSection
    }

    return if $scope.newSection is ''
    $http.post('/api/sections', newSection)
      .success( (data, status, headers, config) ->
        $scope.newSection = ''
        $scope.addSectionToForm(data, formId)
        $scope.form.sections.push(newSection)
        return
      )
    return

  $scope.loadSection = (section) ->
    section.active = true


  $scope.init()



  # $http.get '/api/users'
  # .success (users) ->
  #   $scope.users = users

  # $scope.delete = (user) ->
  #   User.remove id: user._id
  #   _.remove $scope.users, user