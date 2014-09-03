@everywhere include("othello.jl")
@everywhere include("minmax.jl")
@everywhere include("tdmc.jl")
@everywhere include("monte_carlo.jl")
@everywhere include("random.jl")
@everywhere include("human.jl")

# w = [3.2971282e-5,-2.900004,-1.0310278,-6.064045,-0.7198912,-5.8]
# w = [-1.50959886518761,1.4402238951057011,-1.900731894503075,0.2927312275096301,0.717920066379492,-0.03999600025010608]
# player1 = TDMCPlayer(BLACK, w)

#preset = Float64[100, -50, 20, -70, 0, 0]
#
#player1 = TDMCPlayer(BLACK, preset)
#player2 = TDMCPlayer(WHITE, preset)

# tdmc_rating = [255.40044692003707,126.14874230003001,311.3250268665813,-41.042268889679335,-1759.9360911330577,-1065.7001566525744]
tdmc_rating = [8.135505737619601,-0.64526103941445,-1.0309816648988748,-3.345033160754144,-5.091779726681128,2.900751983449407]
  player1 = MinMaxPlayer(BLACK, tdmc_rating)

# player1 = TDMCPlayer(BLACK)
player2 = RandomPlayer(WHITE)

show_step = true
  show_step = false

learn_tdmc = true
  learn_tdmc = false

wins = @parallel (+) for z = 1:100
  println("game = $z")

  game_data = GameData()

  board = init_board()
  push!(game_data.board_list, deepcopy(board))
  push!(game_data.turn_list, player1.color)
  show_step && show(board)

  over = 0
  while over == 0
    pos = operate(player1, board)
    if pos != (0, 0)
      board = set(board, player1.color, pos)
      push!(game_data.board_list, deepcopy(board))
      push!(game_data.turn_list, player2.color)
      show_step && show(board)
    end

    pos = operate(player2, board)
    if pos != (0, 0)
      board = set(board, player2.color, pos)
      push!(game_data.board_list, deepcopy(board))
      push!(game_data.turn_list, player1.color)
      show_step && show(board)
    end

    over = gameover(board)
  end

  if learn_tdmc
    new_w = update_w(player1.w, game_data)
    player1.w = new_w
      player2.w = new_w

    open("w.csv", "a") do out
      for wi in new_w
        write(out, "$wi,")
      end
      write(out, '\n')
    end
  end

  if over == BLACK
    println("o")
  else
    println("x")
  end
  if z % 10 == 0
    println("\n")
  end

  over == BLACK ? 1 : 0
end

println(wins)
println(player1.w)
