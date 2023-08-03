class V1::GamesController < ApplicationController

  skip_before_action :verify_authenticity_token

  before_action :check_token, only: [:index, :create, :create_teams, :get_teams, :join_teams, :card, :show, :add_users, :get_users, :get_scores, :increase_score, :get_user_cards, :take_card, :throw_card]
  before_action -> { verify_game() }, only: [:create_teams, :get_teams, :join_teams, :card, :show, :update, :add_users, :get_users, :get_scores, :increase_score, :get_user_cards, :take_card, :throw_card]

  def index
    
    #Partidas creadas por el usuario
    my_games= Game.where(user: current_user).order(finished: :asc, max_groups: :asc).pluck(:token).map { |token| {"game_token": token} }

    #Partidas no creadas por el usuario (pero que sí participa)
    games_from_user = Game.where.not(user: current_user).joins(:users).where(users: { id: current_user.id }).order(finished: :asc, max_groups: :asc)
    games_from_teams = Game.where.not(user: current_user).joins(teams: :users).where(users: { id: current_user.id }).order(finished: :asc, max_groups: :asc)
    other_games = (games_from_user + games_from_teams).uniq.pluck(:token).map { |token| { "game_token": token } }

    render json: {
      "my_games": my_games,
      "other_games": other_games
    }
    
  end

  def show
    game = get_game
    
    # Verificar si el current_user está unido al juego directamente a través de la relación users
    is_user_joined_directly = game.users.include?(current_user)
    
    # Verificar si el current_user está unido al juego a través de los equipos (teams)
    is_user_joined_through_teams = game.teams.any? { |team| team.users.include?(current_user) }
    
    render json: {
        "max_groups": game.max_groups,
        "administrator_id": game.user_id,
        "finished": game.finished,
        "joined": is_user_joined_directly || is_user_joined_through_teams
    }
  end
 
  def update
    game = get_game
    if game.user.id != current_user.id
      render(json: format_error('No es administrador de la partida'), status: 401)
    elsif game.finished
      render json: { error: "El juego ya finalizó" }, status: :bad_request
    else
      game.update(finished: true)
      head :ok
    end
  end

  def create
    if params[:max_groups]==0 || params[:max_groups]>1
      card_symbols = Game.cards.keys
      random_card = card_symbols.sample
      game = Game.create!(card: random_card, max_groups: params[:max_groups], user: current_user)
      if game.persisted?
        render(json: { "game_token": game.token }, status: 200)
      else
        render(json: format_error(game.errors.full_messages), status: 401)
      end
    else
      render(json: format_error('Error al crear la partida. Revise la modalidad'), status: 400)
    end
  end

  def create_teams # Falta verificar que no esté finalizado
    game = get_game
    if game.max_groups==0
      render(json: format_error('No se pueden crear grupos en partidas individuales'), status: 400)
    elsif params[:team_name].nil?
      render(json: format_error('Error. Petición inválida'), status: 400)
    elsif game.teams.count<game.max_groups
      team = game.teams.find_by(name: params[:team_name])
      if team.blank?
        team = game.teams.create!(name: params[:team_name])
        render(json: {"team_id":team.id}, status: 200)
      else
        render(json: format_error('Ya existe un equipo con ese nombre'), status: 400)
      end
    else
      render(json: format_error('Se ha llegado a la cantidad máxima de grupos'), status: 400)
    end
  end

  def get_teams
    teams = get_game.teams
    team_data = teams.map do |team|
      {
        id: team.id,
        name: team.name
      }
    end
    render json: { teams: team_data }, status: :ok
  end
  
  def join_teams #Falta verificar que no esté finalizado
    if get_game.max_groups>0
      teams = get_game.teams
      team = teams.find_by(id: params[:team_id])
      if team.blank?
        render(json: format_error('El equipo no existe para esta partida'), status: 400)
      else
        # Eliminar relacion con cualquier grupo (si ésta existe)
        teams.each do |team|
          if current_user.teams.include?(team)
            current_user.teams.delete(team)
          end
        end

        # Crea la nueva relacion
        team.users << current_user

        # Asigna las cartas al usuario (si éste no tiene cartas)
        if current_user.my_cards.where(game: get_game).blank?
          card_symbols = Game.cards.keys
          cards = card_symbols.sample(7)
          cards.each do |card|
            current_user.my_cards.create!(game: get_game, card: card)
          end
        end

        head :ok
      end
    else
      render(json: format_error('No se puede unir a grupos en partidas individuales'), status: 400)
    end
  end

  def add_users
    game = get_game
    if game.max_groups>0
      render(json: format_error('No se puede unir como individual en partidas grupales'), status: 400)
    elsif !game.users.find_by(id: current_user.id).nil?
      render(json: format_error('No puedes unirte otra vez a la misma partida'), status: 400)
    else
      current_user.games_users.create(game: game)

      # Asigna las cartas al usuario (si éste no tiene cartas)
      if current_user.my_cards.where(game: get_game).blank?
        card_symbols = Game.cards.keys
        cards = card_symbols.sample(7)
        cards.each do |card|
          current_user.my_cards.create!(game: get_game, card: card)
        end
      end
      head :ok 
    end
  end

  def get_users
    game = get_game
    if game.max_groups>0
      users_data = game.teams.map do |team|
        team.users.map do |user|
          {"id":user.id,"team":{"id":team.id,"name":team.name}}
        end
      end.flatten
    else
      users_data = game.users.map do |user|
        {"id":user.id,"team":nil}
      end
    end
    render(json: {"users":users_data}, status: 200)
  end

  def get_scores # Falta verificar que quien solicita ver los scores pertenezca a la partida
    game = get_game
    if game.max_groups>0
      scores = game.teams.map do |team|
        {"id":team.id,"name":team.name,"score":team.score}
      end
    else
      scores = game.games_users.map do |game_user|
        {"id":game_user.user.id,"name":game_user.user.name,"score":game_user.score}
      end
    end
    render(json: {"scores":scores}, status: 200)
  end

  def increase_score
    game = get_game
    if game.finished
      render(json: format_error('No se puede modificar el puntaje a una partida finalizada'), status: 401)
    elsif game.user.id != current_user.id
      render(json: format_error('No es administrador de la partida'), status: 401)
    else
      if game.max_groups>0 # Por equipos
        team = game.teams.find_by(id: params[:entity_id])
        if !team.nil?
          team.score=team.score+1
          team.save!
          head :ok
        else
          render(json: format_error('El equipo no existe para esta partida'), status: 401)
        end
      else
        game_user = game.games_users.find_by(user_id: params[:entity_id])
        if !game_user.nil?
          game_user.score=game_user.score+1
          game_user.save!
          head :ok
        else
          render(json: format_error('El usuario no existe para esta partida'), status: 401)
        end
      end
    end
  end

  def get_user_cards # Falta verificar que el usuario esté en la partida    
    game = get_game
    user = User.find_by(id: params[:user_id])
    if user.nil?
      render(json: format_error('El usuario no existe para esta partida'), status: 401)
    else
      cards = user.my_cards.where(game_id: game.id).map do |my_card|
        {"id": my_card.id,"url":my_card.card}
      end
      
      show_cards = false
      
      if game.max_groups>0 # Partida por equipos
        same_team = false
        game.teams.each do |game_team|
          current_user.teams.each do |current_user_team|
            user.teams.each do |user_team|
              if game_team.id == current_user_team.id && game_team.id == user_team.id
                same_team = true
              end
            end 
          end 
        end
        if same_team
          show_cards = true
        end
        
      else # Partida individual
        if current_user.id == user.id
          show_cards = true
        end
      end

      if show_cards
        render(json: {"amount_cards":cards.length ,"cards":cards}, status: 200)
      else
        render(json: {"amount_cards":cards.length ,"cards":nil}, status: 200)
      end
      
    end
  end

  def take_card
    game = get_game
    if game.finished
      render(json: format_error('No se pueden tomar cartas en una partida finalizada'), status: 401)
    else
      card_symbols = Game.cards.keys
      random_card = card_symbols.sample
      my_new_card = current_user.my_cards.create!(game: get_game, card: random_card)
      render(json: {"id":my_new_card.id,"url":my_new_card.card.to_s.humanize}, status: 200)
    end
  end

  def throw_card
    game = get_game
    if game.finished
      render(json: format_error('No se pueden tirar cartas en una partida finalizada'), status: 401)
    else
      my_card = current_user.my_cards.find_by(game: get_game,id: params[:card_id])
      if my_card.nil? #Verificar que la carta la tiene
        render(json: format_error('No puedes lanzar una carta que no tienes'), status: 401)
      else
        get_game.update(card: my_card.card)
        my_card.delete
        head :ok
      end
    end
  end

  def card #Falta verificar que pertenezca a la partida
    render(json: {"id":get_game.card_before_type_cast,"url":get_game.card.to_s.humanize}, status: 200)
  end

  def reset_game
    game = get_game
    
    if game.user_id != current_user.id
      render(json: format_error('No eres administrador para restablecer la partida'), status: 401)
      return
    end
    
    if game.finished
      render(json: format_error('No se puede restablecer una partida ya finalizada'), status: 401)
      return
    end

    game.my_cards.destroy_all
    if game.max_groups>0
      game.teams.each do |team|  # Se recorren los usuarios de los equipos para setear cartas
        team.users.each do |user|
          card_symbols = Game.cards.keys
          cards = card_symbols.sample(7)
          cards.each do |card|
            user.my_cards.create!(game: get_game, card: card)
          end
        end 
      end
    else 
      game.users.each do |user| # Idem con usuarios
        card_symbols = Game.cards.keys
        cards = card_symbols.sample(7)
        cards.each do |card|
          user.my_cards.create!(game: get_game, card: card)
        end
      end 
    end
    head :ok
  end

  private

  # Metodos auxiliares

  def game_params
    params.require(:game).permit(:team_name, :card_id, :team_id)
  end

  def verify_game
    if get_game.blank?
      render(json: format_error('Token de partida inválido'), status: 401)
    end
  end

  def get_game #Variable caché
    game = Game.find_by(token: params[:id])
  end

end
