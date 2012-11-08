# this is a hack to change REXML behavior, so it
# can handle $ in the tag names...
# instead of editing the libraries, this patches the class
# dynamically.  make sure you require this before any parsing code

require 'rexml/parsers/baseparser'

# TODO: add a good test here to see if there is a flawed version.
# right now, we just apply this patch universally... let's hope
# that's okay

# here are all the constants that depend on NCNAME_STR
# add a $ to end of NCNAME_STR and update the rest accordingly

if REXML::Version >= "3.1.7.2"
  _ncname_str = '[\w:][\-\w\d\$.]*'
  _name_str = "(?:(#{_ncname_str}):)?(#{_ncname_str})"
  _uname_str = "(?:#{_ncname_str}:)?#{_ncname_str}"

  _attribute_pattern = /\s*(#{_name_str})\s*=\s*(["'])(.*?)\4/um
  _tag_match = /^<((?>#{_name_str}))\s*((?>\s+#{_uname_str}\s*=\s*(["']).*?\5)*)\s*(\/)?>/um
  _close_match = /^\s*<\/(#{_name_str})\s*>/um
  _identity = /^([!\*\w\-]+)(\s+#{_ncname_str})?(\s+["'](.*?)['"])?(\s+['"](.*?)["'])?/u

  REXML::Parsers::BaseParser.__send__(:remove_const, :NCNAME_STR)
  REXML::Parsers::BaseParser.__send__(:remove_const, :NAME_STR)
  REXML::Parsers::BaseParser.__send__(:remove_const, :UNAME_STR)
  REXML::Parsers::BaseParser.__send__(:remove_const, :ATTRIBUTE_PATTERN)
  REXML::Parsers::BaseParser.__send__(:remove_const, :TAG_MATCH)
  REXML::Parsers::BaseParser.__send__(:remove_const, :CLOSE_MATCH)
  REXML::Parsers::BaseParser.__send__(:remove_const, :IDENTITY)

  # and now change all the constants (this will produce warnings!)
  REXML::Parsers::BaseParser.const_set("NCNAME_STR", _ncname_str)
  REXML::Parsers::BaseParser.const_set("NAME_STR", _name_str)
  REXML::Parsers::BaseParser.const_set("UNAME_STR", _uname_str)
  REXML::Parsers::BaseParser.const_set("ATTRIBUTE_PATTERN", _attribute_pattern)
  REXML::Parsers::BaseParser.const_set("TAG_MATCH", _tag_match)
  REXML::Parsers::BaseParser.const_set("CLOSE_MATCH", _close_match)
  REXML::Parsers::BaseParser.const_set("IDENTITY", _identity)
else
  _ncname_str = '[\w:][\-\w\d\$.]*'
  _name_str = "(?:#{_ncname_str}:)?#{_ncname_str}"
  _attribute_pattern = /\s*(#{_name_str})\s*=\s*(["'])(.*?)\2/um
  _tag_match = /^<((?>#{_name_str}))\s*((?>\s+#{_name_str}\s*=\s*(["']).*?\3)*)\s*(\/)?>/um
  _close_match = /^\s*<\/(#{_name_str})\s*>/um
  _identity = /^([!\*\w\-]+)(\s+#{_ncname_str})?(\s+["'].*?['"])?(\s+['"].*?["'])?/u

  REXML::Parsers::BaseParser.__send__(:remove_const, :NCNAME_STR)
  REXML::Parsers::BaseParser.__send__(:remove_const, :NAME_STR)
  REXML::Parsers::BaseParser.__send__(:remove_const, :ATTRIBUTE_PATTERN)
  REXML::Parsers::BaseParser.__send__(:remove_const, :TAG_MATCH)
  REXML::Parsers::BaseParser.__send__(:remove_const, :CLOSE_MATCH)
  REXML::Parsers::BaseParser.__send__(:remove_const, :IDENTITY)

  # and now change all the constants (this will produce warnings!)
  REXML::Parsers::BaseParser.const_set("NCNAME_STR", _ncname_str)
  REXML::Parsers::BaseParser.const_set("NAME_STR", _name_str)
  REXML::Parsers::BaseParser.const_set("ATTRIBUTE_PATTERN", _attribute_pattern)
  REXML::Parsers::BaseParser.const_set("TAG_MATCH", _tag_match)
  REXML::Parsers::BaseParser.const_set("CLOSE_MATCH", _close_match)
  REXML::Parsers::BaseParser.const_set("IDENTITY", _identity)
end
