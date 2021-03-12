class Account::ProfilesController < ApplicationController
  include AccountController

  before_action :load_profile, only: [:edit, :update]

  def edit
  end

  def update
    if @profile.update_attributes(profile_params)
      redirect_to account_root_path, notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: :edit
    end
  end

  private

  def profile_params
    if params.key?(:profile)
      params.require(:profile).
        permit({:sports_practiced => []},
                :attendance_rate,
                {:fitness_goals => []},
                {:boxing_disciplines_practiced => []},
                :boxing_level,
                {:boxing_disciplines_wished => []},
                {:attendance_periods => []},
                {:weekdays_attendance_hours => []},
                {:weekend_attendance_hours => []},
                {:transportation_means => []},
                user_attributes: [:facebook_url,
                                  :linkedin_url,
                                  :professional_sector,
                                  :position,
                                  :company,
                                  :professional_address,
                                  :professional_zipcode,
                                  :professional_city,
                                  :education,
                                  :heard_about_temple_from])
    end
  end

  def load_profile
    @profile = current_user.profile || current_user.build_profile
  end
end
