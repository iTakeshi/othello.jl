const MC_MONTE_CARLO_REPEAT = 100

type MCPlayer
  color::Int
end

function operate(player::MCPlayer, board::Board)
  candidates = find_candidates(board, player.color)
  length(candidates) == 0 && return (0, 0)
  length(candidates) == 1 && return first(candidates)

  rate = map(pos -> monte_carlo(player, board, pos), candidates)

  return candidates[indmax(rate)]
end

function monte_carlo(player::MCPlayer, board::Board, position)
  wins = 0
  for repeat = 1:MC_MONTE_CARLO_REPEAT
    tmp = deepcopy(board)
    over = 0

    set(tmp, player.color, position)

    while over == 0
      enemy_candidates = find_candidates(tmp, -player.color)
      if length(enemy_candidates) > 0
        (x, y) = enemy_candidates[floor(length(enemy_candidates) * rand()) + 1]
        tmp = set(tmp, -player.color, (x, y))
      end

      candidates = find_candidates(tmp, player.color)
      if length(candidates) > 0
        (x, y) = candidates[floor(length(candidates) * rand()) + 1]
        tmp = set(tmp, player.color, (x, y))
      end

      over = gameover(tmp)
    end

    wins += over == player.color ? 1 : 0
  end

  return wins / MC_MONTE_CARLO_REPEAT
end
