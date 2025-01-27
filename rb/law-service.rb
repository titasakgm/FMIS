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

helpers do
  def in_province(lon,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid "
    sql += "FROM province "
    sql += "WHERE ST_Contains(geom, ST_Transform(ST_GeometryFromText("
    sql += "'POINT(#{lon} #{lat})',4326),32647))" 
    res = con.exec(sql)
    con.close
    return (res.num_tuples == 0) ? 0 : res[0]['gid'].to_i
  end

  def in_no08(lon,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid "
    sql += "FROM no08_law "
    sql += "WHERE ST_Contains(geom, ST_Transform(ST_GeometryFromText("
    sql += "'POINT(#{lon} #{lat})',4326),32647))" 
    res = con.exec(sql)
    con.close
    return (res.num_tuples == 0) ? 0 : res[0]['gid'].to_i
  end

  def in_no10(lon,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid "
    sql += "FROM no10_law "
    sql += "WHERE ST_Contains(geom, ST_Transform(ST_GeometryFromText("
    sql += "'POINT(#{lon} #{lat})',4326),32647))" 
    res = con.exec(sql)
    con.close
    return (res.num_tuples == 0) ? 0 : res[0]['gid'].to_i
  end

  def in_no12(lon,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid "
    sql += "FROM no12_law "
    sql += "WHERE ST_Contains(geom, ST_Transform(ST_GeometryFromText("
    sql += "'POINT(#{lon} #{lat})',4326),32647))" 
    res = con.exec(sql)
    con.close
    return (res.num_tuples == 0) ? 0 : res[0]['gid'].to_i
  end

  def get_info08(gid,lng,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid,law_year,law_name,law_folder "
    sql += "FROM no08_law "
    sql += "WHERE gid=#{gid} "
    res = con.exec(sql)
    con.close
    info = nil
    res.each do |rec|
      gid = rec['gid']
      yr = rec['law_year']
      name = rec['law_name']
      path = "http://fmis.forest.ku.ac.th" + rec['law_folder']
      info = {
        :gid => gid,
        :law_year => yr,
        :law_name => name,
        :law_folder => path,
        :longitude => lng,
        :latitude => lat
      }
    end
    info
  end

  def get_info10(gid,lng,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid,law_year,law_name,law_folder "
    sql += "FROM no10_law "
    sql += "WHERE gid=#{gid} "
    res = con.exec(sql)
    con.close
    info = nil
    res.each do |rec|
      gid = rec['gid']
      yr = rec['law_year']
      name = rec['law_name']
      path = "http://fmis.forest.ku.ac.th" + rec['law_folder']
      info = {
        :gid => gid,
        :law_year => yr,
        :law_name => name,
        :law_folder => path,
        :longitude => lng,
        :latitude => lat
      }
    end
    info
  end

  def get_info12(gid,lng,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid,law_year,law_name,law_folder "
    sql += "FROM no12_law "
    sql += "WHERE gid=#{gid} "
    res = con.exec(sql)
    con.close
    info = nil
    res.each do |rec|
      gid = rec['gid']
      yr = rec['law_year']
      name = rec['law_name']
      path = "http://fmis.forest.ku.ac.th" + rec['law_folder']
      info = {
        :gid => gid,
        :law_year => yr,
        :law_name => name,
        :law_folder => path,
        :longitude => lng,
        :latitude => lat
      }
    end
    info
  end

  def get_infocc(gid,lng,lat)
    con = PG::Connection.connect("localhost",25434,nil,nil,"gis","docker","docker")
    sql = "SELECT gid,prov_nam_t AS pname,p_code AS pcode "
    sql += "FROM province "
    sql += "WHERE gid=#{gid} "
    res = con.exec(sql)
    con.close
    info = nil
    res.each do |rec|
      gid = rec['gid']
      pname = rec['pname']
      pcode = rec['pcode']
      geojson = rec['geojson']
      info = {
        :gid => gid,
        :pcode => pcode,
        :pname => pname,
        :longitude => lng,
        :latitude => lat,
        :geojson => geojson
      }
    end
    info
  end
end

get '/check_law/:lon/:lat' do |lng,lat|
  dat = []

  gidcc = in_province(lng,lat)
  if gidcc > 0 # point WITHIN province
    d = get_infocc(gidcc,lng,lat) # json of gid,pcode,pname
    d['layer'] = 'province'
    dat.push(d)
  end

  gid08 = in_no08(lng,lat)
  if gid08 > 0 # point WITHIN no08_law
    d = get_info08(gid08,lng,lat) # json of gid,law_year,law_name,law_folder
    d['layer'] = 'no08_law'
    dat.push(d)
  end

  gid10 = in_no10(lng,lat)
  if gid10 > 0 # point WITHIN no08_law
    d = get_info10(gid10,lng,lat) # json of gid,law_year,law_name,law_folder
    d['layer'] = 'no10_law'
    dat.push(d)
  end

  gid12 = in_no12(lng,lat)
  if gid12 > 0 # point WITHIN no12_law
    d = get_info12(gid12,lng,lat) # json of gid,law_year,law_name,law_folder
    d['layer'] = 'no12_law'
    dat.push(d)
  end
  dat.to_json

end
