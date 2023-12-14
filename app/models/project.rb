class Project < ApplicationRecord
    validates :name, presence: true
    validates :creator, presence: true
    # validates :public, presence: true
    validates :created, presence: true
    validates :repo, presence: true
end
