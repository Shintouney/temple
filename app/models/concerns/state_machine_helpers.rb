module StateMachineHelpers
  extend ActiveSupport::Concern

  included do
    scope :with_state, -> (states) { where(state: states) if states.present? }
    scope :with_states, -> (states) { where(state: states) if states.present? }
    scope :with_not_state, -> (states) { where.not(state: states) if states.present? }
    scope :with_not_states, -> (states) { where.not(state: states) if states.present? }
  end

  class_methods do
    def human_state_name(state_value)
      klass = self.name.classify.constantize
      state_obj = klass.aasm(:default).states.find { |s| s.name == state_value.to_sym }
      raise AASM::UndefinedState, "State :#{name} doesn't exist" if state_obj.nil?
      ::AASM::Localizer.new.human_state_name(klass, state_obj)
    end
  end

  def human_state_name
    self.aasm.human_state
  end
end
