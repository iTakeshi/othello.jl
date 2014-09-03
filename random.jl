type RandomPlayer
  color::Int
end

function operate(player::RandomPlayer, board::Board)
  candidates = find_candidates(board, player.color)
  length(candidates) == 0 && return (0, 0)

  return candidates[floor(length(candidates) * rand()) + 1]
end
