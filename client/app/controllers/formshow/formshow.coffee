'use strict'

angular.module 'greenApp'
.config ($routeProvider) ->
  $routeProvider.when '/forms/:id/:res/success',
    templateUrl: 'app/controllers/formshow/success.html'
    controller: 'FormshowSuccessCtrl'

  $routeProvider.when '/forms/:id/:res',
    templateUrl: 'app/controllers/formshow/formshow.html'
    controller: 'FormshowCtrl'
  $routeProvider.when '/forms/:id',
    templateUrl: 'app/controllers/formshow/formshow.html'
    controller: 'FormshowCtrl'
