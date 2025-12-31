class GotyController < ApplicationController
  before_action   :is_admin?, except: :show

  def show
    @goty = Goty.find_by_year(params[:year])
    if @goty.blank? || @goty.goty_games.empty? || (!logged_in?  && !@goty.published?)
      render '404', status: 404
      return
    end
    page_title "#{@goty.year} GOTY"
  end

  def edit
    year = Date.today.year
    page_title "Editing #{year} GOTY"
    @goty = Goty.find_or_create_by(year: year)
    RecentGame.visible.goty_eligible.each do |game|
      (@goty.goty_games.where(game_id: game.id).size == 0) or next
      @goty.goty_games.create(game_id: game.id, sort: @goty.goty_games.size+1)
    end
  end

  def sort
    id_order = params[:game_ids]
    sort = 0 # set this here so it can be used by both the sorted and hidden games
    logger.debug "************ resorting games as #{id_order.inspect}..."
    id_order.each do |id|
      sort += 1
      logger.debug "************ id #{id} to order #{sort}..."
      GotyGame.update(id, sort: sort)
    end
    # in case a RecentGame has been hidden and thus isn't passed with id_order,
    # change its sort, too, so it doesn't potentioally take up one of the top
    # 10 spots
    sort += 1000 # shove them safely at the bottom of the list, but they don't
                # have to be sorted amongst each other so they can all get the
                # same big fake number
    logger.debug "************ moving hidden games to the bottom of the list..."
    GotyGame.where('id not in (?)', id_order).each do |gg|
      gg.update_attribute(:sort, sort)
    end
    head :ok
  end

  def update_explanation
    goty_game = GotyGame.find(params[:goty_game_id])
    if goty_game.update_attribute(:explanation, params[:goty_game][:explanation])
      head :ok
    else
      render json: goty_game.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update_published
    goty = Goty.find(params[:goty_id])
    if goty.update_attribute(:published, !goty.published?)
      head :ok
    else
      render json: goty.errors.full_messages, status: :unprocessable_entity
    end
  end

end