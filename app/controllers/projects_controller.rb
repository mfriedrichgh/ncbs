require 'uri'
require 'net/http'

class ProjectsController < ApplicationController
    before_action :authenticate_user!
    def index
        @projects = Project.all
    end

    def new
        @project = Project.new
    end

    def show
        @project = Project.find(params[:id])
        # If the project is visible to the current user, either by being public or owned by the current user.
        @visible = @project && (@project.public == true || User.find_by_id(@project.creator).email == current_user.email)
        @editable = User.find_by_id(@project.creator).email == current_user.email
        if @visible
            render 'overview'
        else
            render "index"
        end
    end

    def binaries
        @project = Project.find(params[:id])
        # If the project exists and is either publicly visible or created by the currently logged in user.
        @visible = @project && (@project.public == true || User.find_by_id(@project.creator).email == current_user.email)
        @editable = User.find_by_id(@project.creator).email == current_user.email
        if @visible
            # Download the project.
            url = URI.parse('http://backend:8080/download/' + @project.id.to_s)
            req = Net::HTTP::Get.new(url.to_s)
            res = Net::HTTP.start(url.host, url.port) { |http|
                http.request(req)
            }
            body = res.body if res.is_a?(Net::HTTPSuccess)
            send_data body,
            :filename => @project.name + ".tar.gz",
            :type => "application/gzip"
        else
            redirect_to "#"
        end
    end

    def destroy
        @project = Project.find(params[:id])
        if User.find_by_id(@project.creator).email == current_user.email
            @project.destroy
            redirect_to "/", status: :see_other
        else
            render "overview"
        end
    end
    
    def rebuild
        @project = Project.find(params[:id])
        if User.find_by_id(@project.creator).email == current_user.email
            # Rebuild the project
            url = URI.parse('http://backend:8080/build/' + @project.id.to_s)
            req = Net::HTTP::Get.new(url.to_s)
            res = Net::HTTP.start(url.host, url.port) {|http|
                http.request(req)
            }
        else
            puts "no auth to rebuild"
        end
        redirect_to "#"
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
            url = URI.parse('http://backend:8080/clone/' + @project.id.to_s)
            req = Net::HTTP::Post.new(url.to_s)
            res = Net::HTTP.start(url.host, url.port) {|http|
                http.request(req)
            }
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
