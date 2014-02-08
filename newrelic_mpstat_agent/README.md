## New Relic Mpstat Plugin

### Instructions for running the Mpstat plugin agent

Requires the mpstat command, usually provided by the sysstat package.

1. run `bundle install` to install required gems
2. Edit `config/newrelic_plugin.yml` and replace "YOUR_LICENSE_KEY_HERE" with your New Relic license key
3. Edit the `config/newrelic_plugin.yml` file and add path to 'mpstat' command
4. Execute `ruby newrelic_mpstat_agent.rb`
5. Go back to your New Relic account and after a brief period you will see the Mpstat plugin listed on the left nav
