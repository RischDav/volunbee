class OrganizationsController < ApplicationController
    def intex
        @organizations = Organizations.all
        render json: @organizations, status: :ok
end
