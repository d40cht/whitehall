module ClassificationRoutesHelper
  def classification_path(classification, options={})
    polymorphic_path(classification_model_name(classification), options.merge(id: classification))
  end

  def classification_url(classification, options={})
    polymorphic_url(classification_model_name(classification), options.merge(id: classification))
  end

  private

  # NOTE: This method could (possibly) be dropped once Draper has been removed/replaced.
  def classification_model_name(classification)
    klass = classification.is_a?(Draper::Decorator) ? classification.model.class : classification.class
    klass.name.underscore
  end
end
