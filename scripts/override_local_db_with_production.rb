require 'net/scp'
require 'date'
require 'colorize'
require 'fileutils'

module Exceptions
  class OverrideFailed < StandardError; end
end

DUMP_FOLDER = "{SET_REMOTE_DUMP_DIR_HERE}"
TMP_FOLDER = "dcida_tb_tmp"

def print_command(com, local=false)
	if local
		puts "[LOCAL] Execute: #{com}".yellow
	else
  	puts "Execute: #{com}".yellow
  end
end

def success_command(com, local=false)
	if local
  	puts "[LOCAL] Success: #{com}".green
  else
  	puts "Success: #{com}".green
  end
end

def clean
	FileUtils::rm_rf(__dir__ + "/" + TMP_FOLDER)
end

puts "-------------------------------------------------------"
puts "Starting DCIDA local db override"
puts "-------------------------------------------------------"
puts "\n"

begin

	ssh = Net::SSH.start(ENV['PROD_HOST'], ENV['PROD_USER'])

	# first, check to see that the db_dumps folder exists
	folder_exists_com = "[ -d #{DUMP_FOLDER} ] && echo 1 || echo 0"
	print_command(folder_exists_com)
	f_exists = ssh.exec!(folder_exists_com).to_i
	if f_exists != 1
	raise Exceptions::OverrideFailed.new("db_dumps folder doesn't exist")
	end
	success_command(folder_exists_com)
	puts "\n"

	# create a timestamp which we will use as the file name for the dump
	curr_date_time = Time.now.strftime("%Y%m%d%H%M%S")

	# dump the existing production database into the file
	dump_prod_db_cmd = "pg_dump -F c -v -U dcida_user -h localhost dcida_production -f #{DUMP_FOLDER}/#{curr_date_time}.psql"
	print_command(dump_prod_db_cmd)
	r = ssh.exec!(dump_prod_db_cmd)
	success_command(dump_prod_db_cmd)

	# create a local place to store the file
	FileUtils::mkdir(__dir__ + "/" + TMP_FOLDER)

	# download the file
	# copy the dist folder over to the newest release folder
  print_command("Starting file copy")
  puts "-------------------------------------------------------"
  Net::SCP.download!(ENV['PROD_HOST'], ENV['PROD_USER'], "#{DUMP_FOLDER}/#{curr_date_time}.psql", "#{TMP_FOLDER}/#{curr_date_time}.psql") do |ch, name, sent, total|
    if sent == total
      puts "#{name}: #{sent}/#{total}".green
    else
      puts "#{name}: #{sent}/#{total}".yellow
    end
  end
  success_command("Finished file copy")
  puts "\n"

  # drop my local db
  drop_cmd = "dropdb -p 5433 -U dcida_20_user dcida_20_development"
  print_command(drop_cmd, true)
  r = `#{drop_cmd}`
  success_command(drop_cmd, true)

  # recreate the db
  create_cmd = "createdb -p 5433 -U dcida_20_user dcida_20_development"
  print_command(create_cmd, true)
  r = `#{create_cmd}`
  success_command(create_cmd, true)

  # restore the file to my local db
  restore_cmd = "pg_restore --verbose --clean --no-acl --no-owner -p 5433 -h localhost -U dcida_20_user -d dcida_20_development #{TMP_FOLDER}/#{curr_date_time}.psql"
  print_command(restore_cmd, true)
	#r = ssh.exec!(restore_cmd)
	r = `#{restore_cmd}`
	success_command(restore_cmd, true)

rescue Exceptions::OverrideFailed => e
  puts "Error: #{e}".red
rescue Net::SSH::Exception => e
  puts "Error: SSH Connection error".red
rescue Exception => e
	puts "#{e}"
	puts "Other error!".red
ensure
	clean()
end
# copy the file to some tmp directory
