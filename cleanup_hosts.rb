require 'rubygems'
require 'httparty'
require 'json'

config = JSON.parse(File.read('config.json'), symbolize_names: true)

url = "#{config[:ops_manager_url]}/api/public/v1.0/groups/#{config[:group_id]}/hosts"
response = HTTParty.get(url, digest_auth: config[:auth])
hosts = JSON.parse(response.body)['results']

cutoff_date = Date.today - config['number_of_days_old'].to_i
hosts.each do |host|
  ping_date = Date.parse(host['lastPing'])
  if !host.key?('replicaSetName') and host['replicaStateName'] == 'DOWN' and ping_date <= cutoff_date
    puts "Deleting host #{host['hostname']} (id: #{host['id']}) in group #{config[:group_id]}"
    url = "#{config[:ops_manager_url]}/api/public/v1.0/groups/#{config[:group_id]}/hosts/#{host['id']}"
    response = HTTParty.delete(url, digest_auth: config[:auth])
    puts response.code
  end
end
