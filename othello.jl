const NULL  =  0
const BLACK =  1
const WHITE = -1
typealias Board Array{Int, 2}
typealias Position (Int, Int)

type GameData
  board_list::Vector{Board}
  turn_list::Vector{Int}
end
GameData() = GameData(Board[], Int[])

function init_board()
  board = zeros(Int, 6, 6)::Board
  board[3, 3] = board[4, 4] = WHITE
  board[3, 4] = board[4, 3] = BLACK
  board
end

function find_turnable(board::Board, color, position; check=false)
  (x, y) = position
  turnable = Position[]

  1 <= x <= 6 || return turnable
  1 <= y <= 6 || return turnable
  board[x, y] != NULL && return turnable

  for dx in -1:1
    for dy in -1:1
      dx == dy == 0 && continue
      1 <= x + dx <= 6 || continue
      1 <= y + dy <= 6 || continue
      board[x + dx, y + dy] == -color || continue

      partial = [(x + dx, y + dy)]
      sx, sy = dx, dy
      while 1 <= x + dx + sx <= 6 &&
            1 <= y + dy + sy <= 6 &&
            board[x + dx + sx, y + dy + sy] == -color
        push!(partial, (x + dx + sx, y + dy + sy))
       sx += dx
        sy += dy
      end

      if 1 <= x + dx + sx <= 6 &&
         1 <= y + dy + sy <= 6 &&
         board[x + dx + sx, y + dy + sy] == color
        check && return [(x, y)]
        turnable = union(turnable, partial)
      end
    end
  end
  check && return Position[]
  return turnable
end

function set(board::Board, color, position)
  position == (0, 0) && return board
  (x, y) = position
  turnable = find_turnable(board, color, (x, y))

  if  length(turnable) == 0
    show(board)
    println((color, position))

    throw(ArgumentError)
  end

  for (tx, ty) = turnable
    board[tx, ty] = color
  end
  board[x, y] = color
  return board
end

function find_candidates(board::Board, color)
  candidates = Position[]
  for x = 1:6
    for y = 1:6
      if length(find_turnable(board, color, (x, y), check=true)) > 0
        push!(candidates, (x, y))
      end
    end
  end
  return candidates
end

function score(board::Board)
  sum(board)
end

function gameover(board::Board)
  cand_b = find_candidates(board, BLACK)
  cand_w = find_candidates(board, WHITE)
  if length(cand_b) + length(cand_w) == 0
    over = sign(score(board))
    return over == 0 ? 10 : over
  else
    return 0
  end
end

function show(board::Board)
  print("    a b c d e f\n")
  print("   -------------\n")
  for x = 1:6
    print("$x | ")
    for y = 1:6
      board[x, y] == NULL  && (str = "  ")
      board[x, y] == BLACK && (str = "o ")
      board[x, y] == WHITE && (str = "x ")
      print(str)
    end
    print("|\n")
  end
  print("   -------------\n\n")
end

function null_size(board::Board)
  return length(findin(board, NULL))
end

function mobility(board, color, position)
  turnable = find_turnable(board, color, position)

  for (x, y) = turnable
    m = 0
    for dx = -1:1
      for dy = -1:1
        (dx == 0 && dy == 0) && next
        (1 <= x + dx <= 6) || next
        (1 <= y + dy <= 6) || next

        board[x + dx, y + dy] == NULL && (m += 1)
      end
    end
  end

  return m
end

function to_s(pos::Position)
  (x, y) = pos
  alphabet = ["a", "b", "c", "d", "e", "f"]
  y = alphabet[y]

  return "$x$y"
end
