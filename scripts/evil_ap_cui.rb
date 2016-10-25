#!/usr/bin/env ruby
require 'thread'
require 'pty'
require 'logger'
require 'pry'
require 'optparse'
require 'json'

REQUIRED_ARGS = [:log]

@options = {}
optparse = OptionParser.new do |opts|

  opts.banner = "Usage: #{$0} --length LENGTH"

  opts.on("-k", "--karma", "Indicate if Karma attack is used") do |karma|
    @options[:karma] = true
  end

  opts.on("-l", "--logfile LOGFILE", "Evil AP output log file (required)") do |log|
    @options[:log] = log
  end

  opts.on("-s", "--ssid SSID", "Initial SSID configured for hostapd") do |ssid|
    @options[:ssid] = ssid
  end

  opts.on("-c", "--channel CHANNEL", "Initial SSID configured for hostapd") do |channel|
    @options[:channel] = channel
  end
end

optparse.parse!

REQUIRED_ARGS.each do |arg|
  unless @options[arg]
    puts
    puts "Missing #{arg}!"
    puts
    puts optparse
    exit!
  end
end

LEASES_FILE = '/var/lib/misc/dnsmasq.leases'
IW_COMMAND = 'iw dev wlan1 station dump'

module EvilAP
  class Runner
    def initialize(opts)
      @start_time = Time.now

      @ssid    = opts[:ssid]
      @karma   = opts[:karma]
      @log     = opts[:log]
      @channel = opts[:channel]

      @data = {}

      @current_probe = nil
      @data_queue = Queue.new

      @leases_watcher_thread     = nil
      @iwlist_watcher_thread     = nil
      @hostapdwpe_watcher_thread = nil
      @cui_watcher_thread        = nil
      @cui_render_thread         = nil
    end

    def run
      start_leases_watcher
      start_iwlist_watcher
      start_hostapdwpe_watcher
      start_cui_watcher
      start_cui_render

      loop do
        sleep 1
      end
    end

    def stop
      @leases_watcher_thread.kill
      @iwlist_watcher_thread.kill
      @hostapdwpe_watcher_thread.kill
      @cui_watcher_thread.kill
      @cui_render_thread.kill
      @data_queue = nil
    end

    def start_leases_watcher
      @leases_watcher_thread = Thread.new do
        loop do
          leases = File.read(LEASES_FILE).split("\n").reject{|ln| ln == ""}
          leases.map! do |line|
            ts, mac, ip, hostname, trash = line.split(' ')
            {
              mac: mac,
              ip: ip,
              hostname: hostname
            }
          end

          @data_queue.push([:leases, leases])
          sleep 1
        end
      end
    end

    def start_iwlist_watcher
      @iwlist_watcher_thread = Thread.new do
        loop do
          begin
            output = `#{IW_COMMAND}`.split("\n").reject{|ln| ln =~ /^\s+$/ }

            stations = []

            output.each do |line|
              if line =~ /^Station/
                stations << [line.strip]
              elsif line =~ /^\t/
                stations.last << line.strip
              end
            end

            stations.map! do |station|
              station.each_with_object({}) do |line, coll|
                if line =~ /^Station/
                  coll[:mac] = line.split(' ')[1]
                else
                  key, value = line.split(/:\s+/)
                  case key
                  when "tx packets"
                    coll[:pkts] ||= 0
                    coll[:pkts] += value.to_i
                  when "rx packets"
                    coll[:pkts] ||= 0
                    coll[:pkts] += value.to_i
                  when "signal"
                    coll[:rssi] = value.split(' ')[0]
                  end
                end
              end
            end

            @data_queue.push([:iw, stations])

            sleep 1
          rescue => e
            puts e
            puts e.backtrace.join("\n")
            exit
          end
        end
      end
    end

    def start_hostapdwpe_watcher
      @hostapdwpe_watcher_thread = Thread.new do
        loop do
          pty_command = "tail -f #{@log}"
          begin
            PTY.spawn(pty_command) do |stdout, stdin, pid|
              current_ssids = Hash.new('')

              stdout.each do |line|
                if line =~ /Probe request from/
                  ssid = line.split('SSID to ').last
                  mac = line.split('from ').last.split(',').first
                  current_ssids[mac] = ssid

                elsif line =~ /association OK/
                  mac = line.split("STA ").last.split(" IEEE").first
                  client = {
                    mac: mac,
                    probe: current_ssids[mac].strip
                  }

                  @last_probe = current_ssids[mac].strip

                  @data_queue.push([:hostapd, [client]])
                end
              end
            end
          rescue Errno::EIO
          rescue => e
            puts e
            puts e.backtrace.join("\n")
            exit
          end
        end
      end
    end

    def start_cui_watcher
      @cui_watcher_thread = Thread.new do
        loop do
          source,records = @data_queue.pop
          records.each do |record|
            @data[record[:mac]] ||= {}
            @data[record[:mac]][:status] ||= Time.now.to_i

            record.keys.each do |key|
              next if key == :source
              @data[record[:mac]][key] = record[key]
            end
          end

          if source == :iw
            online_macs = records.map{|x|x[:mac]}
            @data.each do |k,v|
              if online_macs.include?(k)
                if @data[k][:status] == 'offline'
                  @data[k][:status] = Time.now.to_i
                end
              else
                if @data[k][:probe] && @data[k][:status] != 'offline'
                  json = JSON.generate({
                    connect_time: Time.at(v[:status]).to_s,
                    disconnect_time: Time.now.to_s,
                    mac: v[:mac],
                    ip: v[:ip],
                    hostname: v[:hostname],
                    ssid: v[:probe],
                    packet_count: v[:pkts],
                    last_rssi: v[:rssi]
                  })

                  File.open('connection.log','a') {|f| f.puts(json); f.close}
                end

                @data[k][:status] = 'offline'
              end
            end
          end
        end
      end
    end

    def start_cui_render
      @cui_render_thread = Thread.new do
        loop do
          begin
            clients = @data.values.dup
            clients.reject!{|x| x[:status] == "offline"}

            max_height = `tput lines`.chomp.to_i

            header_map = {
              mac: 'Client MAC',
              ip: 'IP',
              hostname: 'Hostname',
              rssi: 'RSSI',
              probe: 'Probe',
              status: 'Connected for',
              pkts: 'Packet Count'
            }

            alignment_map = {
              status: :right,
              pkts: :right
            }


            max_lengths = header_map.each_with_object({}) do |(k,v),c|
              c[k] = v.length
            end

            clients.each do |hsh|
              header_map.keys.each do |k|
                if max_lengths[k] < hsh[k].to_s.length
                  max_lengths[k] = hsh[k].to_s.length
                end
              end
            end

            # clear screen first
            pbuff = "\e[H\e[2J"
            pbuff += "\n"
            pbuff_count = 1

            pbuff += "\e[0;31mEvil AP >:)~ HACKWEEK EDITION\e[0m --- Running for: #{Time.now.to_i - @start_time.to_i}s\n"
            pbuff << "SSID: #{@ssid}, Channel: #{@channel}, Karma Attack Enabled: #{@karma ? 'true' : 'false'}, Last Probe: #{@last_probe}\n"
            pbuff += "\n"
            pbuff_count += 3

            header = header_map.each_with_object([]) do |(k,v),c|
              c << v.to_s.ljust(max_lengths[k])
            end.join(' | ')

            pbuff += header
            pbuff += "\n"
            pbuff_count += 1

            pbuff += '-' * header.length
            pbuff += "\n"
            pbuff_count += 1

            clients.each do |hsh|
              next if pbuff_count == max_height - 1

              pbuff += header_map.keys.each_with_object([]) do |k,c|
                v = hsh[k]

                if k == :status && v.kind_of?(Integer)
                  v = "#{Time.now.to_i - v}s"
                end

                just = alignment_map[k]

                if just == :right
                  c << v.to_s.rjust(max_lengths[k])
                else
                  c << v.to_s.ljust(max_lengths[k])
                end
              end.join(' | ')
              pbuff += "\n"
              pbuff_count += 1
            end

            puts pbuff
            sleep 0.1
          rescue => e
            puts e
            puts e.backtrace.join("\n")
            exit
          end
        end
      end
    end
  end
end

trap('SIGINT') do
  @runner.stop
  puts
  puts "bye bye!!!!"
  exit!
end

@runner = EvilAP::Runner.new(@options)
@runner.run
