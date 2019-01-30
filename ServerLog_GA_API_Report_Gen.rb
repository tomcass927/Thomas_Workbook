require 'json'
require "sqlite3"
require 'csv'
require 'net/http'
require 'uri'
require 'date'
require 'active_support/all'


def all_mailing_lists_api_curl_ruby
		uri = URI.parse("PUT SERVER LOCATION HERE - REMOVED FOR DEMO")
		request = Net::HTTP::Get.new(uri)
		request["Authorization"] = "Basic PUT AUTH TAG HERE - REMOVED FOR DEMO"

		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		 http.request(request) 
				end
			api_output = response.body
			
			obj = JSON.parse(api_output)
				obj['data'].each do |x|
					ga_mailing_name = x['name'] 
					ga_mailing_id = x['id'] 
					ga_from_name = x['d_from_name']
					ga_from_email = x['d_from_email']

	db = SQLite3::Database.new "ga_2_collection.db"
			db.execute "insert into ga_table_1 (ga_mailing_name, ga_mailing_id, ga_from_name, ga_from_email) values ( ? , ? , ? , ? )", 
						[ga_mailing_name, ga_mailing_id, ga_from_name, ga_from_email]
						db.close
		sleep 0.15 
	end
end

########The ABOVE COPILES A LIST OF ALL MAILING LISTS ON SERVER################


def pull_down_all_campaigns
db = SQLite3::Database.new "ga_2_collection.db"
		db.execute ("select * FROM ga_table_1" ) do |db_row|
			select_id = db_row[1]
				uri = URI.parse("PUT SERVER LOCATION HERE - REMOVED FOR DEMO")
				request = Net::HTTP::Get.new(uri)
				request["Authorization"] = "Basic PUT AUTH TAG HERE - REMOVED FOR DEMO"

				req_options = {
  					use_ssl: uri.scheme == "https",
				}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		 http.request(request) 
				end
		api_output = response.body

		obj = JSON.parse(api_output)
			obj['data'].each do |x|
				campaign_name = x['name'] 
				ga_mailing_list_id = x['mailing_list_id'] 
				mailing_list_name = x['mailing_list_name']
				segmentation_criteria_id = x['segmentation_criteria_id']
				unq_campaign_id = x['id']
			if x['dispatch'].nil? == true
				finished_at = "placeholder"
				state_of_deployment = "placeholder"
				elsif
				finished_at = x['dispatch']['finished_at']
				state_of_deployment = x['dispatch']['state']
			end

		db.execute "insert into ga_table_2 (campaign_name, ga_mailing_list_id, mailing_list_name, segmentation_criteria_id, unq_campaign_id, state_of_deployment, finished_at) values (?, ?, ?, ?, ?, ?, ?)",
			[campaign_name, ga_mailing_list_id, mailing_list_name, segmentation_criteria_id, unq_campaign_id, state_of_deployment, finished_at]
			sleep 0.15
		end
	end
end


########The ABOVE COPILES A LIST OF ALL CAMPAIGNS ON SERVER################

def pull_down_campaign_statistics

db = SQLite3::Database.new "ga_2_collection.db"
		db.execute ("select * FROM ga_table_2" ) do |db_row|
			select_campaign_id = db_row[7]
		uri = URI.parse("PUT SERVER LOCATION HERE - REMOVED FOR DEMO")
		request = Net::HTTP::Get.new(uri)
		request["Authorization"] = "Basic PUT AUTH TAG HERE - REMOVED FOR DEMO"

		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		 http.request(request) 
				end
			api_output = response.body

			obj = JSON.parse(api_output)
			
			if obj['data']['content_stats'].first.nil? == true
				next 
			elsif
			stats = obj['data']['content_stats'].first['stat_summary']
				records_delivered = stats["accepted"] 
				records_sent = stats["messages_sent"]
				total_opens = stats["opens_total"]
				unq_opens = stats["opens_unique"]
				total_clicks = stats["clicks_total"]
				unq_clicks = stats["clicks_unique"]
				total_bounces = stats["bounced"]
				soft_bounces = stats["bounces_unique_other"]
				total_scomps = stats["scomps_total"]
				total_unsubs = stats["unsubs_total"]


			mta_data = obj['data']['dispatch']
				virtual_mta_id = mta_data['virtual_mta_id']
				virtual_mta_name = mta_data['virtual_mta_name']

			match_data = obj['data']
				campaign_id = match_data['id']
				campaign_name = match_data['name']
				mailing_list_id = match_data['mailing_list_id']
				mailing_list_name = match_data['mailing_list_name']
				campaign_name = match_data['name']

	db.execute "insert into ga_table_3 (records_delivered, records_sent, total_opens, unq_opens, total_clicks, unq_clicks, total_bounces, soft_bounces, total_scomps, total_unsubs, virtual_mta_id, virtual_mta_name, campaign_id, mailing_list_id, mailing_list_name, campaign_name) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
			[records_delivered, records_sent, total_opens, unq_opens, total_clicks, unq_clicks, total_bounces, soft_bounces, total_scomps, total_unsubs, virtual_mta_id, virtual_mta_name, campaign_id, mailing_list_id, mailing_list_name, campaign_name]
		sleep 0.15
		end
	end
end


########The ABOVE COPILES A LIST OF ALL CAMPAIGNS STATISTICS ON SERVER################

def check_tables_for_stats 

  h = {}
 db = SQLite3::Database.new "ga_2_collection.db"                                #Database Open
  db.execute ("select * FROM smb_data" ) do |db_row|                            #Get List of Mailings to Look Up
    mapping_logic_dealer_id = db_row[1]                                         #Use Dealer ID to match against Mail File Name 
    amount = db_row[8]                                                          #Set Quantity Ordered to a Variable (contains extra characters)
    quantity = amount.gsub(/[\s,]/ ,"")                                         #Set Quantity Ordered to a Variable (removed extra characters)


    # GROUP STARTS HERE
    total_delivered = 0
    total_opens = 0
    total_clicks = 0 
    found = false


      db.execute ("select * FROM ga_table_1" ) do |db_row|                      #Database open - Select GA Table 1 - Mailing Lists Table 
        mailing_file_name = db_row[2]                                           #Set Mailing File Name to Variable 
        mail_file_id = db_row[1]                                                #Set Mail File Id to Variable 
          if mailing_file_name.include?("#{mapping_logic_dealer_id}")           #Conditional Statment to Map Smb Dealer Data to Green Arrow Server Data
              db.execute ("select * FROM ga_table_2 WHERE ga_mailing_list_id = '#{mail_file_id}'" ) do |db_row|    #Database Open - Campagin ID Table 
                campaign_name = db_row[2]                                       #Set Campagin Name to a Variable 
                unq_campaign_id = db_row[7]                                     #Set Campaign Id to a Variable
                  finished_at = db_row[5]                                       #Set Finished Time to a Variable
                  time_stamp = Date.strptime(finished_at)                       #Strip off hh:mm:ss from time stamp 
                  today = Date.current                                          #Set Todays Date to Variable 
                    if time_stamp.between?(today - 9, today)                    #Conditional - All mailings within the last 7 days 
                      found = true
                          db.execute ("select * FROM ga_table_3 WHERE campaign_id = '#{unq_campaign_id}'" ) do |db_row| #Database Open - Campaign Statistics Table
                            unq_campaign_name = db_row[1]                              #Set Unique Campaign Name to Variable
                         # full_campaign_name = "#{db_row[1]}".split("_")              #Split Value to Add Up Relative Stats into One Entry 
                         # unq_campaign_name = "#{full_campaign_name[0]}_#{full_campaign_name[1]}_#{full_campaign_name[2]}_#{full_campaign_name[3]}"
                         # puts unq_campaign_name
                            records_sent = db_row[5]                                    #Set Records Sent to a Variable
                            records_delivered = db_row[4]                               #Set Records Delivered to a Variable
                            unq_opens = db_row[7]                                       #Unique Opens 
                            unq_clicks = db_row[9]                                      #Unique Clicks 
                            virtual_mta_name = db_row[14]                               #Set Virtual MTA to a variable
                          
                          total_opens+=unq_opens.to_i
                          total_clicks+=unq_clicks.to_i
                          total_delivered+=records_delivered.to_i
                          

                            if quantity.to_i > records_delivered.to_i               #Conditional for Quantity and Amount Delivered
                              puts "ReMail Needed for #{unq_campaign_name} - Amount Delivered = #{records_delivered} on #{virtual_mta_name} - Records Sent = #{records_sent} - Quantity = #{quantity}"
                            elsif quantity.to_i < records_delivered.to_i
                              puts "Mailed_over for #{unq_campaign_name} - Amount Delivered = #{records_delivered} on #{virtual_mta_name} - Records Sent = #{records_sent}  - Quantity = #{quantity}"
                            else quantity.to_i == records_delivered.to_i
                              puts "Finished mailing for #{unq_campaign_name} - Amount Delivered = #{records_delivered} on #{virtual_mta_name} - Records Sent = #{records_sent} - Quantity = #{quantity}"
                            end                                                       #END FOR Conditional for Quantity and Amount Delivered
                        end                                                           #END FOR Database Open - Campaign Statistics Table
#                   else
#                    puts "older mailing"
              
                    end                                                               #END FOR Conditional - All mailings within the last 7 days 
              end                                                                     #END FOR Database Open - Campagin ID Table       
          end                                                                         #END FOR Conditional Statment to Map Smb Dealer Data to Green Arrow Server Data
      end                                                                             #END FOR Database open - Select GA Table 1 - Mailing Lists Table 

  # END OF GROUP
  puts total_delivered if found
  puts total_opens if found
  puts total_clicks if found 


  end                                                                                 #END FOR Get List of Mailings to Look Up
end                                                                                   #END FOR Method Check Tables for Stats 


##### Script Starts Here ######

#NOTE = Run this to get all mailing lists (Table 1 - List of Mail Files to Run Subsequent Methods - Use Mailing List IDs as your running list)

all_mailing_lists_api_curl_ruby 

#NOTE = Run this to pull down all campaigns for a loop of Mailing List IDs - see line 57 (Table 1 - Mailing ID = Mailing ID - Table 2)

pull_down_all_campaigns 

#NOTE = Run this to pull down specific campaign statistics - Use list of campaign IDs - See line 60 (Table 2 - Campaign ID = Campaign ID - Table 3)

pull_down_campaign_statistics

##Check Tables for SMB Stats#####

check_tables_for_stats