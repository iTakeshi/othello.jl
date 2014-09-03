type HumanPlayer
  color::Int
end

COLS = ["a", "b", "c", "d", "e", "f"]


function operate(player::HumanPlayer, board::Board)
  candidates = find_candidates(board, player.color)
  length(candidates) == 0 && return (0, 0)

  println(map(pos -> to_s(pos), candidates))

  move = (0, 0)
  while true
    move = from_s(strip(readline(STDIN)))
    findfirst(candidates, move) > 0 && break
    println("Invalid move, retry...")
  end

  return move
end

function to_s(pos::Position)
  (x, y) = pos
  y = COLS[y]

  return "$x$y"
end

function from_s(str)
  length(str) == 2 || return (0, 0)

  x = parseint(str[1])
  y = findfirst(COLS, string(str[2]))

  (1 <= x <= 6 && 1 <= y <= 6) || return (0, 0)

  return (x, y)
end
