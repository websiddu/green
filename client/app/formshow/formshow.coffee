'use strict'

angular.module 'greenApp'
.config ($routeProvider) ->
  $routeProvider.when '/forms/:id/:res/success',
    templateUrl: 'app/formshow/success.html'
    controller: 'FormshowCtrl'

  $routeProvider.when '/forms/:id/:res',
    templateUrl: 'app/formshow/formshow.html'
    controller: 'FormshowCtrl'
    # resolve:
    #   from: 'new'
  $routeProvider.when '/forms/:id',
    templateUrl: 'app/formshow/formshow.html'
    controller: 'FormshowCtrl'
    # resolve:
    #   from: 'submission'
