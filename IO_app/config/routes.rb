Rails.application.routes.draw do
root 'form#input'
get 'add_data' => 'form#add_data'
end
