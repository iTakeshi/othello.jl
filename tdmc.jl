using Calculus

type TDMCPlayer
  color::Int
  w::Vector{Float64}
end
TDMCPlayer(color) = TDMCPlayer(color, zeros(Float64, 6))

const MONTE_CARLO_REPEAT = 100

const TDMC_ALPHA   = 0.08
const TDMC_LAMBDA  = 0.98
const TDMC_GAMMA   = 0.98
const TDMC_EPSILON = 0.01

function operate(player::TDMCPlayer, board::Board)
  candidates = find_candidates(board, player.color)

  length(candidates) == 0 && return (0, 0)
  length(candidates) == 1 && return first(candidates)

  values = map(position -> v_next(player, board, position), candidates)
  max = maximum(values)
  idx = findin(values, max)

  if rand() > TDMC_EPSILON
    position = candidates[idx[floor(length(idx) * rand()) + 1]]
  else
    position = candidates[floor(length(candidates) * rand()) + 1]
  end
  return position
end

function v_next(player::TDMCPlayer, board::Board, position)
  tmp = deepcopy(board)
  tmp = set(tmp, player.color, position)
  return large_v(board, player.w)
end

function large_v(board::Board, w)
  return dot(small_x(board), w)
end

function update_w(w, game_data::GameData)
  large_t = length(game_data.board_list)

  mc_prob = map(t -> small_r(game_data, t), 1:large_t)

  sum = 0
  for t = 1:large_t
    lrl = large_r_lambda(game_data, t, w, mc_prob)
    v = large_v(game_data, t, w)
    gradient = v_gradient(game_data, t, w)

    # show(game_data.board_list[t])
    # println(lrl, "     ", v, "     ", small_x(game_data.board_list[t]), "     ", gradient)

    sum += (tanh(lrl) - tanh(v)) * gradient
  end

  new_w = w + TDMC_ALPHA * sum
  println(new_w)
  return new_w
end

function large_r_lambda(game_data::GameData, t, w, mc_prob)
  large_t = length(game_data.board_list)

  sum = 0
  for n = 1:(large_t - t - 1)
    sum += TDMC_LAMBDA ^ (n - 1) * large_r_n(game_data, t, n, w, mc_prob)
  end

  sum += TDMC_LAMBDA ^ (large_t - t - 1) * large_r(game_data, t, mc_prob)

  return sum
end

function large_r_n(game_data::GameData, t, n, w, mc_prob)
  large_t = length(game_data.board_list)

  sum = 0
  for i = 0:(n - 1)
    sum += TDMC_GAMMA ^ i * mc_prob[t + i]
  end
  sum += TDMC_GAMMA ^ n * large_v(game_data, t + n, w)

  return sum
end

function large_r(game_data::GameData, t, mc_prob)
  large_t = length(game_data.board_list)

  sum = 0
  for i = t:large_t
    sum += TDMC_GAMMA ^ (i - t) * mc_prob[i]
  end

  return sum
end

function small_r(game_data::GameData, t)
  board = game_data.board_list[t]
  color = game_data.turn_list[t]

  wins = 0
  for repeat = 1:MONTE_CARLO_REPEAT
    tmp = deepcopy(board)
    over = 0
    while over == 0
      candidates = find_candidates(tmp, color)
      if length(candidates) > 0
        (x, y) = candidates[floor(length(candidates) * rand()) + 1]
        tmp = set(tmp, color, (x, y))
      end

      enemy_candidates = find_candidates(tmp, -color)
      if length(enemy_candidates) > 0
        (x, y) = enemy_candidates[floor(length(enemy_candidates) * rand()) + 1]
        tmp = set(tmp, -color, (x, y))
      end

      over = gameover(tmp)
    end

    wins += over == 1 ? 1 : 0
  end

  return wins / MONTE_CARLO_REPEAT
end

function large_v(game_data::GameData, t, w)
  return large_v(game_data.board_list[t], w)
end

function v_gradient(game_data::GameData, t, w)
  x = small_x(game_data.board_list[t])
  return gradient(ww -> dot(x, ww), w)
end

function small_x(board::Board)
  cell = [
    board[1,1] board[1,6]          0          0          0          0 board[6,1] board[6,6];
    board[1,2] board[1,5] board[2,1] board[2,6] board[5,1] board[5,6] board[6,2] board[6,5];
    board[1,3] board[1,4] board[3,1] board[3,6] board[4,1] board[4,6] board[6,3] board[6,4];
    board[2,2] board[2,5]          0          0          0          0 board[5,2] board[5,5];
    board[2,3] board[2,4] board[3,2] board[3,5] board[4,2] board[4,5] board[5,3] board[5,4];
    board[3,3] board[3,4]          0          0          0          0 board[4,3] board[4,4];
  ]
  return map(row -> sum(cell[row,:]), 1:size(cell)[1])
end
