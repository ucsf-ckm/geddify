Geddify::Application.routes.draw do
  
  resources :gedifiles

  root :to => "gedifiles#index"
  
  match 'import_gedi_file', :to => "gedifiles#import_gedi_file"
  match 'import', :to => "gedifiles#import"
  match 'gedifiles/:id/ftp_send', :to => "gedifiles#ftp_send"
  match 'gedifiles/:id/email_send', :to => "gedifiles#email_send"
  match 'gedi_download/:auth_token', :to => "gedifiles#gedi_download"
  match 'file_download/:auth_token', :to => "gedifiles#file_download"
  match 'file_download_page/:auth_token', :to => "gedifiles#file_download_page"
  match 'ftp_sync', :to => "gedifiles#ftp_sync"
  match 'longform', :to => "gedifiles#longform"
  match 'editlongform/:id', :to => "gedifiles#editlongform"
  match 'ariel3', :to => "gedifiles#ariel3"
  match 'ariel4', :to => "gedifiles#ariel4"
  match 'short', :to => "gedifiles#short"
  match 'gedifiles/:id/forward', :to => "gedifiles#forward"
  match 'send_forward', :to => "gedifiles#send_forward"
  match 'gedifiles/:status/list', :to => "gedifiles#index"
  match 'gedifiles/:id/history', :to => "accesshistory#list"
end
