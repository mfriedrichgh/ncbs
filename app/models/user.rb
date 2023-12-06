class User < ApplicationRecord
    def create(name, real_name, password)
        @name = name
        @real_name = real_name
        @password = password
    end
end