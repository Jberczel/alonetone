# -*- encoding : utf-8 -*-
class ForumsController < ApplicationController
  
  before_filter :require_login, :except => [:index, :show]
  before_filter :find_user, :only => :index
  before_filter :set_forum_tab, :set_html_meta

  # GET /forums
  # GET /forums.xml
  def index
    # reset the page of each forum we have visited when we go back to index
    session[:forums_page] = nil
    
    @forums = Forum.ordered
    set_interesting_topics
    render @forums 
  end

  # GET /forums/1
  # GET /forums/1.xml
  def show
    @forum = Forum.find_by_permalink(params[:id])
    handle_forum_session
    
    respond_to do |format|
      format.html do # show.html.erb
        @topics = @forum.topics.sticky_and_recent.paginate :page => current_page, :per_page => 20
      end
      format.xml  { render :xml => @forum }
    end
  end

  def new
    @forum = Forum.new
  end

  # GET /forums/1/edit
  def edit
    @forum = Forum.find_by_permalink(params[:id])
  end

  def create
    @forum = Forum.new(params[:forum])
    if @forum.save
      redirect_to(@forum), 'Forum was created.' 
    else
      render :action => "new"
    end
  end

  def update
    @forum = Forum.find_by_permalink(params[:id])
    if @forum.update_attributes(params[:forum])
      flash[:notice] = 'Forum was successfully updated.'
      redirect_to(@forum) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @forum = Forum.find_by_permalink(params[:id])
    @forum.destroy

    redirect_to(forums_path) 
  end
  
  protected
  
  def set_interesting_topics
    @user_topics = Topic.replied_to_by(@user).collect(&:topic) if logged_in?
    @popular_topics = Topic.popular.collect(&:first)
    @replyless_topics = Topic.replyless
  end
  
  def authorized?
    admin?
  end
  
  def set_html_meta
    @page_title = 'alonetone Forums'
    @description = "alonetone forums. Discuss making music, free music, the changing music world, and whatever else comes to you"
    @keywords = 'alonetone, forums, music, discussion, share'
  end
  
  def handle_forum_session
    session[:forums] ||= {}
    session[:forums][@forum.id] = Time.now.utc
    
    if current_page > 1
      session[:forums_page] ||= Hash.new(1)
      session[:forums_page][@forum.id] = current_page 
    end
  end
  
  def set_forum_tab
    @tab = "forums"
  end
end
