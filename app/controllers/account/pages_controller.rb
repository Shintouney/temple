class Account::PagesController < ApplicationController
  include HighVoltage::StaticPage
  include AccountController
end
