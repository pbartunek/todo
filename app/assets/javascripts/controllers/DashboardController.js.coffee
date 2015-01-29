angular.module('ToDo').controller "DashboardController", ($scope, $routeParams, $location, TaskList) ->

  $scope.init = ->
    @listService = new TaskList(serverErrorHandler)
    $scope.lists = @listService.all()

  $scope.createList = (name) ->
    @listService.create name: name, (list) ->
      $location.url("/l/#{list.id}")

  $scope.deleteList = (list, index) ->
    result = confirm "Are you sure you want to delete this task list?"

    if result
      @listService.delete list
      $scope.lists.splice index, 1

  serverErrorHandler = ->
    alert("There was a server error, please reload the page and try again.")
