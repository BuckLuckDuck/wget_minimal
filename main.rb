require 'open-uri'
require 'net/http'
require 'tempfile'
require 'time'
require 'fileutils'

# Urls for tests
# url = 'https://rubyonrails.org/assets/images/opengraph.png'
# url = 'https://speedtest.selectel.ru/10MB'
# url = 'https://speedtest.selectel.ru/100MB'
# url = 'https://homepages.inf.ed.ac.uk/neilb/TestWordDoc.doc'

if ARGV.length > 2
  raise('Аргументов слишком много. Максимум аргументов: 2 (Ссылка на файл, название файла).')
elsif ARGV.length == 2
  filename = ARGV[1].to_s
end

url = ARGV[0].to_s

uri = URI.parse(url)


def show_progress(length_now)
  prefix = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z']
  suffix = 'B'
  index = 0

  while length_now > 1024.0
    index += 1
    length_now /= 1024.0
  end

  "#{length_now.round(2)} #{prefix[index]}#{suffix}"
end


def download_result(tempfile, destination)
  return tempfile unless destination

  tempfile.close
  FileUtils.mv tempfile.path, destination
end


tempfile = Tempfile.new('tempfile-name', :binmode => true )
progress = 0
time = Time.now.sec
time_start = Time.now

Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  http.request_get(uri.path) do |response|
    response.read_body do |chunk|
      tempfile << chunk
      progress += chunk.length
      if Time.now.sec - time != 0
        progress_text = show_progress(progress)
        puts "Скачано: #{progress_text}"
        time = Time.now.sec
      end
    end

    destination = filename == nil ? uri.path.to_s.split('/')[-1] : filename
    download_result(tempfile, destination)

    puts "Файл #{destination} успешно скачен за #{(Time.now - time_start).round(3)} сек."

    tempfile.close! if tempfile
  end
end