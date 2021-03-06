'use strict'

angular.module 'greenApp'
.controller 'FormshowCtrl', ($scope, $http, $routeParams, formData, Auth, $location, Utils, $window) ->

  $scope.form = {};
  formId = $routeParams.id
  resultId = $routeParams.res
  $scope.page = true

  $scope.totalPoints = 0
  $scope.aquiredPoints = 0
  $scope.isAdmin = Auth.isAdmin

  $scope.popOupOpen = false
  $scope.enableDraft = false

  $scope.getFormatedDate = Utils.getFormatedDate

  $scope.getFormLink = (form) ->
    if $scope.isAdmin() and form.status is 'Unpublished'
      return "/forms/edit/#{form._id}"
    else if $scope.isAdmin() and form.status is 'Published'
      return "/results/#{form._id}"
    else
      return "/forms/#{form._id}"

  $scope.goBack = ->
    $window.history.back()

  $scope.init = ->
    _loadFormData()

  _loadFormData = ->
    formData.getForm(formId)
      .success (data, status) ->
        if !Auth.isAdmin()
          if resultId != undefined
            formData.getFormUserResponse(resultId)
              .success (results, resultsStatus) ->
                if results.length != 0
                  _formatForm(data, results)
          else
            $scope.form = data
            $scope.form.aquired_points = 0
            $scope.form.sections[0].active = true
        else
          $scope.form = data
          $scope.form.aquired_points = 0
          $scope.form.sections[0].active = true

  _formatForm = (data, results) ->
    form = data
    form.total_points = results[0].total_points
    form.results_id = results[0]._id

    newsecitons = {}

    for i, sec of results[0].sections
      newsecitons[sec.id] =
        possible_points: sec.possible_points
        aquired_points: sec.aquired_points

    for index, field of results[0].results
      section = _.find form.sections, (s) -> s._id is field.section_id
      secField = _.find section.fields, (s) -> s._id is field.field_id
      secField.aquired_points = field.aquired_points

      section.possible_points = newsecitons[field.section_id].possible_points

      section.aquired_points = 0 if section.aquired_points is undefined

      section.aquired_points+= field.aquired_points

      if field.field_type is 'checkbox'
        for index, choice of field.response
          choiceI = _.find secField.choices, (s) ->
            s._id is choice
          if choiceI
            choiceI.selected = true
            _showHiddenField(field.field_id, choiceI._id, section)
      else if field.response != ''
        secField.response = field.response
        _showHiddenField(field.field_id, field.response, section)

    $scope.form = form
    $scope.form.aquired_points = results[0].points
    $scope.form.sections[0].active = true

  _showHiddenField = (fieldId, response, section) ->
    return if !fieldId

    fieldTobeShown = _.find section.fields, (v) ->
      v.has_condition is true and response in v.condition.choice

    if fieldTobeShown
      fieldTobeShown.has_condition = false

  _updateScore = (field, section) ->
    if field.type in ['checkbox']
      selectdOption = _.filter field.choices, 'selected',  true
      aquired_points = _.sum(selectdOption, 'points')
    else
      selectdOption = _.find field.choices, (v) -> field.response is v._id
      aquired_points = selectdOption.points

    field.aquired_points = 0

    if selectdOption != undefined
      if selectdOption.is_na is true
        field.is_na_reduced = field.possible_points
        field.possible_points = 0
        # $scope.form.total_points = $scope.form.total_points - field.possible_points
      else
        # $scope.form.total_points = $scope.form.total_points + (field.is_na_reduced or 0)
        if field.is_na_reduced
          field.possible_points = field.is_na_reduced
        field.is_na_reduced = 0
      field.aquired_points = aquired_points

      # if selectdOption.show_field.length > 0
      #   selectdOption.show_field.forEach (field) ->
      #     index = _.findIndex section.fields, (v) ->
      #       v._id is field
      #     if index > -1
      #       section.fields[index].is_points_added = true

    _updateSectionScore(section)

  _updateSectionScore = (section) ->
    section.total_points = 0
    section.aquired_points = 0
    section.possible_points = 0

    for field, key in section.fields

      if field.aquired_points
        section.aquired_points+= field.aquired_points

      if field.has_condition is false and field.is_bonus isnt true
        section.possible_points += field.possible_points

    _updateFormScore()

  _updateFormScore = ->
    return if !$scope.form.sections
    $scope.form.aquired_points = 0
    $scope.form.total_points = 0
    for section, key in $scope.form.sections
      if section.aquired_points
        $scope.form.aquired_points += section.aquired_points

      $scope.form.total_points += section.possible_points


  $scope.watchResponses = (field, section, choice) ->
    $scope.enableDraft = false
    for key, val of section.fields
      val.showing_popup = false

    if field.type is 'select'
      for key, val of field.choices
        if val._id is field.response
          $scope.popup_content = val.help_text_html
          field.showing_popup = true
          break
    else if (field.response is choice._id and field.type != 'checkbox') or (choice.selected is true)
      field.showing_popup = true

    if (field.type is 'checkbox')
      for key, val of field.choices
        val.showing_popup = false
      choice.showing_popup = true


    ## Show hide conditional field
    conditionOption = _.find field.choices, (v) ->
      if field.type in ['checkbox']
        v.selected is true and v.is_condition is true
      else
        v.is_condition is true and field.response is v._id

    for i, val of section.fields
      if val.condition.field is field._id
        val.has_condition = true
        val.response = ''

    if(conditionOption)
      fieldIndexs = []
      section.fields.forEach (val, index) ->
        if(val._id in conditionOption.show_field)
          fieldIndexs.push(val)
          section.fields[index].has_condition = false

    _updateScore(field, section)

  $scope.toggleClass = (section) ->
    for key, val of $scope.form.sections
      $scope.form.sections[key].active = false
    section.active = true

  $scope.moveToNextStep = ($index, section) ->
    for key, val of $scope.form.sections
      $scope.form.sections[key].active = false
    $scope.form.sections[$index + 1].active = true

  $scope.moveToPrevStep = ($index, section) ->
    for key, val of $scope.form.sections
      $scope.form.sections[key].active = false
    $scope.form.sections[$index - 1].active = true

  $scope.saveAsDraft = (event) ->
    event.preventDefault()
    $scope.form.submitted = false
    _saveForm()

  $scope.updateFormStatus = (event) ->
    event.preventDefault()
    $scope.form.submitted = true
    $scope.form.status = 'submitted'
    _saveForm()

  $scope.saveFormResuts = (e) ->
    e.preventDefault()
    $scope.formSaving = true
    _saveForm()

  _saveForm = ->
    formData.respond($scope.form)
      .success (data, status) ->
        $scope.formSaving = false
        $scope.enableDraft = true
        if resultId is undefined
          $location.path("#{$location.path()}/#{data._id}")
        if data.submitted is true
          $location.path("#{$location.path()}/success")

  $scope.init()
