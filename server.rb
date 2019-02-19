require 'sinatra'
require 'json'
require 'pry'
require 'httparty'

LABEL_NAME = "bug"
LABEL_APPEND = "duplicate"
GITHUB_ACCESS_TOKEN=""

post '/payload' do
  @data = JSON.parse(request.body.read)
  if has_new_fields_added? && !appended_label?
    append_label
    post_result_to_pr
  end
end


def has_new_fields_added?
  true
end

def append_label
  if pr_labels.include?(LABEL_NAME)
    response = HTTParty.post("#{@data.dig('pull_request', 'issue_url')}/labels",
    headers: {
      "Authorization": "token #{GITHUB_ACCESS_TOKEN}",
      "Content-Type": "application/json",
      "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
    },
    body: {
      "labels": pr_labels.push(LABEL_APPEND).uniq,
    }.to_json
  )
  end
end

def pr_labels
  labels_data = @data["pull_request"]["labels"]
  labels_data.map { |dt| dt["name"] }
end

def appended_label?
  pr_labels.include?(LABEL_APPEND)
end

def post_result_to_pr
  mess = "Founded new field(s) in your pullrequest."
  response = HTTParty.post("#{@data.dig('pull_request', 'comments_url')}",
    headers: {
      "Authorization": "token #{GITHUB_ACCESS_TOKEN}",
      "Content-Type": "application/json",
      "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
    },
    body: {
      "body": "[BOT] \n #{mess}",
    }.to_json
  )
  puts response
end
