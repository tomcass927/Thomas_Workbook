class CampaignActivity < ActiveRecord::Base
  self.table_name = "CampaignActivity"
  has_many :facebook_report_snapshots, class_name: 'FacebookReportSnapshot', primary_key: 'ActivityKey', foreign_key: 'CampaignActivityKey'
  has_many :facebook_report_snapshot_histories, class_name: 'FacebookReportSnapshotHistory', primary_key: 'ActivityKey', foreign_key: 'CampaignActivityKey'
  belongs_to :campaign, class_name: 'Campaign', foreign_key: 'CampaignKey'

	def Calculated_AW_Budget
			(((self.Calculated_Impressions_Requested.to_i) / 1000) * 10 * 0.5)
	end


	def Impression_Spend
		if (self.QuantityOrdered.to_i) <= (self.Calculated_Impressions_Requested.to_i)
			(self.Calculated_AW_Budget * (0.2)).round(2)
		elsif (self.QuantityOrdered.to_i) > (self.Calculated_Impressions_Requested.to_i)
			(self.Calculated_AW_Budget * (0.2)).round(2)
		else
			nil 
		end
	end

	def Click_Spend
		if (self.QuantityOrdered.to_i) <= (self.Calculated_Impressions_Requested.to_i)
			(self.Calculated_AW_Budget * (0.8)).round(2)
		elsif (self.QuantityOrdered.to_i) > (self.Calculated_Impressions_Requested.to_i)
			(self.Calculated_AW_Budget * (0.8)).round(2)
		else
			nil
		end
	end

	def Clicks_Requested
			((self.Calculated_Impressions_Requested.to_i) * 0.005).round(1)
	end

	def NumberOfDays
	(self.EndDate - self.StartDate).to_i
		end

	def Impression_Calculation
		(self.NumberOfDays * 1000)
	end


	def Calculated_Impressions_Requested
		if (self.QuantityOrdered.to_i) <= (self.Impression_Calculation.to_i)
			self.Impression_Calculation.to_i
		elsif (self.QuantityOrdered.to_i) > (self.Impression_Calculation.to_i)
			self.QuantityOrdered.to_i
		else 
			nil
		end
	end







end

