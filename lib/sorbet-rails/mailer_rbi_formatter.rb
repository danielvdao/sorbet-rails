# typed: strict
require('parlour')
require('sorbet-rails/sorbet_utils.rb')

module SorbetRails
  class MailerRbiFormatter
    extend T::Sig

    Parameter = ::Parlour::RbiGenerator::Parameter

    sig { returns(Parlour::RbiGenerator) }
    attr_reader :rbi_generator

    sig { returns(T.class_of(ActionMailer::Base)) }
    attr_reader :mailer_class

    sig { params(mailer_class: T.class_of(ActionMailer::Base)).void }
    def initialize(mailer_class)
      @mailer_class = T.let(mailer_class, T.class_of(ActionMailer::Base))
      @rbi_generator = T.let(Parlour::RbiGenerator.new, Parlour::RbiGenerator)
    end

    sig { void }
    def populate_rbi
      @rbi_generator.root.add_comments([
        "This is an autogenerated file for Rails' mailers.",
        'Please rerun bundle exec rake rails_rbi:mailers to regenerate.'
      ])

      @rbi_generator.root.create_class(@mailer_class.name) do |mailer_rbi|
        @mailer_class.action_methods.to_a.sort.each do |mailer_method|
          method_def = @mailer_class.instance_method(mailer_method)
          parameters = SorbetRails::SorbetUtils.parameters_from_method_def(method_def)
          mailer_rbi.create_method(
            mailer_method,
            parameters: parameters,
            return_type: 'ActionMailer::MessageDelivery',
            class_method: true,
          )
        end
      end
    end

    sig { returns(String) }
    def generate_rbi
      puts "-- Generate sigs for mailer #{@mailer_class.name} --"
      populate_rbi
      @rbi_generator.rbi
    end
  end
end
