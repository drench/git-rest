#!/usr/bin/env ruby

require 'sinatra'

# curl -X DELETE http://localhost:4567/some/path
delete %r{^/([\w\-/]+)} do |c|
  system "git rest delete #{c}"
  [ 204, {}, %q{} ]
end

# curl http://localhost:4567/some/path
get %r{^/([\w\-/]+)} do |c|
  head = {}
  head[:ETag] = `git rev-parse '#{c}'`
  if $? == 0
    rc = 200
    body = `git rest get #{c}`
    head['Content-Type'] = 'application/octet-stream'
  else
    rc = 404
    body = %q{}
    head.delete(:ETag)
  end

  [ rc, head, body ]
end

# curl -I http://localhost:4567/some/path
head %r{^/([\w\-/]+)} do |c|
  head = {}
  head[:ETag] = `git rev-parse '#{c}'`
  if $? == 0
    rc = 200
    head['Content-Type'] = 'application/octet-stream'
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
put %r{^/([\w\-/]+)} do |c|
  request.body.rewind
  grp = IO.popen(%Q(git rest put '#{c}'), 'w+')
  request.body.each do |chunk|
    grp.puts(chunk)
  end
  grp.close
  %q{OK}
end
