require 'rake/testtask'

task :default => :test

desc 'Run unit tests'
task :test do
  test_files = FileList['*.rb']
  test_files.each do |file|
    if File.basename(file) == 'test_others.rb'
      ruby file
    else
      ruby file, '--test'
    end
  end
end
