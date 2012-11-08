# Example Revent server configurations for Varnish
# this file defines the revent_service director 
# which contains all the deployment-specific configurations
# needed in the main varnish configuration file.


# edit the following backends to match your current rails servers
# add or delete backend servers as necessary

backend revent1{
  .host = "127.0.0.1";
  .port = "80";
  .connect_timeout = 600s;
  .first_byte_timeout = 600s;
  .between_bytes_timeout = 600s;
#   .probe = {
#     .url = "/";
#     .interval = 5s;
#     .timeout = 10s;
#     .window = 5;
#     .threshold = 3;
#   }
}

backend revent2{
  .host = "127.0.0.1";
  .port = "80";
  .connect_timeout = 600s;
  .first_byte_timeout = 600s;
  .between_bytes_timeout = 600s;
#   .probe = {
#     .url = "/";
#     .interval = 5s;
#     .timeout = 10s;
#     .window = 5;
#     .threshold = 3;
#   }
}


# Be sure to add your backend servers to the revent_service director
# NOTE: do not change the name of this director

director revent_service round-robin {
  { .backend = revent1; }
  { .backend = revent2; }
}


# Your application servers should be able to purge the varnish cache

acl purge {
  "localhost";
  "127.0.0.1";
}
