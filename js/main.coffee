snake = $('<div>')
snakeSeg = $('<div>')
direction = 'down'
sibs = 6
leadSeg = null
rBounds = null
lBounds = null
tBounds = null
bBounds = null
moveInterval = null
newApple = null
moveTime = 150
score = 0
container = $('#play-wrap')

snakeSeg.addClass('snake-seg')

$(->
	lBounds = container.offset().left
	rBounds = container.outerWidth() + lBounds - 10

	tBounds = container.offset().top
	bBounds = container.outerHeight() + tBounds - 12

	leadSeg = snakeSeg.clone();
	leadSeg.position({
		top: (rBounds / 2).FindClosestNumberThatIsDivisibleBy(10)
		left: (bBounds / 2).FindClosestNumberThatIsDivisibleBy(10)
		})

	leadSeg.addClass('lead-seg');
	container.append(leadSeg)
	
	growSnake(sibs)

	addNewApple();
	
	moveInterval = setInterval(->
		offset = leadSeg.offset()
		switch direction
			when "left"
				moveSeg leadSeg, offset.top, offset.left - 11
			when "right"
				moveSeg leadSeg, offset.top, offset.left + 11
			when 'up'
				moveSeg leadSeg, offset.top - 11, offset.left
			when 'down'
				moveSeg leadSeg, offset.top + 11, offset.left
	, moveTime
	)
	
	$('body').keydown((e)->
		arrowKeys = [37,38,39,40]
		if arrowKeys.indexOf(e.keyCode) > 0
			e.preventDefault()
	)

	$('body').keyup((e)->
		e.preventDefault()
		switch e.keyCode
			when 37
				if direction != 'right'
					direction = 'left'
			when 38
				if direction != 'down'
					direction = 'up'
			when 39 
				if direction != 'left'
					direction = 'right'
			when 40
				if direction != 'up'
					direction = 'down'
			when 78
				addNewApple()
		)	

	if typeof(Storage) != "undefined"
		loadHighscores()
)

moveSeg = (s, t, l) ->
	offset = s.offset()
	prevSib = s.prev('div')

	if l > rBounds
		l = lBounds
	if l < lBounds
		l = rBounds
	if t < tBounds
		t = bBounds
	if t > bBounds
		t = tBounds

	s.offset({
		top:t
		left:l
		})

	isCollision = collision(leadSeg, newApple)
	if isCollision
		appendNewSeg()
		score +=1
		$('#score-span').text(score)



	if leadSeg != s
		isSelfCollision = collision(leadSeg, s)
		if isSelfCollision
			alert('Crashed!')
			clearInterval(moveInterval)

	
	if prevSib.length != 0
		moveSeg prevSib, offset.top, offset.left


appendNewSeg = ->
	lastSeg = $(leadSeg.siblings().first())
	lastOffset = lastSeg.offset()

	lastSeg.before(newApple)
	newApple
		.offset({
			top: (lastOffset.top - 12)
			left: (lastOffset.left + 10)
			})

	# we have to counter the fact that we've added a new segment to the dom by shifting it all right 10px
	$('.snake-seg').each(->
		l = $(this).offset().left
		$(this).offset({left: l - 10})
		)

	addNewApple()
	setTimer()

growSnake = (newSibs) ->
	i = 0

	while i < newSibs
    	sib = snakeSeg.clone()
    	leadSeg.before sib
    	i++

addNewApple = ->
	left = getRndBetween(lBounds, rBounds).FindClosestNumberThatIsDivisibleBy(10)
	top = getRndBetween(tBounds, bBounds).FindClosestNumberThatIsDivisibleBy(10)
	newApple = snakeSeg.clone()
	$('#play-wrap').append(newApple)
	newApple
		.css({
		backgroundColor: '#996f54'
		})
		.offset({top: top, left:left})

collision = ($div1, $div2) ->
  x1 = $div1.position().left
  y1 = $div1.position().top
  h1 = $div1.outerHeight(true)
  w1 = $div1.outerWidth(true)
  b1 = y1 + h1
  r1 = x1 + w1
  x2 = $div2.position().left
  y2 = $div2.position().top
  h2 = $div2.outerHeight(true)
  w2 = $div2.outerWidth(true)
  b2 = y2 + h2
  r2 = x2 + w2
  return false  if b1 < y2 or y1 > b2 or r1 < x2 or x1 > r2
  true

setTimer = ->
	moveTime -= 2
	clearInterval(moveInterval)
	moveInterval = setInterval(->
		lOffSet = leadSeg.offset()
		switch direction
			when 'left'
				moveSeg(leadSeg, lOffSet.top, lOffSet.left - 11)
			when 'right'
				moveSeg(leadSeg, lOffSet.top, lOffSet.left + 11)
			when 'up'
				moveSeg(leadSeg, lOffSet.top - 11, lOffSet.left)
			when 'down'
				moveSeg(leadSeg, lOffSet.top + 11, lOffSet.left)
	, moveTime
	)

getRndBetween = (lo, hi) ->
	Math.floor(lo + Math.random() * (hi - lo));

Number.prototype.FindClosestNumberThatIsDivisibleBy = (n) ->
	Math.round(this / n) * n

stop = ->
	clearInterval(moveInterval)

loadHighscores = ->
	highscores = []
	if localStorage.highscores
		highscores = JSON.parse(localStorage.highscores)

		if highscores.length > 1
			highscores = highscores.sort((a,b)->
				a[1] < b[1]
				)

		i = 0

		while i <= 5
			if highscores[i]
				displayHighscore highscores[i]
			i++

displayHighscore = (highscore) ->
	$('#highscores-list').append $('<li>').html(highscore[0] + ' <strong>' + highscore[1] + '</strong')

saveHighscore = ->
	score = [[$('#player').val()], $('#score').val()]

	if localStorage.highscores
		scores = JSON.parse(localStorage.highscores)
	else
		scores = []
		

	scores.push(score);
	localStorage.setItem('highscores', JSON.stringify(scores))





