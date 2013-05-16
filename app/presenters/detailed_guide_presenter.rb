class DetailedGuidePresenter < Draper::Decorator
  include EditionPresenterHelper

  decorates :detailed_guide
end
