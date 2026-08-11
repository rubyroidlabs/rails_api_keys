# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "ping", to: "ping#show"
      post "ping", to: "ping#create"
    end
  end
end
