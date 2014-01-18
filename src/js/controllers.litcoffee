    vespaControllers = angular.module('vespaControllers', 
                                      ['ui.ace', 'vespa.socket', 'ui.bootstrap'])

The main controller. avispa is a subcontroller.

    vespaControllers.controller 'ideCtrl', ($scope, $rootScope, SockJSService, VespaLogger, $modal, AsyncFileReader) ->

This controls our editor visibility.

      $scope.toggleEditor = ->
        $scope.editorVisible = !$scope.editorVisible

      $scope.editorVisible = true

      $scope.aceLoaded = (editor) ->
        editor.setTheme("ace/theme/chaos");
        editor.getSession().setMode("ace/mode/lobster");
        editor.setKeyboardHandler("vim");
        editor.setBehavioursEnabled(true);
        editor.setSelectionStyle('line');
        editor.setHighlightActiveLine(true);
        editor.setShowInvisibles(false);
        editor.setDisplayIndentGuides(false);
        editor.renderer.setHScrollBarAlwaysVisible(false);
        editor.setAnimatedScroll(false);
        editor.renderer.setShowGutter(true);
        editor.renderer.setShowPrintMargin(false);
        editor.getSession().setUseSoftTabs(true);
        editor.setHighlightSelectedWord(true);

Ace needs a statically sized div to initialize, but we want it
to be the full page, so make it so.

        editor.resize()
        $scope.editor = editor

Check syntax button callback

      $scope.check_lobster = ->

        req =
          domain: 'lobster'
          request: 'validate'
          payload: $scope.editor.getValue()

        $scope.loading = true

        SockJSService.send req, (result)->
          $scope.loading = false
          if result.error
            VespaLogger.log 'lobster', 'error', result.payload
          else
            $rootScope.$broadcast 'lobsterUpdate', result

This is just the initial data. We should remove it at some point.

      $scope.editor_data = """
      class A () {
            port s : { position = subject } ;
            port o : { position = object } ;
      }
      
      domain a = A();
      domain b = A();
      domain c = A();
      domain d = A();
      domain e = A();
      domain f = A();
      domain g = A();
      domain h = A();
      domain i = A();
      
      a.s --> b.o;
      b.s --> c.o;
      c.s --> d.o;
      d.s --> e.o;
      e.s --> f.o;
      f.s --> g.o;
      g.s --> h.o;
      h.s --> i.o;
      i.s --> a.o;
      """

Create a modal for loading policies

      $scope.load_policy = ->
        instance = $modal.open
          templateUrl: 'policyLoadModal.html'
          controller: ($scope, $modalInstance) ->

            $scope.input = {}

            $scope.load = ->

              inputs = 
                label: $scope.input.label
                policy_file: $('#policyFile')[0].files[0]
                lobster_file:  $('#policyFile')[0].files[0]

              $modalInstance.close(inputs)

            $scope.cancel = ->
              $modalInstance.dismiss('cancel')

If we get given files, read them as text and send them over the websocket

        instance.result.then(
          (inputs)-> 
            console.log(inputs)

            filelist = 
              application: inputs.policy_file
              dsl: inputs.lobster_file

            AsyncFileReader.read filelist, (files)->
              req = 
                domain: 'policy'
                request: 'create'
                payload: 
                  _id: inputs.label
                  application: files.application
                  dsl: files.dsl

              SockJSService.send(req)

          ()->
            console.log("Modal dismissed")
        )



The console controller is very simple. It simply binds it's errors
scope to the VespaLogger scope

    vespaControllers.controller 'consoleCtrl', ($scope, VespaLogger) ->

      $scope.errors = VespaLogger.messages