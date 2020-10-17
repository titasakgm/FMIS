#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/cors'
require 'pg'
require 'json'

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST"
set :allow_headers, "Content-type,if-modified-since"
set :expose_headers, "location,link"

set :bind, "0.0.0.0"

get '/check_law' do
  lon = params[:lon]
  lat = params[:lat]
  con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
  sql = "SELECT gid,law_year,law_name,law_folder "
  sql += "FROM no08_law "
  sql += "WHERE ST_Contains(geom, ST_Transform(ST_GeometryFromText("
  sql += "'POINT(#{lon} #{lat})',4326),32647))" 
  res = con.exec(sql)
  con.close
  dat = []
  res.each do |rec|
    gid = rec['gid']
    yr = rec['law_year']
    name = rec['law_name']
    path = "http://fmis.forest.ku.ac.th" + rec['law_folder']
    d = {
      :gid => gid,
      :law_year => yr,
      :law_name => name,
      :law_folder => path,
      :longitude => lon,
      :latitude => lat
    }
    dat.push(d)
  end
  dat.to_json
end
