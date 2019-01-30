
class Campaign < ActiveRecord::Base
  self.table_name = "Campaign"
  belongs_to :agency, class_name: 'Agency', foreign_key: 'AgencyId'
  has_many :campaign_activities, class_name: 'CampaignActivity', primary_key: 'CampaignKey', foreign_key: 'CampaignKey'
end
