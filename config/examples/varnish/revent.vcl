# Revent VCL configuration file for varnish.
#
# NOTE: you should never need to edit this file
# during deployment.  All deployment-specific
# configurations go in revent_deployment_config.vcl
#


# include revent deployment information
# this file is expected to define a director named revent_service
include "revent_deployment_config.vcl";


sub vcl_recv {

  if (req.request == "PURGE") {
    if (!client.ip ~ purge) {
      error 405 "Not allowed.";
    }
    return (lookup);
  }

  if (req.request == "BAN") {
    if (!client.ip ~ purge) {
      error 405 "Not allowed.";
    }

    # This option is to clear any cached object containing the req.url
    ban("req.url ~ "+req.url);

    error 200 "Cached Cleared Successfully.";
  }


  set req.backend = revent_service;

  set req.grace = 12h;

  unset req.http.If-None-Match;

  if (req.request != "GET" && req.request != "HEAD") {
    /* We only deal with GET and HEAD by default */
    return (pass);
  }

  if (req.http.cookie) {
    set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", "");
    #set req.http.Cookie = regsuball(req.http.Cookie, "_daysofaction_session_id=[^;]+(; )?", "");
    if (req.http.cookie ~ "^ *$") {
        remove req.http.cookie;
    }
  }

  # requests we NEVER fetch from cache
  if (req.url ~ "^/logout" ) {
    return (pass);
  }
  if (req.url ~ "^/[^/]+/logout" ) {
    return (pass);
  }
  if (req.url ~ "^/admin" ) {
    return (pass);
  }
  if (req.url ~ "^/profile" ) {
    return (pass);
  }
  if (req.url ~ "^/[^/]+/profile" ) {
    return (pass);
  }
  if (req.url ~ "^/[^/]+/account" ) {
    return (pass);
  }
  if (req.url ~ "^/[^/]+/signup" ) {
    return (pass);
  }
  if (req.url ~ "^/[^/]+/events/copy" ) {
    return (pass);
  }
  if (req.url ~ "^/[^/]+/reports" ) {
    return (pass);
  }
  if (req.url ~ "^/[^/]+/partners" ) {
    return (pass);
  }

  # requests we ALWAYS fetch from cache
  if (req.url ~ "^/themes" ) {
    return (lookup);
  }
  if (req.url ~ "^/javascripts" ) {
    return (lookup);
  }
  if (req.url ~ "^/stylesheets" ) {
    return (lookup);
  }
  if (req.url ~ "^/images" ) {
    return (lookup);
  }
  if (req.url ~ "^/jquery" ) {
    return (lookup);
  }
  if (req.url ~ "^/$" ) {
    return(lookup);
  }

  if (req.request == "GET" && req.url ~ "^/[^/]+/?$" ) {
     unset req.http.cookie;
     unset req.http.Authorization;
     return(lookup);
  }

  return (lookup);
}

sub vcl_hit{
  if (req.request == "PURGE") {
    purge;
    error 200 "Purged.";
  }
}

sub vcl_miss{
  if (req.request == "PURGE") {
    purge;
    error 200 "Purged.";
  }
}
 
sub vcl_fetch {
 
  # responses we NEVER cache
  if (req.url ~ "^/logout" ) {
    return (hit_for_pass);
  }
  if (req.url ~ "^/admin" ) {
    return (hit_for_pass);
  }
  if (req.url ~ "^/profile" ) {
    return (hit_for_pass);
  }
  if (req.url ~ "^/account" ) {
    return (hit_for_pass);
  }
  if (req.url ~ "^/[^/]+/profile" ) {
    return (hit_for_pass);
  }
  if (req.url ~ "^/[^/]+/signup" ) {
    return (hit_for_pass);
  }
  if (req.url ~ "^/[^/]+/events/copy" ) {
    return (hit_for_pass);
  }

  set beresp.grace = 12h; 
  set beresp.ttl = 3m;
  set beresp.http.cache-control = "public, max-age=600";

  if (req.url ~ "^/[^/]+/partners/" ) {
    return (hit_for_pass);
  }
  if (req.request == "GET" && req.url ~ "^/[^/]/?$" ) {
    unset beresp.http.Set-Cookie;
    return (deliver);
  }
  if (!(beresp.ttl > 0s)) {
    return (hit_for_pass);
  }
  if (beresp.http.Set-Cookie) {
    return (hit_for_pass);
  }
  return (deliver);
}

 
sub vcl_deliver {
  return (deliver);
}
