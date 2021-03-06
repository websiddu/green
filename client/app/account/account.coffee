'use strict'

angular.module 'greenApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/',
    authenticate: true
    templateUrl: 'app/controllers/forms/forms.html'
    controller: 'FormsController'

  .when '/lg',
    templateUrl: 'app/account/login/login.html'
    controller: 'LoginCtrl'

  .when '/signup',
    templateUrl: 'app/account/signup/signup.html'
    controller: 'SignupCtrl'

  .when '/settings',
    templateUrl: 'app/account/settings/settings.html'
    controller: 'SettingsCtrl'
    authenticate: true
