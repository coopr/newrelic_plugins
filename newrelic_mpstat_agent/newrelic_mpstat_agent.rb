#!/usr/bin/env ruby
$stdout.sync = true

# Reports the following MP statistics : user, nice, sys, iowait, irq, soft, steal, idle, intrps
#
# Compatibility
# -------------
# Requires the mpstat command, usually provided by the sysstat package.


require "rubygems"
require "bundler/setup"
require "newrelic_plugin"

#
#
# NOTE: Please add the following lines to your Gemfile:
#     gem "newrelic_plugin", git: "git@github.com:DevOpHub/newrelic_plugins.git"
#
#
# Note: You must have a config/newrelic_plugin.yml file that
#       contains the following information in order to use
#       this Gem:
#
#       newrelic:
#         # Update with your New Relic account license key:
#         license_key: 'put_your_license_key_here'
#         # Set to '1' for verbose output, remove for normal output.
#         # All output goes to stdout/stderr.
#         verbose: 1
#       agents:
#         mpstat:
#            # The command used to display MP statistics
#            command: mpstat
#            # Report current usage as the average over this many seconds.
#            interval: 5

module MpstatAgent

  class Agent < NewRelic::Plugin::Agent::Base

    agent_guid   "com.devophub.mpstat"
    agent_config_options :command, :interval
    agent_version '0.0.1'
    agent_human_labels("Mpstat") { `hostname` }


    def poll_cycle
      # Using the second reading- avg since previous check
      output = stat_output
      values,result = parse_values(output), {}
      [:usr, :user, :nice, :sys, :iowait, :irq, :soft, :steal, :idle].each do |k|
        report_metric("mpstat/#{k}", "%", values[k]) if values[k]
      end
      report_metric("mpstat/intrps", "instr/sec", values[:intrps]) if values[:intrps]
    rescue Exception => e
      raise "Couldn't parse output. Make sure you have mpstat installed. #{e}"
    end


    private

    def stat_output()
      @command = command || 'mpstat'
      @interval = interval || 5
      stat_command = "#{command} #{interval} 2"
      `#{stat_command}`
    end

    def parse_values(output)
      # Expected output format:
      # 06:58:22 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
      # 06:58:22 AM  all    0.38    0.01    0.24    0.15    0.00    0.01    0.35    0.01   98.89


      # take the format fields
      format=output.split("\n").grep(/CPU/).last.gsub(/\//,'p').gsub(/(%|:|PM|AM)/,'').downcase.split

      # take all the stat fields
      raw_stats=output.split("\n").grep(/[0-9]+\.[0-9]+$/).last.split

      stats={}
      format.each_with_index { |field,i| stats[ format[i].to_sym ]=raw_stats[i] }
      stats
    end

  end


  NewRelic::Plugin::Setup.install_agent :mpstat, MpstatAgent

  #
  # Launch the agent (never returns)
  #
  NewRelic::Plugin::Run.setup_and_run

end
