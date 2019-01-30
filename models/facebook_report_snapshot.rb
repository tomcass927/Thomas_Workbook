class FacebookReportSnapshot < ActiveRecord::Base
  self.table_name = "FacebookReportSnapshot"
  belongs_to :campaign_activity, class_name: 'CampaignActivity', primary_key: 'CampaignActivityKey'
  has_one :campaign_activity, class_name: 'CampaignActivity', primary_key: 'CampaignActivityKey', foreign_key: 'ActivityKey'

	def Total_Aprox_Spend
		 if self.Spend.nil? && self.LinkClicks > 0
		 	(self.LinkCPC * self.LinkClicks).round(2)
		 elsif self.Spend.nil?
		 	0
		 elsif self.Spend >= 0
		 	self.Spend
		end
	end 

	def Impressions_Remaining
		if self.campaign_activity.Calculated_Impressions_Requested.nil? && self.campaign_activity
				(self.campaign_activity.Actual_ValueRequested.to_i - self.Impressions.to_i).round(2)
			elsif self.campaign_activity.Calculated_Impressions_Requested >= 0 && self.campaign_activity
				(self.campaign_activity.Calculated_Impressions_Requested - self.Impressions).round(2)
			else
				"All"
			end
		end

	def Remaining_Budget
		if self.campaign_activity && self.campaign_activity.Calculated_AW_Budget.nil?
				"CCC"
 		elsif self.campaign_activity && self.campaign_activity.Calculated_AW_Budget.to_i >= 0
 				(self.campaign_activity.Calculated_AW_Budget - (self.Total_Aprox_Spend)).round(2)
 		else 
 				"OverSpent"
		end
	end

	def FB_CPM
		if self.Impressions > 0 && self.LinkClicks > 0
 			((self.Total_Aprox_Spend) / (self.Impressions / 1000) ).round(2)
 		else 
 			"NIS/CCC"
 		end
	end

	def FB_Clicks_Remaining
		if (self.campaign_activity.Clicks_Requested - self.LinkClicks).round(2) > 0
 	 		(self.campaign_activity.Clicks_Requested - self.LinkClicks).round(0)
 	 	else 
 	 		"Completed/CCC"
 	 	end
	end

	def PacePerDay
		if self.Impressions_Remaining.nil?
			nil
		elsif self.Impressions_Remaining > 0 && ((self.campaign_activity.EndDate) - (self.TimeStamp.to_date)).to_i > 0
	(self.Impressions_Remaining / (((self.campaign_activity.EndDate) - (self.TimeStamp.to_date)).to_i)).round(0)
		else 
			"Completed/CCC"
		end
	end

	def DaysLeft
		if (((self.campaign_activity.EndDate) - (self.TimeStamp.to_date)).to_i) > 0
			(((self.campaign_activity.EndDate) - (self.TimeStamp.to_date)).to_i)
		else 
			"Completed/CCC"
		end
	end

	def ClickPacePerDay
 	  if (self.campaign_activity.Clicks_Requested - self.LinkClicks).round(2) > 0 && ((self.campaign_activity.EndDate) - (self.TimeStamp.to_date)).to_i > 0
			(((self.campaign_activity.Clicks_Requested - self.LinkClicks).round(2)) / self.DaysLeft).round(0)
		else 
			"Completed/CCC"
		end
	end

	def AlertFlag
		if self.Impressions_Remaining.nil?
			nil
		elsif self.Impressions_Remaining > 0 && self.FB_Clicks_Remaining.to_i > 0
		  timediff = (Time.now.to_date - self.campaign_activity.StartDate).to_i
	 	  if (timediff < 0  && self.Impressions.nil?)
	 	  			"Alert"
	 	  elsif (timediff == 0  && self.Impressions.nil?)
	 	  			"StartedToday"
	 	  elsif (timediff > 0  && self.Impressions.nil?)
	 	  			"FutureCampaign"
	 	  elsif (timediff > 0  && self.ClickPacePerDay.to_i > 5 && self.PacePerDay.to_i > 1000)
	 	  			"HighImp/ClickPacePerDay"
	 	   elsif (timediff > 0  && self.ClickPacePerDay.to_i < 5 && self.PacePerDay.to_i > 1000)
	 	  			"HighPacePerDay"
	 	   elsif (timediff > 0  && self.ClickPacePerDay.to_i > 5 && self.PacePerDay.to_i < 1000)
	 	  			"HighClickPacePerDay"
		   else 
		  			"CampaignDeployingNormally"
		   end
		elsif (self.FB_Clicks_Remaining.to_i > 0) && (self.Impressions_Remaining.to_i <= 0)
   			"OnlyClicksRemain"
		else 
			"Completed/CCC"
		  end
		end

end

 			
