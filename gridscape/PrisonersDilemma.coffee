# need to redefine mod to behave correctly with negative numbers
mod = (n, m) ->
	return ((n % m) + m) % m

Strategy =
	cooperate: 0
	defect: 1

Game =
	prisonersDilemma: [[3, 1], [4, 2]]
	stagHunt: [[4, 1], [3, 2]]
	chicken: [[3, 2], [4, 1]]
	deadlock: [[2, 1], [4, 3]]
	stableChicken: [[1, 2], [4, 3]]

class Player
	@strategy = Strategy.cooperate
	@mostRecentScore = -1
	@grid = null
	@i = -1
	@j = -1

	constructor: (grid, i, j, strategy) ->
		@grid = grid
		@i = i
		@j = j
		@strategy = strategy

	# Plays a one-shot Prisoner's Dilemma game.
	# Payoff matrix (C=cooperate, D=defect):
	#
	# 		C 		D
	#	C 	3	|	1
	#	D 	4	|	2
	#
	playAgainst: (neighbor) ->
		payoffMatrix = @grid.game
		return payoffMatrix[@strategy][neighbor.strategy]

	# Returns a list of the 8 Moore neighbors surrounding the player
	getNeighbors: () ->
		return [@grid.get(@i-1, @j-1), @grid.get(@i-1, @j), @grid.get(@i-1, @j+1),
				@grid.get(@i, @j-1), 	@grid.get(@i, @j+1),
				@grid.get(@i+1, @j-1), @grid.get(@i+1, @j), @grid.get(@i+1, @j+1)]
		# Von Neumann neighborhood: return [@grid.get(@i-1, @j), @grid.get(@i, @j-1), @grid.get(@i, @j+1), @grid.get(@i+1, @j+1)]

class GameGrid
	@n = 0
	@players = []
	@game = null

	# Creates an nxn grid of players.
	constructor: (n, game) ->
		@players = []
		@game = game
		@n = n
		for i in [0..@n-1]
			for j in [0..@n-1]
				@players.push(@randomPlayer(i, j, 0.70))

	# Gets the player in cell (i, j)
	# The game grid is a torus, meaning that the rightmost cells are neighbors with the leftmost cells
	# and the top cells are neighbors with the bottom cells (the game grid "wraps around").
	get: (i, j) ->
		return @players[@n*(mod(i, @n)) + mod(j, @n)]

	# Generates a player at cell (i, j) in the grid with a randomly chosen strategy 
	# (given probability p that it will cooperate).
	randomPlayer: (i, j, prob) ->
		r = Math.random()
		strategy = Strategy.cooperate
		if r > prob
			strategy = Strategy.defect
		return new Player(@, i, j, strategy)

	# Runs a single iteration of the Prisoner's Dilemma simulation.
	iterate: () ->
		# For each player, play Prisoner's Dilemma with everyone in its Moore neighborhood.
		for player in @players
			player.mostRecentScore = 0
			for neighbor in player.getNeighbors()
				player.mostRecentScore += player.playAgainst(neighbor)

		# Check each player to see if it is the lowest scoring player in its neighborhood.
		# If so, switch player's strategy to that of its highest-scoring neighbor.
		for player in @players
			isLowest = true
			for neighbor in player.getNeighbors()
				if neighbor.mostRecentScore < player.mostRecentScore
					isLowest = false
			if isLowest
				# Get the neighbor with the highest score
				highestNeighborScore = 0
				highestScoringNeighbor = []
				for neighbor in player.getNeighbors()
					if neighbor.mostRecentScore > highestNeighborScore
						highestScoringNeighbors = [neighbor]
						highestNeighborScore = neighbor.score
					else if neighbor.mostRecentScore == highestNeighborScore
						highestScoringNeighbors.push(neighbor)
				# Set the strategy to the highest scoring neighbor's strategy
				r = Math.floor(Math.random()*highestScoringNeighbors.length)
				console.log("length: " + highestScoringNeighbors.length)
				console.log("r: " + r)
				player.strategy = highestScoringNeighbors[r].strategy

	# Runs k iterations of the simulation.
	simulate: (k) ->
		for i in [0..k]
			@iterate()

printAscii = (grid) ->
	# For use in the console
	for i in [0..grid.n-1]
		rep = ""
		for j in [0..grid.n-1]
			rep += grid.get(i, j).strategy.toString()
		console.log(rep)
	console.log("\n")

$( () ->
	trials = 500

	canvas = document.getElementById("gameCanvas")
	ctx = canvas.getContext("2d")

	canvasSize = 1200

	drawGrid = (grid, ctx) ->
		squareSize = canvasSize / grid.n
		for i in [0..grid.n-1]
			for j in [0..grid.n-1]
				if grid.get(i, j).strategy == Strategy.cooperate
					ctx.fillStyle = "#EEEEEE"
				else
					ctx.fillStyle = "#555555"
				ctx.fillRect(squareSize*i, squareSize*j, squareSize, squareSize)

	g = new GameGrid(100, Game.chicken)

	animate = () ->
		g.iterate()
		drawGrid(g, ctx)
		fps = 5
		setTimeout( () ->
			window.requestAnimationFrame(animate)
		, 1000 / fps)

	window.requestAnimationFrame(animate)
		
)