Rails.application.routes.draw do
  root 'run#dashboard'
  get 'submission' => 'run#submission'
  post 'submission' => 'run#send_submission'
  get 'schedule' => 'run#schedule'
  post 'schedule' => 'run#send_schedule'
  get 'update' => 'run#update'
  post 'update' => 'run#send_update'
  get 'search' => 'run#search'
  post 'search' => 'datapoint#results'
  get 'update_data' => 'datapoint#update_data'
  post 'update_data' => 'datapoint#send_update_data'
end
