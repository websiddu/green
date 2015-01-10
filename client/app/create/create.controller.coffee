'use strict'

angular.module 'greenApp'
.controller 'CreateController', ($scope, $http, $routeParams, sectionData, formData, SweetAlert, Auth) ->

  $scope.isAdmin = Auth.isAdmin
  $scope.formShow = false

  formId = $routeParams.id
  $scope.originalForm = {}
  $scope.form = []
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
    has_condition: false
    condition:
      field: ''
      choice: ''
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

  $scope.getAlertSettings = (item) ->
    title: "Are you sure?",
    text: "You will not be able to recover this #{item}!",
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: "Yes, delete it!",
    cancelButtonText: "No, cancel!",
    closeOnConfirm: true,
    closeOnCancel: true


  $scope.getFormatedDate = (date) ->
    d = new Date(date)
    d.toUTCString()

  $scope.pluralize = (points) ->
    if points == 1
      'point'
    else
      'points'

  $scope.findMaxPoints = (array) ->
    max = _.max(array, (a) ->
        return a.points
      )
    return max.points


  $scope.calculateSecitonPoints = ->
    return if $scope.form.sections is undefined
    for skey, sval of $scope.form.sections
      $scope.form.sections[skey].bonus_points = 0
      $scope.form.sections[skey].possible_points = 0
      for key, fld of sval.fields
        if $scope.form.sections[skey].fields[key].is_bonus
          $scope.form.sections[skey].bonus_points += $scope.findMaxPoints(fld.choices)
        else
          $scope.form.sections[skey].possible_points += $scope.findMaxPoints(fld.choices)
    return

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
    SweetAlert.swal($scope.getAlertSettings('section'), (isConfirm) -> _handleSectionDelete(isConfirm, section))

  _handleSectionDelete = (isConfirm, section) ->
    if (isConfirm)
      sectionData.delete(formId, section)
      .success (data, status) ->
        $scope.form.sections.splice($scope.form.sections.indexOf(section), 1)

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

  $scope.submitSection = (section, sectionId) ->
    $scope.sectionSaving = true
    sectionData.create(section)
      .success (data, status) ->
        $scope.sectionSaving = false
        $scope.enableSaveButton = true

  $scope.submitForm = (form) ->
    $scope.formSaving = true
    formData.update(form)
      .success (data, status) ->
        $scope.formSaving = false

  $scope.$watch('form.sections', (old, newValue) ->
    $scope.enableSaveButton = false
    $scope.calculateSecitonPoints()
  , true)

  $scope.init()
