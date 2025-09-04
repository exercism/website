namespace :screenshot do
  desc "Generate ad-hoc screenshots for visual testing (not part of regular test suite)"
  task :generate, [:test_name] => :environment do |_task, args|
    test_name = args[:test_name] || '*'

    Rails.env = 'test'

    # Load the Rails test environment
    require Rails.root.join('test', 'test_helper')
    require Rails.root.join('test', 'application_system_test_case')

    visual_test_files = Dir.glob("test/visual/#{test_name}.rb").select { |f| File.file?(f) }

    if visual_test_files.empty?
      puts "No visual tests found matching pattern: test/visual/#{test_name}.rb"
      puts "Available visual tests:"
      Dir.glob('test/visual/*_test.rb').each do |file|
        puts "  #{File.basename(file, '.rb')}"
      end
      exit 1
    end

    puts "Running visual tests..."
    visual_test_files.each do |file|
      puts "Executing: #{file}"
      load file

      test_class_name = File.basename(file, '.rb').camelize
      test_class = test_class_name.constantize

      test_class.new.run_all_tests
    end

    puts "\nScreenshots generated in tmp/screenshots/"
    puts "Visual test files are in test/visual/ (not run by regular test suite)"
  end
end

class ApplicationSystemTestCase
  def run_all_tests
    methods = self.class.instance_methods(false).select { |m| m.to_s.start_with?('test_') }
    methods.each do |method|
      puts "  Running #{method}..."

      setup if respond_to?(:setup)

      begin
        send(method)
      rescue StandardError => e
        puts "    Error: #{e.message}"
      end

      teardown if respond_to?(:teardown)
    end
  end
end
