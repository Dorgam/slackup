require 'slack-ruby-client'
require 'json'
require 'fileutils'
require 'date'
require 'dropbox_sdk'

def backup_channels(username)
  client = Slack::Web::Client.new
  channels = client.channels_list.channels
  channels.each do |channel|
    history = client.channels_history :channel => "#"+channel.name
    messages_formated = []
    messages = history.messages
    messages.each do |msg|
      #msg_formated = {:user => msg.user, :text => msg.text, :ts => msg.ts}
      messages_formated.push(msg)
    end
    messages_json = messages_formated.to_json
    if File.exist?("jsons/" + username + "/channels/" + channel.name + ".json")
      text = File.open("jsons/" + username + "/channels/" + channel.name + ".json", "r:UTF-8").read
      json_obj = JSON.parse(text)
      json_array = json_obj.to_a
      msgs_array = JSON.parse(messages_json).to_a
      array_union = msgs_array | json_array
      File.open("jsons/" + username + "/channels/" + channel.name + ".json", "w:UTF-8") {|f| f.write(array_union.to_json) }else
      FileUtils.mkpath "jsons/" + username + "/channels/"
      File.open("jsons/" + username + "/channels/" + channel.name + ".json", "w:UTF-8") {|f| f.write(messages_json) }
    end
  end
end

def backup_groups(username)
  client = Slack::Web::Client.new
  groups = client.groups_list.groups
  groups.each do |group|
    history = client.groups_history :channel => group.id
    messages_formated = []
    messages = history.messages
    messages.each do |msg|
      #msg_formated = {:user => msg.user, :text => msg.text, :ts => msg.ts}
      messages_formated.push(msg)
    end
    messages_json = messages_formated.to_json
    if File.exist?("jsons/" + username + "/groups/" + group.name + ".json")
      text = File.open("jsons/" + username + "/groups/" + group.name + ".json", "r:UTF-8").read
      json_obj = JSON.parse(text)
      json_array = json_obj.to_a
      msgs_array = JSON.parse(messages_json).to_a
      array_union = msgs_array | json_array
      File.open("jsons/" + username + "/groups/" + group.name + ".json", "w:UTF-8") {|f| f.write(array_union.to_json) }
    else
      FileUtils.mkpath "jsons/" + username + "/groups/"
      File.open("jsons/" + username + "/groups/" + group.name + ".json", "w:UTF-8") {|f| f.write(messages_json) }
    end
  end
end

def backup_ims(username)
  client = Slack::Web::Client.new
  ims = client.im_list.ims
  ims.each do |im|
    history = client.im_history :channel => im.id
    messages_formated = []
    messages = history.messages
    messages.each do |msg|
      #msg_formated = {:user => msg.user, :text => msg.text, :ts => msg.ts}
      messages_formated.push(msg)
    end
    messages_json = messages_formated.to_json
    if File.exist?("jsons/" + username + "/ims/" + im.user + ".json")
      text = File.open("jsons/" + username + "/ims/" + im.user + ".json", "r:UTF-8").read
      json_obj = JSON.parse(text)
      json_array = json_obj.to_a
      msgs_array = JSON.parse(messages_json).to_a
      array_union = msgs_array | json_array
      File.open("jsons/" + username + "/ims/" + im.user + ".json", "w:UTF-8") {|f| f.write(array_union.to_json) }
    else
      FileUtils.mkpath "jsons/" + username + "/ims/"
      File.open("jsons/" + username + "/ims/" + im.user + ".json", "w:UTF-8") {|f| f.write(messages_json) }
    end
  end
end

def create_htmls(username, ulist)
  index_first = File.open("temps/index/first.txt", "r:UTF-8").read
  index_middle = ""
  index_last = File.open("temps/index/last.txt", "r:UTF-8").read
  index_middle += "<h2>Channels</h2><ul>"
  #Loop through user channels
  Dir.glob("jsons/" + username + "/channels/*.json") do |file|
    index_middle += "<li><a href = 'channels/" + file.split("/")[3].split(".")[0] + ".html'>" + file.split("/")[3].split(".")[0] + "</a></li>"
    text = File.open(file, "r:UTF-8").read
    first_html = File.open("temps/first.txt", "r:UTF-8").read
    middle_html = ""
    last_html = File.open("temps/last.txt", "r:UTF-8").read
    json_obj = JSON.parse(text)
    json_obj.reverse.each do |message|
      user = ulist.find { |h| h['id'] == message["user"] }['name']
      message_text = ""
      if message["file"] != nil
        message_text = message["file"]["permalink"]
        message_text = "[Shared File]: " + '<a href="' + message_text + '">' + message["file"]["name"] + '</a>'
      elsif message["attachments"] != nil
        message["attachments"].each do |attachment|
          if attachment["title_link"] != nil
            display_text = attachment["title_link"]
            message_text += "[Shared attachment]: " + '<a href="' + attachment["title_link"] + '">' + attachment["title"] + '</a>'
          elsif attachment["title"] != nil
            message_text += "[Shared attachment]: " + attachment["title"]
          elsif attachment["from_url"] != nil
            message_text += "[Shared attachment]: " + '<a href="' + attachment["from_url"] + '">' + attachment["from_url"] + '</a>'
          end
        end
      else
        message_text = message["text"].gsub('<', '').gsub('>', '')
      end
      middle_html = middle_html + "<li>" + user + "@" + Time.at(message["ts"].to_i).to_datetime.to_s + ": " + message_text + "</li>"
    end
    final_html = first_html + middle_html + last_html
    FileUtils.mkpath "htmls/" + username + "/channels/"
    File.open("htmls/" + username + "/channels/" + file.split("/")[3].split(".")[0] + ".html", "w:UTF-8") {|f| f.write(final_html) }
  end
  index_middle += "</ul><h2>Groups</h2><ul>"
  #Loop through groups
  Dir.glob("jsons/" + username + "/groups/*.json") do |file|
    index_middle += "<li><a href = 'groups/" + file.split("/")[3].split(".")[0] + ".html'>" + file.split("/")[3].split(".")[0] + "</a></li>"
    text = File.open(file, "r:UTF-8").read
    first_html = File.open("temps/first.txt", "r:UTF-8").read
    middle_html = ""
    last_html = File.open("temps/last.txt", "r:UTF-8").read
    json_obj = JSON.parse(text)
    json_obj.reverse.each do |message|
      user = ulist.find { |h| h['id'] == message["user"] }['name']
      message_text = ""
      if message["file"] != nil
        message_text = message["file"]["permalink"]
        message_text = "[Shared File]: " + '<a href="' + message_text + '">' + message["file"]["name"] + '</a>'
      elsif message["attachments"] != nil
        message["attachments"].each do |attachment|
          if attachment["title_link"] != nil
            display_text = attachment["title_link"]
            message_text += "[Shared attachment]: " + '<a href="' + attachment["title_link"] + '">' + attachment["title"] + '</a>'
          elsif attachment["title"] != nil
            message_text += "[Shared attachment]: " + attachment["title"]
          elsif attachment["from_url"] != nil
            message_text += "[Shared attachment]: " + '<a href="' + attachment["from_url"] + '">' + attachment["from_url"] + '</a>'
          end
        end
      else
        message_text = message["text"].gsub('<', '').gsub('>', '')
      end
      middle_html = middle_html + "<li>" + user + "@" + Time.at(message["ts"].to_i).to_datetime.to_s + ": " + message_text + "</li>"
    end
    final_html = first_html + middle_html + last_html
    FileUtils.mkpath "htmls/" + username + "/groups/"
    File.open("htmls/" + username + "/groups/" + file.split("/")[3].split(".")[0] + ".html", "w:UTF-8") {|f| f.write(final_html) }
  end
  index_middle += "</ul><h2>DMs</h2><ul>"
  #Loop through ims
  Dir.glob("jsons/" + username + "/ims/*.json") do |file|
    user = ulist.find { |h| h['id'] == file.split("/")[3].split(".")[0] }['name']
    index_middle += "<li><a href = 'ims/" + file.split("/")[3].split(".")[0] + ".html'>" + user + "</a></li>"
    text = File.open(file, "r:UTF-8").read
    first_html = File.open("temps/first.txt", "r:UTF-8").read
    middle_html = ""
    last_html = File.open("temps/last.txt", "r:UTF-8").read
    json_obj = JSON.parse(text)
    json_obj.reverse.each do |message|
      user = ulist.find { |h| h['id'] == message["user"] }['name']
      message_text = ""
      if message["file"] != nil
        message_text = message["file"]["permalink"]
        message_text = "[Shared File]: " + '<a href="' + message_text + '">' + message["file"]["name"] + '</a>'
      elsif message["attachments"] != nil
        message["attachments"].each do |attachment|
          if attachment["title_link"] != nil
            display_text = attachment["title_link"]
            message_text += "[Shared attachment]: " + '<a href="' + attachment["title_link"] + '">' + attachment["title"] + '</a>'
          elsif attachment["title"] != nil
            message_text += "[Shared attachment]: " + attachment["title"]
          elsif attachment["from_url"] != nil
            message_text += "[Shared attachment]: " + '<a href="' + attachment["from_url"] + '">' + attachment["from_url"] + '</a>'
          end
        end
      else
        message_text = message["text"].gsub('<', '').gsub('>', '')
      end
      middle_html = middle_html + "<li>" + user + "@" + Time.at(message["ts"].to_i).to_datetime.to_s + ": " + message_text + "</li>"
    end
    final_html = first_html + middle_html + last_html
    FileUtils.mkpath "htmls/" + username + "/ims/"
    File.open("htmls/" + username + "/ims/" + file.split("/")[3].split(".")[0] + ".html", "w:UTF-8") {|f| f.write(final_html) }
  end
  index_middle += "</ul>"
  index_final = index_first + index_middle + index_last
  File.open("htmls/" + username + "/index.html", "w:UTF-8") {|f| f.write(index_final) }
end

def sync(dropbox_tk, username)
  client = DropboxClient.new(dropbox_tk)
  #Index Page
  begin
    client.file_delete('/index.html')
  rescue
  end
  uploading_file = open("htmls/" + username + "/index.html")
  client.put_file('/index.html', uploading_file)
  #HTMLS
  Dir.glob("htmls/" + username + "/channels/*.html") do |file|
    uploading_file = open(file)
    begin
      client.file_delete('/channels/' + file.split("/")[3])
    rescue
    end
    response = client.put_file('/channels/' + file.split("/")[3], uploading_file)
    puts "uploaded:", response.inspect
  end
  Dir.glob("htmls/" + username + "/groups/*.html") do |file|
    uploading_file = open(file)
    begin
      client.file_delete('/groups/' + file.split("/")[3])
    rescue
    end
    response = client.put_file('/groups/' + file.split("/")[3], uploading_file)
    puts "uploaded:", response.inspect
  end
  Dir.glob("htmls/" + username + "/ims/*.html") do |file|
    uploading_file = open(file)
    begin
      client.file_delete('/ims/' + file.split("/")[3])
    rescue
    end
    response = client.put_file('/ims/' + file.split("/")[3], uploading_file)
    puts "uploaded:", response.inspect
  end
  #JSONS
  Dir.glob("jsons/" + username + "/channels/*.json") do |file|
    uploading_file = open(file)
    begin
      client.file_delete('jsons/channels/' + file.split("/")[3])
    rescue
    end
    response = client.put_file('jsons/channels/' + file.split("/")[3], uploading_file)
    puts "uploaded:", response.inspect
  end
  Dir.glob("jsons/" + username + "/groups/*.json") do |file|
    uploading_file = open(file)
    begin
      client.file_delete('jsons/groups/' + file.split("/")[3])
    rescue
    end
    response = client.put_file('jsons/groups/' + file.split("/")[3], uploading_file)
    puts "uploaded:", response.inspect
  end
  Dir.glob("jsons/" + username + "/ims/*.json") do |file|
    uploading_file = open(file)
    begin
      client.file_delete('jsons/ims/' + file.split("/")[3])
    rescue
    end
    response = client.put_file('jsons/ims/' + file.split("/")[3], uploading_file)
    puts "uploaded:", response.inspect
  end
end

def clean_folders username
  FileUtils.remove_dir("jsons")
  FileUtils.remove_dir("htmls")
end

def get_users username
  client = Slack::Web::Client.new
  client.users_list.members
end

def long_share_url(access_token, path)
    client = DropboxClient.new(access_token)
    session = DropboxOAuth2Session.new(access_token, nil)
    response = session.do_get "/shares/auto/#{client.format_path(path)}", {"short_url"=>false}
    Dropbox::parse_response(response)
end

def download_jsons dropbox_tk, username
  client = DropboxClient.new(dropbox_tk)
  begin
    #Download Channels
    channels_meta = client.metadata("jsons/channels")["contents"]
    #puts channels_meta
    channels_meta.each do |channel|
      url = channel["path"]
      download_url = "jsons/channels/" + url.split("/")[3]
      save_url = "jsons/" + username + "/channels/" + url.split("/")[3]
      downloaded_file = client.get_file(download_url)
      FileUtils.mkpath "jsons/" + username + "/channels/"
      File.open(save_url, "w") {|f| f.write(downloaded_file)}
    end
    #Download Groups
    groups_meta = client.metadata("jsons/groups")["contents"]
    groups_meta.each do |group|
      url = group["path"]
      download_url = "jsons/groups/" + url.split("/")[3]
      save_url = "jsons/" + username + "/groups/" + url.split("/")[3]
      downloaded_file = client.get_file(download_url)
      FileUtils.mkpath "jsons/" + username + "/groups/"
      File.open(save_url, "w") {|f| f.write(downloaded_file)}
    end
    #Download ims
    ims_meta = client.metadata("jsons/ims")["contents"]
    ims_meta.each do |im|
      url = im["path"]
      download_url = "jsons/ims/" + url.split("/")[3]
      save_url = "jsons/" + username + "/ims/" + url.split("/")[3]
      downloaded_file = client.get_file(download_url)
      FileUtils.mkpath "jsons/" + username + "/ims/"
      File.open(save_url, "w") {|f| f.write(downloaded_file)}
    end
  #rescue
    #puts "No jsons folder, This is first time backup"
  end
end

#---------------------------------------------------
#Script Runs from here
#---------------------------------------------------

#Collect argumnets from Heroku Scheduler call.
token = ARGV[0]
username = ARGV[1]
dropbox_tk = ARGV[2]

Slack.config.token = token #Assign the Slack token
ulist = get_users username #Get list of users info
download_jsons dropbox_tk, username #Download old backup data

#Get new data from slack
backup_channels username
backup_groups username
backup_ims username

create_htmls username, ulist #Generate HTML files from JSONs
sync dropbox_tk, username #Sync with dropbox
clean_folders username #clean server files