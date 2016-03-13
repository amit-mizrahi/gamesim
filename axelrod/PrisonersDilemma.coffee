Move =
	cooperate: 0
	defect: 1

class Player

	constructor: () ->
		@strategy = null # "strategy" is a function of the other player's Move that returns a Move
		@lastMove = null
		@score = 0

class TitForTatPlayer extends Player
	# Player with tit-for-tat strategy
	# Tit-for-tat: start by cooperating. If other player defects, start defecting until other player cooperates.
	constructor: () ->
		super()
		@strategy = (oMove) ->
			if oMove == Move.cooperate
				return Move.cooperate
			else if oMove == Move.defect
				return Move.defect
			else
				return Move.cooperate

class GrimTriggerPlayer extends Player
	# Player with grim trigger strategy
	# Grim trigger: start by cooperating. If other player defects, continue defecting until termination.
	@hasDefected = false

	constructor: () ->
		super()
		@hasDefected = false
		@strategy = (oMove) ->
			if @hasDefected
				return Move.defect
			else
				if oMove == Move.cooperate or oMove == null
					return Move.cooperate
				else
					@hasDefected = true
					return Move.defect

class RandomPlayer extends Player
	# Player with random strategy
	# Randomly selects between "cooperate" and "defect" based on value of random variable

	constructor: () ->
		super()
		@strategy = (oMove) ->
			r = Math.random()
			if r > 0.5
				return Move.defect
			else
				return Move.cooperate


class IteratedPrisonersDilemma
	# Prisoner's dilemma with n iterations
	@player = null
	@opponent = null
	@n = 0

	constructor: (n) ->
		@player = new GrimTriggerPlayer()
		@opponent = new RandomPlayer()
		@n = n

	getScore: (playerMove, opponentMove) ->
		payoffMatrix = [[3, 1], [4, 2]]
		return payoffMatrix[playerMove][opponentMove]

	play: () ->
		pmove = @player.strategy(@opponent.lastMove)
		omove = @opponent.strategy(@player.lastMove)
		@player.score += @getScore(pmove, omove)
		@opponent.score += @getScore(omove, pmove)
		@player.lastMove = pmove
		@opponent.lastMove = omove

	run: () ->
		for i in [0..@n]
			@play()

i = new IteratedPrisonersDilemma(50)
i.run()
console.log("Player score: " + i.player.score)
console.log("Opponent score: " + i.opponent.score)