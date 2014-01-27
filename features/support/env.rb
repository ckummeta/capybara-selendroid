require 'selenium-webdriver'
require 'capybara'
require 'capybara/cucumber'


TEST_CONFIG = ENV.to_hash || {}

environments = {
    'QA' => 'https://qa.com',
    'PRODUCTION' => 'https://www.google.com'
}

TEST_CONFIG['SERVER'] ||= 'QA'
Capybara.app_host = environments[TEST_CONFIG['SERVER'].upcase]

Capybara.default_driver = :selenium
Capybara.default_wait_time = 20

TEST_CONFIG['BROWSER_NAME'] ||= 'firefox'
caps = case TEST_CONFIG['BROWSER_NAME'].downcase
         when 'firefox', 'android'
           browser_name = TEST_CONFIG['BROWSER_NAME'].downcase.to_sym
           Selenium::WebDriver::Remote::Capabilities.send(TEST_CONFIG['BROWSER_NAME'].downcase.to_sym)
         else
           raise "Not supported browser: #{TEST_CONFIG['BROWSER_NAME']}"
       end

if TEST_CONFIG['PLATFORM'] =='ANDROID'
  caps.platform = TEST_CONFIG['PLATFORM'].downcase.to_sym
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => :remote,
                                   :url => "http://localhost:4444/wd/hub",
                                   :desired_capabilities => caps)
  end

else
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => browser_name,
                                   :desired_capabilities => caps)
  end
end
