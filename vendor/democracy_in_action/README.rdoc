= democracy_in_action

* http://github.com/radicaldesigns/democracy_in_action

== DESCRIPTION:

A collection of tools for storing and retrieving data in your Democracy in Action account.


== SYNOPSIS:

===Examples:

Creating a connection to Democracy in Action:
  @dia = DemocracyInAction::API.new( :email => 'bob@example.org', :password => 'secret', :node => :salsa )

Retrieving a list of groups in your account, and getting all their names:
  @dia.groups.get.map { |g| g.Group_Name }

View a list of tables available in Democracy In Action:
  puts DemocracyInAction::Tables::TABLES

View the columns available for your supporters:
  puts @dia.supporter.describe

Get a list of supporters who work for google:
  googlers = @dia.supporter.get( :where => "Email LIKE '%google.com'" )

=====Searches will return an array of DemocracyInAction::Results

These can be accessed by methods matching the column names:
  puts 'jackpot!' if googlers.first.First_Name == 'Sergei'

Or you can treat them as a hash:
  puts 'double jackpot!' if googlers.first['First_Name'] == 'Larry'



== REQUIREMENTS:

Ruby v1.8.6

== INSTALL:

sudo gem install radicaldesigns-democracy_in_action -s http://gems.github.com

== LICENSE:

This library is covered by the LGPL License, version 3
http://www.gnu.org/copyleft/lesser.html

Copyright (c) 2008 Radical Designs

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
