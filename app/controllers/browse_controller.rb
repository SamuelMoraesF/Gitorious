class BrowseController < ApplicationController
  before_filter :find_project_and_repository
  before_filter :check_for_commits
  before_filter :find_head_candidate_if_no_head_param, :only => [:index]
  
  # backwards-compat redirects, remove at will
  def browse() redirect_to(:action => "index") end
  def log() redirect_to(:action => "index") end
  
  def index
    @git = @repository.git
    @commits = @repository.paginated_commits(params[:head], params[:page])
    # TODO: Patch rails to keep track of what it responds to so we can DRY this up
    @atom_auto_discovery_url = project_repository_formatted_log_path(@project, @repository, "master", :atom)
    respond_to do |format|
      format.html
      format.atom
    end
  end
  
  def tree
    @git = @repository.git
    @commit = @git.commit(params[:sha])
    unless @commit
      redirect_to project_repository_tree_path(@project, @repository, "HEAD", params[:path])
      return
    end
    path = params[:path].blank? ? [] : ["#{params[:path].join("/")}/"] # FIXME: meh, this sux
    @tree = @git.tree(@commit.tree.id, path)
  end
  
  def commit
    @diffmode = params[:diffmode] == "sidebyside" ? "sidebyside" : "inline"
    @git = @repository.git
    @commit = @git.commit(params[:sha])
    @diffs = @commit.diffs
    @comment_count = @repository.comments.count(:all, :conditions => {:sha1 => @commit.id})
  end
  
  def diff
    @git = @repository.git
    @diff = @git.diff(params[:sha], params[:other_sha])
  end
  
  def blob
    @git = @repository.git
    @commit = @git.commit(params[:sha])
    unless @commit
      redirect_to project_repository_blob_path(@project, @repository, "HEAD", params[:path])
      return
    end
    @blob = @git.tree(@commit.tree.id, ["#{params[:path].join("/")}"]).contents.first
    render_not_found and return unless @blob
    unless @blob.respond_to?(:data) # it's a tree
      redirect_to project_repository_tree_path(@project, @repository, @commit.id, params[:path])
    end
  end
  
  def raw
    @git = @repository.git
    @commit = @git.commit(params[:sha])
    unless @commit
      redirect_to project_repository_raw_blob_path(@project, @repository, "HEAD", params[:path])
      return
    end
    @blob = @git.tree(@commit.tree.id, ["#{params[:path].join("/")}"]).contents.first
    render_not_found and return unless @blob
    if @blob.size > 500.kilobytes
      flash[:error] = "Blob is too big. Clone the repository locally to see it"
      redirect_to project_repository_path(@project, @repository) and return
    end
    render :text => @blob.data, :content_type => @blob.mime_type
  end
  
  def archive
    @git = @repository.git
    
    @commit = @git.commit(params[:sha])
    
    if @commit
      prefix = "#{@project.slug}-#{@repository.name}"
      data = @git.archive_tar_gz(params[:sha], prefix + "/")
      
      send_data(data, :type => 'application/x-gzip', 
        :filename => "#{prefix}.tar.gz")
    else
      flash[:error] = "The given repository or sha is invalid"
      redirect_to project_repository_path(@project, @repository) and return
    end
  end
  
  protected
    def find_project_and_repository
      @project = Project.find_by_slug!(params[:project_id])
      @repository = @project.repositories.find_by_name!(params[:repository_id])
    end
    
    def check_for_commits
      unless @repository.has_commits?
        flash[:notice] = "The repository doesn't have any commits yet"
        redirect_to project_repository_path(@project, @repository) and return
      end
    end
    
    def find_head_candidate_if_no_head_param
      if params[:head].blank?
        redirect_to project_repository_log_path(@project, @repository, @repository.head_candidate.name)
        return
      end
    end
end
