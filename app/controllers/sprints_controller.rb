class SprintsController < ApplicationController
  before_filter :get_sprints
  
  before_filter :validate_sprint, :only => :show
  
  def get_sprints
    @sprints = Sprint.all(:order => "name")
  end
  
  # GET /sprints
  # GET /sprints.json
  def index
    reload_sprint_list
    sprint = Sprint.find(:first, :order => "updated_at DESC")
    #sprint = Card.find(:first, :order => "card_updated DESC").sprint
    redirect_to sprint_path(sprint)
    
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: @sprints }
    # end
  end
  
  # def streamer
  #   self.response_body = Enumerator.new do |y|
  #     100000.times do |i|
  #       y << "This is line #{i}\n"
  #       self.response.headers['Last-Modified'] = Time.now.to_s
  #     end
  #   end
  # end
  
  def validate_sprint
    sprint = Sprint.find(params[:id])
    if sprint.start_date.nil? || sprint.end_date.nil? || sprint.start_date == sprint.end_date
      flash[:alert] = 'Sprint requires valid start and end dates'
      redirect_to edit_sprint_path(sprint)
    end
  end
  
  # GET /sprints/1
  # GET /sprints/1.json
  def show
    reload_sprint(params[:id])
        
    @sprint = Sprint.find(params[:id])
    
    @cards = @sprint.cards.order("card_updated desc")
    
    @card_days = @cards.group_by { |t| t.card_updated.beginning_of_day }
    
    @features = @cards.where("card_type = 'Story'")
    @bugs = @cards.where("card_type = 'Bug'")
    @tasks = @cards.where("card_type = 'Task'")
    
    @to_do = @cards.where("status IN ('Open','Reopened')").order("card_updated desc")
    @in_progress = @cards.where("status = 'In Progress'").order("card_updated desc")
    @in_review = @cards.where("status = 'In Review'").order("card_updated desc")
    @in_qa = @cards.where("status = 'In QA'").order("card_updated desc")
    @done = @cards.where("status = 'Closed'").order("card_updated desc")

    @wip = @cards.where("status IN ('In Progress','In Review', 'In QA')").order("card_updated desc")

    @done_each_day = []
    @points_remaining = []
    @days = []
    @target_points = []
    @target_high_points = []
    @target_low_points = [] 
    @days_in_sprint = (@sprint.end_date.to_date - @sprint.start_date.to_date).to_i+1
    @workdays_in_sprint = 0
    @points_this_sprint = @sprint.cards.sum('points')
    @workdays_in_sprint = work_days_between(@sprint.start_date,@sprint.end_date)
    @developers = @cards.where("status <> 'Open' AND (status <> 'Closed' OR (card_updated > '#{1.day.ago}'))").order("assignee, card_updated desc").group_by { |t| t.assignee }

    @sprint_progress_to_do = @to_do.sum('points').to_f / @points_this_sprint * 100
    @sprint_progress_wip = @wip.sum('points').to_f / @points_this_sprint * 100
    @sprint_progress_done = @done.sum('points').to_f / @points_this_sprint * 100

    days_so_far = 0
    done_so_far = 0
    index = 0
    
    @sprint.start_date.upto(@sprint.end_date) do |day|
      if day.strftime('%A') != 'Saturday' && day.strftime('%A') != 'Sunday'
        index = index + 1   
        target_point = @points_this_sprint - @points_this_sprint/@workdays_in_sprint.to_f*index
        target_high_point = target_point + target_point * 0.2
        target_low_point = target_point - target_point * 0.2
        @target_points << target_point
        @target_high_points << target_high_point
        @target_low_points << target_low_point
        @days << day.strftime('%a').to_s

        if day.to_date <= Time.now.in_time_zone.to_date
          days_so_far = days_so_far + 1
          done_this_day = 0
          @sprint.cards.each do |card|
            if card.status.to_s == 'Closed' && card.card_updated.to_date == day.to_date
              done_this_day = done_this_day + card.points.to_i
            end
          end
          done_so_far = done_so_far + done_this_day
          @points_remaining << @points_this_sprint - done_so_far      
        end 
      end
    end


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sprint }
    end
  end

  # GET /sprints/new
  # GET /sprints/new.json
  def new
    @sprint = Sprint.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sprint }
    end
  end

  # GET /sprints/1/edit
  def edit
    @sprint = Sprint.find(params[:id])
  end

  # POST /sprints
  # POST /sprints.json
  def create
    @sprint = Sprint.new(params[:sprint])

    respond_to do |format|
      if @sprint.save
        format.html { redirect_to @sprint, notice: 'Sprint was successfully created.' }
        format.json { render json: @sprint, status: :created, location: @sprint }
      else
        format.html { render action: "new" }
        format.json { render json: @sprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sprints/1
  # PUT /sprints/1.json
  def update
    @sprint = Sprint.find(params[:id])

    respond_to do |format|
      if @sprint.update_attributes(params[:sprint])
        format.html { redirect_to @sprint, notice: 'Sprint was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sprints/1
  # DELETE /sprints/1.json
  def destroy
    @sprint = Sprint.find(params[:id])
    @sprint.destroy

    respond_to do |format|
      format.html { redirect_to sprints_url }
      format.json { head :no_content }
    end
  end
  
end
