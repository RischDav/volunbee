class UsersController < ApplicationController
  skip_before_action :check_user_released, only: [:locked]

  def locked
    # Diese Aktion zeigt die gesperrte Seite an
  end
end