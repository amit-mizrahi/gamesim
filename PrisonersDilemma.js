// Generated by CoffeeScript 1.6.3
(function() {
  var Game, GameGrid, Player, Strategy, mod, printAscii;

  mod = function(n, m) {
    return ((n % m) + m) % m;
  };

  Strategy = {
    cooperate: 0,
    defect: 1
  };

  Game = {
    prisonersDilemma: [[3, 1], [4, 2]],
    stagHunt: [[4, 1], [3, 2]],
    chicken: [[3, 2], [4, 1]],
    deadlock: [[2, 1], [4, 3]],
    stableChicken: [[1, 2], [4, 3]]
  };

  Player = (function() {
    Player.strategy = Strategy.cooperate;

    Player.mostRecentScore = -1;

    Player.grid = null;

    Player.i = -1;

    Player.j = -1;

    function Player(grid, i, j, strategy) {
      this.grid = grid;
      this.i = i;
      this.j = j;
      this.strategy = strategy;
    }

    Player.prototype.playAgainst = function(neighbor) {
      var payoffMatrix;
      payoffMatrix = this.grid.game;
      return payoffMatrix[this.strategy][neighbor.strategy];
    };

    Player.prototype.getNeighbors = function() {
      return [this.grid.get(this.i - 1, this.j - 1), this.grid.get(this.i - 1, this.j), this.grid.get(this.i - 1, this.j + 1), this.grid.get(this.i, this.j - 1), this.grid.get(this.i, this.j + 1), this.grid.get(this.i + 1, this.j - 1), this.grid.get(this.i + 1, this.j), this.grid.get(this.i + 1, this.j + 1)];
    };

    return Player;

  })();

  GameGrid = (function() {
    GameGrid.n = 0;

    GameGrid.players = [];

    GameGrid.game = null;

    function GameGrid(n, game) {
      var i, j, _i, _j, _ref, _ref1;
      this.players = [];
      this.game = game;
      this.n = n;
      for (i = _i = 0, _ref = this.n - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        for (j = _j = 0, _ref1 = this.n - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          this.players.push(this.randomPlayer(i, j));
        }
      }
    }

    GameGrid.prototype.get = function(i, j) {
      return this.players[this.n * (mod(i, this.n)) + mod(j, this.n)];
    };

    GameGrid.prototype.randomPlayer = function(i, j) {
      var r, strategy;
      r = Math.random();
      strategy = Strategy.cooperate;
      if (r > 0.5) {
        strategy = Strategy.defect;
      }
      return new Player(this, i, j, strategy);
    };

    GameGrid.prototype.iterate = function() {
      var highestNeighborScore, highestScoringNeighbor, isLowest, neighbor, player, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3, _ref4, _results;
      _ref = this.players;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        player = _ref[_i];
        player.mostRecentScore = 0;
        _ref1 = player.getNeighbors();
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          neighbor = _ref1[_j];
          player.mostRecentScore += player.playAgainst(neighbor);
        }
      }
      _ref2 = this.players;
      _results = [];
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        player = _ref2[_k];
        isLowest = true;
        _ref3 = player.getNeighbors();
        for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
          neighbor = _ref3[_l];
          if (neighbor.mostRecentScore < player.mostRecentScore) {
            isLowest = false;
          }
        }
        if (isLowest) {
          highestNeighborScore = 0;
          highestScoringNeighbor = null;
          _ref4 = player.getNeighbors();
          for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
            neighbor = _ref4[_m];
            if (neighbor.mostRecentScore > highestNeighborScore) {
              highestScoringNeighbor = neighbor;
              highestNeighborScore = neighbor.score;
            }
          }
          _results.push(player.strategy = highestScoringNeighbor.strategy);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    GameGrid.prototype.simulate = function(k) {
      var i, _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= k ? _i <= k : _i >= k; i = 0 <= k ? ++_i : --_i) {
        _results.push(this.iterate());
      }
      return _results;
    };

    return GameGrid;

  })();

  printAscii = function(grid) {
    var i, j, rep, _i, _j, _ref, _ref1;
    for (i = _i = 0, _ref = grid.n - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      rep = "";
      for (j = _j = 0, _ref1 = grid.n - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
        rep += grid.get(i, j).strategy.toString();
      }
      console.log(rep);
    }
    return console.log("\n");
  };

  $(function() {
    var animate, canvas, canvasSize, ctx, drawGrid, g, trials;
    trials = 500;
    canvas = document.getElementById("gameCanvas");
    ctx = canvas.getContext("2d");
    canvasSize = 1200;
    drawGrid = function(grid, ctx) {
      var i, j, squareSize, _i, _ref, _results;
      squareSize = canvasSize / grid.n;
      _results = [];
      for (i = _i = 0, _ref = grid.n - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (j = _j = 0, _ref1 = grid.n - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
            if (grid.get(i, j).strategy === Strategy.cooperate) {
              ctx.fillStyle = "#EEEEEE";
            } else {
              ctx.fillStyle = "#555555";
            }
            _results1.push(ctx.fillRect(squareSize * i, squareSize * j, squareSize, squareSize));
          }
          return _results1;
        })());
      }
      return _results;
    };
    g = new GameGrid(100, Game.prisonersDilemma);
    animate = function() {
      var fps;
      g.iterate();
      drawGrid(g, ctx);
      fps = 5;
      return setTimeout(function() {
        return window.requestAnimationFrame(animate);
      }, 1000 / fps);
    };
    return window.requestAnimationFrame(animate);
  });

}).call(this);
