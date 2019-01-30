
class Agency < ActiveRecord::Base
  self.table_name = "Agency"
  has_many :campaigns, class_name: 'Campaign', primary_key: 'Id'

  def my_special_method
    self.Id * 2
  end
end
