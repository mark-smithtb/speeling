require 'net/https'
require 'webrick'

class Dictionary < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(_request, response)
    if File.exist?('word_list.txt')
      word_list = File.readlines('word_list.txt')
      word_list.sort!
    else
      word_list = []
    end
    html = "<ul>" + (word_list.map {|line| "<li>#{line}</li>"}).join + "</ul>"
    response.status = 200
    response.body = %(
    <html>
    <head>
  <meta charset="utf-8">
  <title>TIY Dictionary</title>
  <link rel="stylesheet" href="http://getbootstrap.com/dist/css/bootstrap.min.css" media="screen" title="no title" charset="utf-8">
</head>
    <body>
    <div class="navbar navbar-default">
    <a href="/" class="navbar-brand">Home</a>
    <form method="POST" action="/save" class="navbar-form navbar-right">
    <input name = "word">
    <button type = "submit" class="btn btn-success">Add word</button>
    </form>
    <form method="POST" action="/search" class="navbar-form navbar-right">
    <input name = "search_word">
    <button type="submit" class="btn btn-primary">Search word</button>
    </form>
    </div>
    <div class="col-lg-12"
    #{html}
    </div>
    </body>
    </html>
    )
  end
end

class Saveword < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    File.open('word_list.txt', 'a+') do |file|
      file.puts "#{request.query['word']}"
    end
    response.status = 302
    response.header['location'] = '/'
    response.body = 'Your word was added.'
  end
end

class Search < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    found_word = nil
    File.open('word_list.txt') do |file|
    found_word = file.find_all {|line| line.start_with?(request.query['search_word'])}
        end
    # lines = File.readlines('word_list.txt')
    # matching_lines = lines.select {|line| line.include?(request.query['search_word'])}
    html = "<ul>" + (found_word.map {|line| "<li>#{line}</li>"}).join + "</ul>"
    response.status = 200
    response.body = %(

    <html>
    <head>
  <meta charset="utf-8">
  <title>TIY Dictionary</title>
  <link rel="stylesheet" href="http://getbootstrap.com/dist/css/bootstrap.min.css" media="screen" title="no title" charset="utf-8">
</head>
    <body>
    <div class="navbar navbar-default">
    <a href="/" class="navbar-brand">Home</a>
    <form method="POST" action="/save" class="navbar-form navbar-right">
    <input name = "word">
    <button type = "submit" class="btn btn-success">Add word</button>
    </form>
    <form method="POST" action="/search" class="navbar-form navbar-right">
    <input name = "search_word">
    <button type="submit" class="btn btn-primary">Search word</button>
    </form>
    </div>
    <div class="col-lg-12">
    #{html}
    </div>
    </body>
    </html>
    )
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount '/', Dictionary
server.mount '/save', Saveword
server.mount '/search', Search
trap('INT') do
  server.shutdown
end

server.start
