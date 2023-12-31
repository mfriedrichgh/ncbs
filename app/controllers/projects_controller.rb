require 'uri'

class ProjectsController < ApplicationController
    before_action :authenticate_user!
    def index
        @projects = Project.all
    end

    def show
        @project = Project.find(params[:id])
        # If the 
        @visible = @project && (@project.public == true || User.find_by_id(@project.creator).email == current_user.email)
        @editable = User.find_by_id(@project.creator).email == current_user.email
        if @visible
            render 'overview'
        else
            render 'notfound'
        end
    end

    def new
        @project = Project.new
    end

    def destroy
        puts "ATTEMPTED TO DESTROY"
        puts "ATTEMPTED TO DESTROY"
        puts "ATTEMPTED TO DESTROY"
        puts "ATTEMPTED TO DESTROY"
        puts "ATTEMPTED TO DESTROY"
        puts "ATTEMPTED TO DESTROY"
        @project = Project.find(params[:id])
        @project.destroy
        redirect_to :index, status: :see_other
    end

    def create
        @project = Project.new(name: project_params[:name], 
            repo: project_params[:repo], 
            public: project_params[:public],
            creator: current_user.id, 
            created: DateTime.current.to_date)

        @valid_name = project_params[:name] != ""
        @unique_name = Project.where(name: project_params[:name]).empty?
        @valid_repo = valid_url?(project_params[:repo])

        if @unique_name && @valid_repo && @valid_name && @project.save
            redirect_to @project
        else
            render :new, status: :unprocessable_entity
        end
    end

    private
    def project_params
        params.require(:project).permit(:name, :repo, :public)
    end

    def valid_url?(url)
        uri = URI.parse(url)
        uri.is_a?(URI::HTTP) && uri.host.present?
    rescue URI::InvalidURIError
        false
    end

end
