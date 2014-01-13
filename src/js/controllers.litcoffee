    vespaControllers = angular.module('vespaControllers', ['ui.ace', 'vespa.socket'])

The main controller. avispa is a subcontroller.

    vespaControllers.controller 'ideCtrl', ($scope, SockJSService) ->

      ws_sock = SockJSService("http://#{location.host}/ws", null , {debug: true})

      $scope.editor = null

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

        $("#editor").height "#{$(window).height() * 0.75 }px"
        editor.resize()
        $scope.editor = editor

Check syntax button callback

      $scope.check_lobster = ->

        req =
          domain: 'lobster'
          request: 'validate'
          payload: $scope.editor.getValue()

        ws_sock.send req, (result)->
          console.log  "Got result"
          console.log result


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




    vespaControllers.controller 'avispaCtrl', ($scope) ->

      $scope.avispa = new Avispa
        el: $('#surface svg')

      $('#surface').append $scope.avispa.$el


