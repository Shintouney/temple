class UsersDecorator < Draper::CollectionDecorator
  def as_json_for_autocomplete
    decorated_collection.map(&:as_json_for_autocomplete)
  end
end
