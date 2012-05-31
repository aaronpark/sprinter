class SprintsController < ApplicationController
  # GET /sprints
  # GET /sprints.json
  def index
    @sprints = Sprint.all(:order => "end_date desc, xid desc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sprints }
    end
  end

  # GET /sprints/1
  # GET /sprints/1.json
  def show
    @sprint = Sprint.find(params[:id])
    @issues = HTTParty.get("http://jira.wantsa.com:38881/rest/api/2/search?jql=fixVersion=#{@sprint.xid}",{:basic_auth => auth})
    @start_date = @sprint.start_date
    @end_date = @sprint.end_date
    @done_each_day = []
    @points_remaining = []
    @days = []
    @points = 0
    @target_points = []
    @target_high_points = []
    @target_low_points = [] 
    @days_in_sprint = (@end_date.to_date - @start_date.to_date).to_i+1
    @workdays_in_sprint = 0
    
    @issues['issues'].each do |issue|
      @points = @points + issue['fields']['customfield_10013'].to_i
    end
    @start_date.upto(@end_date) do |day|
      if day.strftime('%A') != 'Saturday' && day.strftime('%A') != 'Sunday'
        @workdays_in_sprint = @workdays_in_sprint + 1
      end
    end 
    
    days_so_far = 0
    done_so_far = 0
    index = 0
    
    @start_date.upto(@end_date) do |day|
      if day.strftime('%A') != 'Saturday' && day.strftime('%A') != 'Sunday'
        index = index + 1   
        target_point = @points - @points/@workdays_in_sprint.to_f*index
        target_high_point = target_point + target_point * 0.2
        target_low_point = target_point - target_point * 0.2
        @target_points << target_point
        @target_high_points << target_high_point
        @target_low_points << target_low_point
        @days << day.strftime('%D').to_s

        if day.to_date <= Time.now.to_date
          days_so_far = days_so_far + 1
          done_this_day = 0
          @issues['issues'].each do |issue|
            if issue['fields']['status']['name'].to_s == 'Closed' && issue["fields"]["updated"].to_date == day.to_date
              done_this_day = done_this_day + issue['fields']['customfield_10013'].to_i
            end
          end
          done_so_far = done_so_far + done_this_day
          @points_remaining << @points - done_so_far
          
          if day.to_date == Time.now.to_date      
            if @points - done_so_far < target_low_point
              @progress_status = 'progress-warning'
            elsif @points - done_so_far > target_low_point && @points - done_so_far < target_high_point
              @progress_status = 'progress-success'
            elsif @points - done_so_far > target_high_point
              @progress_status = 'progress-danger'
            else
              @progress_status = 'progress-info'
            end
            @sprint_progress = days_so_far/@workdays_in_sprint.to_f*100
          end
          
                     
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
  
  def reload
    @project = HTTParty.get("http://jira.wantsa.com:38881/rest/api/2/project/WP",{:basic_auth => auth})
    sprints_added = 0
    @project['versions'].each do |version|
      if !Sprint.find_by_xid(version['id'])
        Sprint.create({:xid => version['id'], :name => version['name']})
        sprints_added = sprints_added + 1
      end
    end
    redirect_to sprints_path, notice: "#{pluralize(sprints_added, 'Sprint')} reloaded."

  end
  
end
