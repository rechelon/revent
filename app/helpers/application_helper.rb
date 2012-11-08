# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def spotlight_events calendar=nil
    return [] if calendar.nil?
    calendar.events.searchable.sticky
  end
  def countries_for_select
    CountryCodes::countries_for_select('name', 'a3').map{|a| [a[0],a[1].downcase]}.sort.unshift(['All Countries', 'all'])
  end
  def calendar_select
    Site.current.sorted_calendars.reject {|c| c.archived?}.collect{|c| [c.name, c.permalink]}
  end
  def shorten(url,login,api_key,api)
    require 'open-uri'
    reply = open(api + '?login=' + login + '&apiKey=' + api_key + '&longUrl='+  url).read
    bitly = ActiveSupport::JSON.decode(reply)
    bitly['data']['url']
  end  

  def sponsor_string(event)
    html = ''
    if !event.custom_attributes_data.sponsor_union.blank?
      html += "<div id='event-sponsor' class='event-info'><span class='label info-label'>Sponsored by:</span><br> #{event.custom_attributes_data.sponsor_union}"
      if event.custom_attributes_data.sponsor_local && !event.custom_attributes_data.sponsor_local.empty?
        html += "<br>Local #{event.custom_attributes_data.sponsor_local}" 
      end
      html += '</div>'
    elsif !event.custom_attributes_data.sponsor_other.blank? 
     html = "<div id='event-sponsor' class='event-info'><span class='label info-label'>Sponsored by:</span><br> #{event.custom_attributes_data.sponsor_other}</div>"
    end 
  end

  def time_options
    [
      ['',''],
      ['05:00 AM','05:00 AM'],
      ['05:15 AM','05:15 AM'],
      ['05:30 AM','05:30 AM'],
      ['05:45 AM','05:45 AM'],
      ['06:00 AM','06:00 AM'],
      ['06:15 AM','06:15 AM'],
      ['06:30 AM','06:30 AM'],
      ['06:45 AM','06:45 AM'],
      ['07:00 AM','07:00 AM'],
      ['07:15 AM','07:15 AM'],
      ['07:30 AM','07:30 AM'],
      ['07:45 AM','07:45 AM'],
      ['08:00 AM','08:00 AM'],
      ['08:15 AM','08:15 AM'],
      ['08:30 AM','08:30 AM'],
      ['08:45 AM','08:45 AM'],
      ['09:00 AM','09:00 AM'],
      ['09:15 AM','09:15 AM'],
      ['09:30 AM','09:30 AM'],
      ['09:45 AM','09:45 AM'],
      ['10:00 AM','10:00 AM'],
      ['10:15 AM','10:15 AM'],
      ['10:30 AM','10:30 AM'],
      ['10:45 AM','10:45 AM'],
      ['11:00 AM','11:00 AM'],
      ['11:15 AM','11:15 AM'],
      ['11:30 AM','11:30 AM'],
      ['11:45 AM','11:45 AM'],
      ['12:00 PM','12:00 PM'],
      ['12:15 PM','12:15 PM'],
      ['12:30 PM','12:30 PM'],
      ['12:45 PM','12:45 PM'],
      ['01:00 PM','01:00 PM'],
      ['01:15 PM','01:15 PM'],
      ['01:30 PM','01:30 PM'],
      ['01:45 PM','01:45 PM'],
      ['02:00 PM','02:00 PM'],
      ['02:15 PM','02:15 PM'],
      ['02:30 PM','02:30 PM'],
      ['02:45 PM','02:45 PM'],
      ['03:00 PM','03:00 PM'],
      ['03:15 PM','03:15 PM'],
      ['03:30 PM','03:30 PM'],
      ['03:45 PM','03:45 PM'],
      ['04:00 PM','04:00 PM'],
      ['04:15 PM','04:15 PM'],
      ['04:30 PM','04:30 PM'],
      ['04:45 PM','04:45 PM'],
      ['05:00 PM','05:00 PM'],
      ['05:15 PM','05:15 PM'],
      ['05:30 PM','05:30 PM'],
      ['05:45 PM','05:45 PM'],
      ['06:00 PM','06:00 PM'],
      ['06:15 PM','06:15 PM'],
      ['06:30 PM','06:30 PM'],
      ['06:45 PM','06:45 PM'],
      ['07:00 PM','07:00 PM'],
      ['07:15 PM','07:15 PM'],
      ['07:30 PM','07:30 PM'],
      ['07:45 PM','07:45 PM'],
      ['08:00 PM','08:00 PM'],
      ['08:15 PM','08:15 PM'],
      ['08:30 PM','08:30 PM'],
      ['08:45 PM','08:45 PM'],
      ['09:00 PM','09:00 PM'],
      ['09:15 PM','09:15 PM'],
      ['09:30 PM','09:30 PM'],
      ['09:45 PM','09:45 PM'],
      ['10:00 PM','10:00 PM'],
      ['10:15 PM','10:15 PM'],
      ['10:30 PM','10:30 PM'],
      ['10:45 PM','10:45 PM'],
      ['11:00 PM','11:00 PM'],
      ['11:15 PM','11:15 PM'],
      ['11:30 PM','11:30 PM'],
      ['12:00 AM','12:00 AM'],
      ['12:15 AM','12:15 AM'],
      ['12:30 AM','12:30 AM'],
      ['12:45 AM','12:45 AM'],
      ['01:00 AM','01:00 AM'],
      ['01:15 AM','01:15 AM'],
      ['01:30 AM','01:30 AM'],
      ['01:45 AM','01:45 AM'],
      ['02:00 AM','02:00 AM'],
      ['02:15 AM','02:15 AM'],
      ['02:30 AM','02:30 AM'],
      ['02:45 AM','02:45 AM'],
      ['03:00 AM','03:00 AM'],
      ['03:15 AM','03:15 AM'],
      ['03:30 AM','03:30 AM'],
      ['03:45 AM','03:45 AM'],
      ['04:00 AM','04:00 AM'],
      ['04:15 AM','04:15 AM'],
      ['04:30 AM','04:30 AM'],
      ['04:45 AM','04:45 AM']
    ]  
  end

  def union_options
    [
      ["Select a Union",""],
      ["State Federation","State Federation"],
      ["Central Labor Council","Central Labor Council"],
      ["Area Labor Council","Area Labor Council"],
      ["------------------------","linebreak"],
      ["Actors' Equity Association","Actors' Equity Association"],
      ["Air Line Pilots Association","Air Line Pilots Association"],
      ["Amalgamated Transit Union","Amalgamated Transit Union"],
      ["American Association of University Professors","American Association of University Professors"],
      ["American Federation of Government Employees","American Federation of Government Employees"],
      ["American Federation of Musicians of the United Sta...","American Federation of Musicians of the United States and Canada"],
      ["American Federation of School Administrators","American Federation of School Administrators"],
      ["American Federation of State, County and Municipal...","American Federation of State, County and Municipal Employees"],
      ["American Federation of Teachers","American Federation of Teachers"],
      ["American Federation of Television and Radio Artist...","American Federation of Television and Radio Artists"],
      ["American Guild of Musical Artists","American Guild of Musical Artists"],
      ["American Guild of Variety Artists","American Guild of Variety Artists"],
      ["American Postal Workers Union","American Postal Workers Union"],
      ["American Radio Association","American Radio Association"],
      ["American Train Dispatchers Association","American Train Dispatchers Association"],
      ["Associated Actors and Artistes of America","Associated Actors and Artistes of America"],
      ["Association of Flight Attendants ","Association of Flight Attendants "],
      ["Bakery, Confectionery, Tobacco Workers and Grain M...","Bakery, Confectionery, Tobacco Workers and Grain Millers International Union"],
      ["Brotherhood of Railroad Signalmen","Brotherhood of Railroad Signalmen"],
      ["California School Employees Association","California School Employees Association"],
      ["Communications Workers of America","Communications Workers of America"],
      ["Farm Labor Organizing Committee","Farm Labor Organizing Committee"],
      ["Federation of Professional Athletes","Federation of Professional Athletes"],
      ["Glass, Molders, Pottery, Plastics and Allied Worke...","Glass, Molders, Pottery, Plastics and Allied Workers International Union"],
      ["International Alliance of Theatrical Stage Employe...","International Alliance of Theatrical Stage Employes, Moving Picture Technicians, Artists and Allied Crafts of the United States, Its Territories and Canada"],
      ["International Association of Bridge, Structural, O...","International Association of Bridge, Structural, Ornamental and Reinforcing Iron Workers"],
      ["International Association of Fire Fighters","International Association of Fire Fighters"],
      ["International Association of Heat and Frost Insula...","International Association of Heat and Frost Insulators and Allied Workers"],
      ["International Association of Machinists and Aerosp...","International Association of Machinists and Aerospace Workers"],
      ["International Brotherhood of Boilermakers, Iron Sh...","International Brotherhood of Boilermakers, Iron Ship Builders, Blacksmiths, Forgers and Helpers"],
      ["International Brotherhood of Electrical Workers","International Brotherhood of Electrical Workers"],
      ["International Brotherhood of Teamsters","International Brotherhood of Teamsters"],
      ["International Federation of Professional and Techn...","International Federation of Professional and Technical Engineers"],
      ["International Longshore and Warehouse Union","International Longshore and Warehouse Union"],
      ["International Longshoremen's Association","International Longshoremen's Association"],
      ["International Plate Printers, Die Stampers and Eng...","International Plate Printers, Die Stampers and Engravers Union of North America"],
      ["International Union of Allied Novelty and Producti...","International Union of Allied Novelty and Production Workers"],
      ["International Union of Bricklayers and Allied Craf...","International Union of Bricklayers and Allied Craftworkers"],
      ["International Union of Elevator Constructors","International Union of Elevator Constructors"],
      ["International Union of Operating Engineers","International Union of Operating Engineers"],
      ["International Union of Painters and Allied Trades ...","International Union of Painters and Allied Trades of the United States and Canada"],
      ["International Union of Police Associations","International Union of Police Associations"],
      ["Laborers' International Union of North America","Laborers' International Union of North America"],
      ["Laborers' International Union of North America","Laborers' International Union of North America"],
      ["Marine Engineers' Beneficial Association","Marine Engineers' Beneficial Association"],
      ["National Air Traffic Controllers Association","National Air Traffic Controllers Association"],
      ["National Association of Letter Carriers","National Association of Letter Carriers"],
      ["National Education Association","National Education Association"],
      ["National Nurses United","National Nurses United"],
      ["National Postal Mail Handlers Union ","National Postal Mail Handlers Union "],
      ["Office and Professional Employees International Un...","Office and Professional Employees International Union"],
      ["Operative Plasterers' and Cement Masons' Internati...","Operative Plasterers' and Cement Masons' International Association of the United States and Canada"],
      ["Professional Aviation Safety Specialists","Professional Aviation Safety Specialists"],
      ["Screen Actors Guild","Screen Actors Guild"],
      ["Seafarers International Union of North America","Seafarers International Union of North America"],
      ["Service Employees International Union","Service Employees International Union"],
      ["Sheet Metal Workers International Association","Sheet Metal Workers International Association"],
      ["The Guild of Italian American Actors","The Guild of Italian American Actors"],
      ["Transport Workers Union of America","Transport Workers Union of America"],
      ["Transportation Communications International Union/...","Transportation Communications International Union/IAM"],
      ["UNITEHERE!","UNITEHERE!"],
      ["United Association of Journeymen and Apprentices o...","United Association of Journeymen and Apprentices of the Plumbing and Pipe Fitting Industry of the United States and Canada"],
      ["United Automobile, Aerospace & Agricultural Implem...","United Automobile, Aerospace & Agricultural Implement Workers of America International Union"],
      ["United Brotherhood of Carpenters and Joiners of Am...","United Brotherhood of Carpenters and Joiners of America"],
      ["United Farm Workers of America","United Farm Workers of America"],
      ["United Food and Commercial Workers International U...","United Food and Commercial Workers International Union"],
      ["United Mine Workers of America","United Mine Workers of America"],
      ["United Steel, Paper and Forestry, Rubber, Manufact...","United Steel, Paper and Forestry, Rubber, Manufacturing, Energy, Allied Industrial & Service Workers International Union "],
      ["United Transportation Union","United Transportation Union"],
      ["United Union of Roofers, Waterproofers and Allied ...","United Union of Roofers, Waterproofers and Allied Workers"],
      ["Utility Workers Union of America","Utility Workers Union of America"],
      ["Writers Guild of America, East Inc.","Writers Guild of America, East Inc."],
      ["Working America","Working America"],
      ["Other","Other"]
    ]
  end

  def liquid(section, data)
    Liquid::Template.parse(section).render(data.stringify_keys).html_safe
  end

  def liquid_or_default(section, default, data={})
    section.nil? ? default : liquid(section, data)
  end

end
