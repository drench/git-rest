#!/usr/bin/env ruby

require 'sinatra'

TAG_PATTERN = %r{^/([\w\-/]+)}

# curl -X DELETE http://localhost:4567/some/path
delete TAG_PATTERN do |c|
  system "git rest delete #{c}"
  [ 204, {}, %q{} ]
end

# curl http://localhost:4567/some/path
get TAG_PATTERN do |c|
  head = {}
  head[:ETag] = `git rev-parse '#{c}'`.chomp
  if $? == 0
    inm = request.env['HTTP_IF_NONE_MATCH']
    if inm && inm == head[:ETag]
      rc = 304
    else
      rc = 200
      body = `git rest get #{c}`
      head['Content-Type'] = 'application/octet-stream'
    end
  else
    rc = 404
    body = %q{}
    head.delete(:ETag)
  end

  [ rc, head, body ]
end

# curl -I http://localhost:4567/some/path
head TAG_PATTERN do |c|
  head = {}
  head[:ETag] = `git rev-parse '#{c}'`.chomp
  if $? == 0
    inm = request.env['HTTP_IF_NONE_MATCH']
    if inm && inm == head[:ETag]
      rc = 304
    else
      rc = 200
      head['Content-Type'] = 'application/octet-stream'
    end
  else
    rc = 404
    head.delete(:ETag)
  end

  [ rc, head, %q{} ]
end

# curl -d "Some String" http://localhost:4567/
post '/' do
  head = {}
  grp = IO.popen(%q(git rest post), 'w+')
  request.body.each do |chunk|
    grp.puts(chunk)
  end
  grp.close_write
  sha1 = grp.gets.chomp
  grp.close_read
  head[:Location] = request.url + sha1

  [ 302, head, sha1 ]
end

# curl -d "Some String" http://localhost:4567/some/path
put TAG_PATTERN do |c|
  request.body.rewind
  grp = IO.popen(%Q(git rest put '#{c}'), 'w+')
  request.body.each do |chunk|
    grp.puts(chunk)
  end
  grp.close
  %q{OK}
end
