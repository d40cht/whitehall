class SpeechPresenter < Draper::Decorator
  include EditionPresenterHelper

  decorates :speech

  def delivered_on
    date_microformat(:delivered_on)
  end
end
