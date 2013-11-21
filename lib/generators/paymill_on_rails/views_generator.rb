require 'rails/generators'

module PaymillOnRails
  class ViewsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../app/views/paymill_on_rails', __FILE__)
    desc 'Copies views into main app'
    def install
      %w(plans subscriptions).each do |folder|
        %w(_form index show new edit).each do |file|
          copy_file "#{folder}/#{file}.html.erb", "app/views/paymill_on_rails/#{folder}/#{file}.html.erb"
        end
      end

    end
  end
end