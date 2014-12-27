'use strict'

angular.module 'greenApp'
.controller 'CreateController', ($scope, $http, $routeParams, sectionData, formData, SweetAlert) ->

  formId = $routeParams.id
  $scope.originalForm = {}
  $scope.form = {}
  $scope.sections = []
  $scope.sectionSaving = false
  $scope.enableSaveButton = true
  $scope.formSaving = false
  $scope.isCollapsed = true

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
    type: 'text'
    required: ''
    sequence: 0
    edit_mode: true
    is_bonus: false
    choices: [
      label: "Option"
      points: 0
      focus: true
    ]
    field_validation:
      is_required: false
      type: ''
      category: ''
      data: ''
      message: ''

  # Choices
  choice =
    label: ''

  $scope.sortableOptions =
    containment: "parent"
    stop: (e, ui) ->


  $scope.getFormatedDate = (date) ->
    d = new Date(date)
    d.toUTCString()

  $scope.pluralize = (points) ->
    console.log points
    if points == 1
      'point'
    else
      'points'

  $scope.init = ->
    return unless formId
    $scope.getCurrenForm()

  $scope.getCurrenForm = ->
    $http.get("api/forms/#{formId}")
      .success (data) ->
        $scope.originalForm = angular.copy(data)
        $scope.form = data

  $scope.addSectionToForm = (sectionId, formId) ->
    $http.put("api/forms/s/#{formId}", {
        sections: sectionId._id
      }).success (data, status) ->


  $scope.removeSection = (section) ->
    SweetAlert.swal({
      title: "Are you sure?",
      text: "You will not be able to recover this section!",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: "Yes, delete it!",
      cancelButtonText: "No, cancel!",
      closeOnConfirm: false,
      closeOnCancel: true
    },
    (isConfirm) ->
      if (isConfirm)
        $http.delete("api/forms/s/#{formId}", {
          sections: section._id
        }).success (data, status) ->
          $scope.form.sections.splice($scope.form.sections.indexOf(section), 1)
          SweetAlert.swal("Deleted!", "Your imaginary file has been deleted.", "success");

    );




  $scope.addNewSection = ->
    newSection = {
      title: $scope.newSection
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

  $scope.addField = (section) ->
    section.fields.push angular.copy(field)

  $scope.removeField = (field, section) ->
    currentField = section.fields.indexOf(field)
    section.fields.splice(currentField, 1)

  $scope.toggleField = (field, section) ->
    field.edit_mode = !field.edit_mode;

  $scope.isValidField = (field) ->
    field.label not in [undefined, '', null] and field.type not in ['', undefined]

  $scope.addChoice = (field) ->
    field.choices = [] if field.choices is undefined
    field.choices.push angular.copy(choice)

  $scope.removeChoice = (field, index) ->
    field.choices.splice index, 1


  $scope.$watch('form.sections', (old, newValue) ->
    $scope.enableSaveButton = false
  , true)

  $scope.submitSection = (section, sectionId) ->
    $scope.sectionSaving = true
    sectionData.create(section)
      .success( (data, status) ->
        $scope.sectionSaving = false
        $scope.enableSaveButton = true
      )

  $scope.submitForm = (form) ->
    $scope.formSaving = true
    formData.update(form)
      .success( (data, status) ->
        $scope.formSaving = false
      )

  $scope.init()

  # $http.get '/api/users'
  # .success (users) ->
  #   $scope.users = users

  # $scope.delete = (user) ->
  #   User.remove id: user._id
  #   _.remove $scope.users, user
