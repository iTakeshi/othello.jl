type MinMaxPlayer
  color::Int
  rating::Array{Float64, 2}
end

function MinMaxPlayer(color)
  default = [
    100 -50  20  20 -50 100;
    -50 -90   0   0 -90 -50;
     20   0   0   0   0  20;
     20   0   0   0   0  20;
    -50 -90   0   0 -90 -50;
    100 -50  20  20 -50 100;
  ]
  return MinMaxPlayer(color, default)
end

function MinMaxPlayer(color, w::Vector{Float64})
  rating = [
    w[1] w[2] w[3] w[3] w[2] w[1];
    w[2] w[4] w[5] w[5] w[4] w[2];
    w[3] w[5] w[6] w[6] w[5] w[3];
    w[3] w[5] w[6] w[6] w[5] w[3];
    w[2] w[4] w[5] w[5] w[4] w[2];
    w[1] w[2] w[3] w[3] w[2] w[1];
  ]
  return MinMaxPlayer(color, rating)
end


const MM_ALPHA = -32768
const MM_BETA  =  32768

const DEPTH = 6

function alphabeta(player::MinMaxPlayer, depth, table, turn, alpha, beta)
  process = find_candidates(table, turn)
  if length(process) == 0
    enemy = find_candidates(table, -turn)
    if length(enemy) == 0 || depth == 0
      p = score(table) * player.color
      return p > 0 ? MM_BETA : MM_ALPHA
    else
      return alphabeta(player, depth, table, -turn, alpha, beta)
    end
  end
  if depth <= 0
    return sum(player.rating .* table) * player.color
  end

  for (x, y) = process
    board = deepcopy(table)
    board = set(board, turn, (x, y))
    r = alphabeta(player, depth - 1, board, -turn, alpha, beta)
    if player.color == turn
      alpha = maximum([alpha, r])
      alpha >= beta && return beta
    else
      beta = minimum([beta, r])
      alpha >= beta && return alpha
    end
  end
  return player.color == turn ? alpha : beta
end

function operate(player::MinMaxPlayer, table)
  process = find_candidates(table, player.color)
  length(process) == 0 && return (0, 0)
  length(process) == 1 && return first(process)

  rate = 0
  moves = Position[]
  push!(moves, first(process))

  for (x, y) in process
    board = deepcopy(table)
    board = set(board, player.color, (x, y))
    r = alphabeta(player, DEPTH, board, -player.color, MM_ALPHA, MM_BETA)
    rate < r && ((rate, moves) = (r, Position[]))
    rate == r && push!(moves, (x, y))
  end

  return moves[floor(length(moves) * rand()) + 1]
end



# function operate(player::MinMaxPlayer, board::Board)
#   candidates = find_candidates(board, player.color)
#   length(candidates) == 0 && return (0, 0)
#   length(candidates) == 1 && return first(candidates)
#
#   rate = 0
#   process = Position[]
#   push!(process, first(candidates))
#
#   for (x, y) = candidates
#     tmp = deepcopy(board)
#     tmp = set(tmp, player.color, (x, y))
#     r = alphabeta(player, board, -player.color, DEPTH, MM_ALPHA, MM_BETA)
#     rate <  r && ((rate, process) = (r, Position[]))
#     rate == r && push!(process, (x, y))
#   end
#
#   process = unique(process)
#
#   return process[floor(length(process) * rand()) + 1]
# end
#
# function alphabeta(player::MinMaxPlayer, board::Board, color, depth, alpha, beta)
#   candidates = find_candidates(board, color)
#
#   if length(candidates) == 0
#     enemy_candidates = find_candidates(board, -color)
#     if length(enemy_candidates) == 0 || depth == 0
#       p = score(board) * player.color
#       return p > 0 ? MM_BETA : MM_ALPHA
#     else
#       return alphabeta(player, board, -color, depth, alpha, beta)
#     end
#   end
#
#   depth <= 0 && return sum(RATING .* board) * player.color
#
#   for (x, y) = candidates
#     tmp = deepcopy(board)
#     set(tmp, color, (x, y))
#     r = alphabeta(player, tmp, -color, depth - 1, alpha, beta)
#
#     if player.color == color
#       alpha = maximum([alpha, r])
#       alpha >= beta && return beta
#     else
#       beta = minimum([beta, r])
#       alpha >= beta && return alpha
#     end
#   end
#
#   return player.color == color ? alpha : beta
# end

# function alphabeta(player::MinMaxPlayer, board::Board, color, depth, alpha, beta)
#   candidates = find_candidates(board, color)
#   enemy_candidates = find_candidates(board, -color)
#
#   length(candidates) + length(enemy_candidates) == 0 && return score(board) * player.color > 0 ? MM_BETA : MM_ALPHA
#   depth <= 0 && return sum(RATING .* board) * color
#
#   length(candidates) == 0 && return alphabeta(player, board, -color, depth - 1, alpha, beta)
#
#   for (x, y) = candidates
#     tmp = deepcopy(board)
#     alpha = maximum([alpha, -alphabeta(player, board, -color, depth - 1, -alpha, -beta)])
#     alpha >= beta && return alpha
#   end
#
#   return alpha
# end

# function alphabeta(player, board, color, depth, alpha, beta)
#   candidates = find_candidates(board, color)
#   enemy_candidates = find_candidates(board, -color)
#
#   if length(candidates) == 0
#     if length(enemy_candidates) == 0 || depth == 0
#       p = score(board) * player.color
#       return p > 0 ? MM_BETA : MM_ALPHA
#     else
#       return alphabeta(player, board, -color, depth, alpha, beta)
#     end
#   end
#   depth <= 0 && return sum(RATING .* board) * player.color
#
#   if color == player.color
#     if length(enemy_candidates) > 0
#       for pos = enemy_candidates
#         alpha = maximum([alpha, alphabeta(player, board, -color, depth - 1, alpha, beta)])
#         alpha >= beta && return beta
#       end
#       return alpha
#     else
#       return alphabeta(player, board, color, depth - 1, alpha, beta)
#     end
#   else
#     for pos = candidates
#       beta = minimum([beta, alphabeta(player, board, color, depth - 1, alpha, beta)])
#       alpha >= beta && return alpha
#     end
#     return beta
#   end
# end
