require 'rubygems'
require 'nokogiri'
require 'selenium-webdriver'
require 'uri'
require "sqlite3"
require 'action_view'

include ActionView::Helpers::JavaScriptHelper

def login_green_arrow(driver, wait)
	driver.get 'SERVER SITE LOCATION HERE'
	sleep 5

	#GA2 Login User
	email_user = driver.find_element(:id, "user_session_username")
	email_user.send_keys("USER NAME HERE")

	#GA2 Login Password
	password_user = driver.find_element(:id, "user_session_password")
	password_user.send_keys("PASS WORD HERE")

	sleep 1 
	driver.find_element(:class, 'button').click 
	driver.get 'SITE LOCATION HERE'
end

def print_mail_file_names(driver, run_id)
	db = SQLite3::Database.new "ga_collection_2.db"

	db.execute( "select * from smb_data" ) do |db_row|
		driver.get 'SERVER SITE LOCATION HERE'
		loop do
			driver.find_elements(:css, '.data-table tbody tr').each do |row|
		
				name = row.find_element(:css, '.name').text
				if name.include?(db_row[10])
					puts "FOUND #{db_row[0]} #{db_row[1]} for #{name}"
					row.find_element(:css, '.view-button').click
					sleep 3
					driver.find_elements(:css, '.campaigns .data-table-header a').first.click
					sleep 3
					# FILL OUT FORM
					campaign_name = driver.find_element(:id, "campaign_name")
				#	campaign_name.send_keys("CUS_AW_ONE_6457_#{db_row[6]}_Off#{db_row[7]}")
					campaign_name.send_keys("#{db_row[10]}_Off#{db_row[4]}")

					sleep 3

					driver.find_element(:class, 'button').click

					sleep 2

					driver.find_element(:css, '.campaign_content_editable').click

					sleep 1 

					driver.find_elements(:css, '.html-tab-selector a').first.click

					sleep 2
					
					subject_content = driver.find_element(:name, "campaign_content[content_attributes][subject]")
					subject_content.send_keys("#{db_row[5]}")

					sleep 2

					html_content = driver.find_element(:name, "campaign_content[content_attributes][html]")
					driver.execute_script("$('[name=\"campaign_content[content_attributes][html]\"]').val('#{escape_javascript(db_row[3])}');")
					#html_content.send_keys("#{db_row[2]}")

					sleep 1

					driver.find_element(:css, '.form-actions-container button').click 

					sleep 3

				#	driver.find_element(:css, '.campaign_segment_editable').click

				#	driver.find_elements(:css, '#criteria-controls').click

					break
				end
			end
			begin
				next_link = driver.find_element(:css, 'a[rel="next"]')
				next_link.click
				sleep 3
			rescue
				break
			end
		end
	end
end
###### SMB CODE BELOW |  GREEN ARROW ABOVE

def login_smb(driver, wait)
	driver.get 'SITE LOCATION HERE'

	email_user = driver.find_element(:id, "Login1_UserName")
	email_user.send_keys("USERNAME2 HERE")

	password_user = driver.find_element(:id, "Login1_Password")
	password_user.send_keys("PASSWORD2 HERE")

	sleep 1

	driver.find_element(:id, "Login1_LoginButton").click

	sleep 2 


	select_list = wait.until {
	    element = driver.find_element(:id, "ddlAgencies")
	    element if element.displayed?
	}


sleep 1

	options = select_list.find_elements(:tag_name =>"option")

	options.each do |g|
		if g.text == "CLIENT HERE"
			g.click
			break
		end
	end
	sleep 1
	driver.find_element(:id, "btnSelectAgency").click
	sleep 1
end

def go_to_smb_launch_control(driver)
		sleep 1 
	driver.find_element(:link, 'Admin').click
		sleep 2
	driver.find_element(:link, 'Launch Control').click
	sleep 2 
	driver.find_element(:id, 'Skinnedctl00_main_ddlMailDate').click
#### Extract all options from the select box
	lis = driver.find_elements(:css => ".rfdSelectBox ul li")
		lis.each do |g|
		  if g.text == "Tuesday"
			  g.click
			  break
		  end
		end

#sleep 1

 #driver.find_element(:link, 'Prev Wk').click

 sleep 2

#driver.find_element(:id, "ctl00_main_grdCustList_ctl00_ctl03_ctl01_PageSizeComboBox_Arrow").click 
 #driver.find_elements(:css => ".rcbList li").each do |g|
 #if g.text == "50"
 #g.click
 #break
 #end
#end
driver.find_element(:link, "Cust. Number").click

sleep 2

#driver.find_element(:link, "Cust. Number").click

#driver.find_element(:link, "Job Status").click
#driver.find_element(:link, "Job Status").click
#driver.find_element(:class, 'rgPageNext').click
#sleep 2
#driver.find_element(:class, 'rgPageNext').click
#driver.find_element(:class, 'rgPageNext').click
end

def find_row_for_job(driver, job_id)
	driver.find_elements(:css, '#ctl00_main_grdCustList_ctl00 tbody tr').each do |row|
		columns =  row.find_elements(:css, 'td')
		if columns.size >= 12
			if columns[1].text == job_id
				return row
			end
		end
	end
	nil
end

def fetch_info_for_jobs(driver, valid_job_ids, run_id)
	valid_job_ids.each do |job_id|
		go_to_smb_launch_control(driver)
		sleep 1
		row = find_row_for_job(driver, job_id)
		row.click
		driver.find_element(:link, 'Edit Selected').click
		sleep 1 
		quantity = driver.find_element(:id, 'ctl00_main_txtQuantity')['value']
		sleep 1
		driver.find_element(:link, 'Creative').click
		#Gets HTML Element
		creative_content = driver.find_element(:id, 'ctl00_main_txtCreativeHTMLContentHiddenTextarea')['value']
		creative_value = URI.decode(creative_content)
		sleep 1
		#Gets Subject Line 
		subject_line = driver.find_element(:id, 'ctl00_main_txtSubjectLine')['value']
		sleep 1
		#Gets Offer # 
		offer_number = driver.find_element(:id, 'ctl00_main_lblCustomerOrdinal').text 
		sleep 2
		smb_unq_value = driver.find_element(:id, 'ctl00_main_lblJobID').text 
		split_smb_value = "#{smb_unq_value}".split("_")
		new_mail_file_name = "#{split_smb_value[0]}_#{split_smb_value[1]}_#{split_smb_value[2]}"
		sleep 2
		driver.find_element(:link, 'Dealer Detail').click
		sleep 3
		from_email = driver.find_element(:id, 'ctl00_main_txtDefaultFrom')['value']
		sleep 1
		from_name = driver.find_element(:id, 'ctl00_main_txtFromName')['value']
		sleep 1 
		dealer_name_smb = driver.find_element(:id, 'ctl00_main_txtCustomerName')['value']
		sleep 1
		dealer_id_smb = driver.find_element(:id, 'ctl00_main_txtCustomerNumber')['value']

		# DATABASE ENTRY HERE
		db = SQLite3::Database.new "transfer_mail_files.db"
		db.execute "insert into creative_content (dealer_id, dealer_name, creative_content, subject_line, run_id, offer_number, quantity, from_email, from_name, new_mail_file_name) values ( ?, ? , ?, ?, ?, ?, ?, ?, ?, ?)", 
					[dealer_id_smb, dealer_name_smb, creative_value, subject_line, run_id, offer_number, quantity, from_email, from_name, new_mail_file_name]
	end
end

def find_rows(driver, desired_day, desired_status, completed_status)
	valid_job_ids = []
	driver.find_elements(:css, '#ctl00_main_grdCustList_ctl00 tbody tr').each do |row|
		columns =  row.find_elements(:css, 'td')
		if columns.size >= 7
			day = columns[5].text
			status = columns[8].text
			 completed = columns[7].text
			if day == desired_day && status == desired_status && completed == completed_status
				valid_job_ids << columns[1].text
			end
		end
	end
	valid_job_ids
end

def append_acronym(driver, acronym_info, run_id)
	# Find a few rows
	db = SQLite3::Database.new "transfer_mail_files.db"
	db.execute( "select * from creative_content where run_id=#{run_id}" ) do |db_row|
			acronym_info.each do |info|
				if info[:dealer_name] == db_row[0].strip && info[:dealer_id].to_s ==db_row[1].to_s.strip
					db.execute("UPDATE creative_content SET dealer_acronym='#{info[:dealer_acronym].strip}' WHERE id=#{db_row[3]}")
				end
			end
	end
end

def fetch_acronyms(driver)
	acronym_info = []
	driver.find_element(:link, 'Admin').click
		sleep 1
		driver.find_element(:link, 'Maintain Old Dealer Codes').click
		sleep 1
		driver.find_element(:id, 'ctl00_main_chkUnmatchedOnly').click 
		sleep 1
		driver.find_elements(:css, '#ctl00_main_grdOldCodes_ctl00 tbody tr').each do |row|
			row_html = Nokogiri::HTML(row['innerHTML'])
			column_text_1 = row_html.css('td')[0].text
			column_text_2 = row_html.css('td')[1].text
			column_text_3 = row_html.css('td')[2].text
			dealer_code = column_text_1
			dealer_name = column_text_2
			dealer_id = column_text_3

			acronym_info <<  { dealer_acronym: dealer_code, dealer_name:dealer_name, dealer_id:dealer_id }
		end
	acronym_info	
end

def extract_links(run_id)
	db = SQLite3::Database.new "transfer_mail_files.db"
		db.execute( "select * from creative_content where run_id=#{run_id}" ) do |db_row|
		links = []
			creative = "#{db_row[2]}"
			html = URI.unescape(creative)
			page = Nokogiri::HTML(html)
			page.search('a').each do |link|
			single_links = link['href']
		links << single_links
db.execute("UPDATE creative_content SET links='#{links}' WHERE id=#{db_row[3]}")
		end 
	end 
end

def output(run_id)
db = SQLite3::Database.new "transfer_mail_files.db"
	content = ''
	db.execute( "select * from creative_content WHERE run_id=#{run_id} " ) do |db_row|	
		content << "\nGood Morning Noel/Matt,"
		content << "\n"
		content << "\nDealer Name: #{db_row[0]}"
		content << "\nDealer ID: #{db_row[1]}"
		content << "\nAlternate Mail File Name: #{db_row[12]}_Off#{db_row[7]}"
		content << "\n"
		content << "\nCreative: Attached"
		content << "\nSubject Line: #{db_row[4]}" 
		content << "\n"
		content << "\nFrom Name: #{db_row[11]}"
		content << "\nFrom Email: #{db_row[10]}"
		content << "\n"
		content << "\nQuantity: #{db_row[9]}"
		converstion_amount = "#{db_row[9]}".sub(',', '').to_i 
		opens_amount_nr = converstion_amount * 0.1 + rand(25)
		opens_amount_round = opens_amount_nr.ceil 
		clicks_amount_nr = opens_amount_nr * 0.05 + rand(10)
		clicks_amount_round = clicks_amount_nr.ceil
		content << "\n"
		all_links = "#{db_row[8]}".split(",")
		content << "\n"
		content << all_links.join("\n").sub('[', '').sub(']', '')
		content << "\n"
		content << "\n============================================================="
	end
	File.open("filename_#{run_id}", 'w') { |file| file.write(content) }
end 


def list_for_today
	db = SQLite3::Database.new "transfer_mail_files.db"
		content = ''
			db.execute( "select * from creative_content" ) do |db_row|	
				content << "\nDealer Name: #{db_row[0]}"
				content << "\nDealer ID: #{db_row[1]}"
				content << "\nCampaign Name: CUS_AW_ONE_#{db_row[6]}_Off#{db_row[7]}"
		end
	File.open("list_for_today", 'w') { |file| file.write(content) }
end 



def creatives_for_today(run_id)
	db = SQLite3::Database.new "transfer_mail_files.db"
		content = ''
			db.execute( "select * from creative_content where run_id=#{run_id}" ) do |db_row|	
			content << "\n#{db_row[2]}"
		File.open("#{db_row[1]}_Off#{db_row[7]}.html", 'w') { |file| file.write(content) }
	end
end 

def new_mail_file_names_list
	db = SQLite3::Database.new "transfer_mail_files.db"
			content = ''
		db.execute( "select * from creative_content" ) do |db_row|	
			split_db_value = "#{db_row[12]}".split("_")
			full_new_file_name = "#{split_db_value[0]}_#{split_db_value[1]}_#{split_db_value[2]}"
			puts "Old Mail Name: CUS_AW_ONE_6457_#{db_row[6]}"
			puts "New Mail Name: #{full_new_file_name}"
			puts "========"
		content << "\n#{db_row[1]}, #{full_new_file_name}, #{db_row[6]}"
				File.open("new_mail_file_names_2.csv", 'w') { |file| file.write(content) }
	end

end 


def quanity_of_records_to_add(run_id)
	db = SQLite3::Database.new "transfer_mail_files.db"
			#content = ''
			list = ''
		db.execute( "select * from new_table ORDER BY quantity DESC" ) do |db_row|	
			mail_file_size = "#{db_row[9]}"
			split_db_value = "#{db_row[12]}".split("_")
			full_new_file_name = "#{split_db_value[0]}_#{split_db_value[1]}_#{split_db_value[2]}"
			list_item_1 = "Look for This First - Mail File Name Name: #{full_new_file_name}"
			list_item_2 = "Look for This Second - Mail File Name Name: CUS_AW_ONE_6457_#{db_row[6]}"
			list_item_3 = "Quantity to Add: #{mail_file_size}"
			#puts "========"
			#content << "\n#{db_row[1]}, #{quantity_to_add}, #{db_row[6]}"
			list << "\n#{list_item_1}"
			list << "\n#{list_item_2}"
			list << "\n#{list_item_3}"
			list << "\n==============="
		#	File.open("List_for_Justin_Files_to_Add.csv", 'w') { |file| file.write(content) }
	end
		File.open("List_for_Justin_Files_to_Add", 'w') { |file| file.write(list) }
end 


#### ACTUALLY WHERE THE SCRIPT STARTS
driver = Selenium::WebDriver.for :firefox
wait = Selenium::WebDriver::Wait.new(:timeout => 20)


###STEP 1 - Collect Data #######
run_id = Time.now.to_i
#puts "#{run_id}"
#run_id = 1531492090
login_smb(driver, wait)
go_to_smb_launch_control(driver)
valid_job_ids = find_rows(driver, 'Tue', 'APPROVED', 'Deploying')
fetch_info_for_jobs(driver, valid_job_ids, run_id)
#acronym_info = fetch_acronyms(driver)
#append_acronym(driver, acronym_info, run_id)

##STEP 2 - QC DATA and Tool Setup#####
#run_id = 1538068710
extract_links(run_id)
output(run_id) 

##STEP 3 - OUTPUT DATA - ####
#login_green_arrow(driver, wait) 
#print_mail_file_names(driver, run_id) 

#creatives_for_today(run_id)
#new_mail_file_names_list
#quanity_of_records_to_add(run_id)



