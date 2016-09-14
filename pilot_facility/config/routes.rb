Rails.application.routes.draw do
  root 'run#dashboard'
  get 'dashboard' => 'run#dashboard'
  get 'approval' => 'run#approval'
  get 'add_run' => 'run#add_run'
  post 'add_run' => 'run#confirm_run_add'
  get 'schedule' => 'run#schedule'
  post 'update_run' => 'run#update_run'
  patch 'update_run' => 'run#confirm_run_update'
  get 'search' => 'run#search'
  post 'search' => 'run#search_results'
  post 'data_results' => 'datapoint#results'
  post 'update_data' => 'datapoint#update_data'
  patch 'update_data' => 'datapoint#confirm_data_update'
  get 'add_data' => 'datapoint#add_data'
  post 'add_data' => 'datapoint#confirm_data_add'
  get 'report' => 'run#report'
  get 'add_sample_set' => 'datapoint#add_sample_set'
  post 'add_sample_set' => 'datapoint#confirm_sample_set'
  get 'comparison_report' => 'run#comparison_setup'
  post 'comparison_report' => 'run#comparison_report'
  post 'run_lineage' => 'run#run_lineage'
  get 'download_data' => 'run#download_data'
  get 'add_tot_protein' => 'datapoint#add_tot_protein'
  post 'add_tot_protein' => 'datapoint#confirm_tot_protein'
  get 'tot_prot_todb' => 'datapoint#tot_prot_todb'
  get 'add_pc' => 'datapoint#add_pc'
  post 'add_pc' => 'datapoint#confirm_pc'
  get 'pc_todb' => 'datapoint#pc_todb'
end
