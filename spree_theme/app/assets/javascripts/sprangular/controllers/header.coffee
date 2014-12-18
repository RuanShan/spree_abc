Sprangular.controller "HeaderCtrl", ($scope, $location, Cart, Account, Catalog, Env, Flash, Status, Angularytics) ->

  $scope.cart = Cart
  Catalog.taxonomies().then (taxonomies) ->
    $scope.taxonomies = taxonomies
  $scope.account = Account
  $scope.env = Env
  $scope.search = {text: $location.search()['search']}

  $scope.goToMyAccount = ->
    $location.path '/account'

  $scope.logout = ->
    Account.logout()
      .then (content) ->
        Angularytics.trackEvent("Account", "Logout")
        $scope.$emit('account.logout')
        Flash.success "Successfully logged out"
        $location.path '/'

  $scope.login = ->
    $location.path '/sign-in'

  $scope.doSearch = ->
    Angularytics.trackEvent("Product", "Search", $scope.search.text)
    $location.search('search', $scope.search.text)
    $location.path "/products"

  $scope.getProducts = (search) ->
    Catalog.products(search)
