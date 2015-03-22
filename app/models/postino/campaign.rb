module Postino
  class Campaign < ActiveRecord::Base

    belongs_to :parent, class_name: "Postino::Campaign"
    belongs_to :list
    has_many :subscribers, through: :list
    has_many :attachments
    has_many :metrics
    #has_one :campaign_template
    #has_one :template, through: :campaign_template
    belongs_to :template, class_name: "Postino::Template"
    #accepts_nested_attributes_for :template, :campaign_template

    attr_accessor :step

    validates :subject, presence: true , unless: :step_1?
    validates :from_name, presence: true, unless: :step_1?
    validates :from_email, presence: true, unless: :step_1?

    #validates :plain_content, presence: true, unless: :template_step?
    validates :html_content, presence: true, if: :template_step?

    before_save :detect_changed_template

    mount_uploader :logo, CampaignLogoUploader

    def delivery_progress
      return 0 if metrics.deliveries.size.zero?
      subscribers.size.to_f / metrics.deliveries.size.to_f * 100.0
    end

    def step_1?
      self.step == 1
    end

    def template_step?
      self.step == "template"
    end

    def send_newsletter
      #with custom
      #Postino::CampaignMailer.my_email.delivery_method.settings.merge!(SMTP_SETTINGS)
      #send newsletter here
      self.subscribers.each do |s|
        push_notification(s)
      end
    end

    def test_newsletter
      Postino::CampaignMailer.test(self).deliver_now
    end

    def detect_changed_template
      if self.changes.include?("template_id")
        copy_template
      end
    end

    def generate_premailer
      premailer = Premailer.new('http://localhost:3000/postino/manage/campaigns/1/preview', :warn_level => Premailer::Warnings::SAFE)

    end

    #deliver email + create metric
    def push_notification(subscriber)
      self.metrics.create(trackable: subscriber, action: "deliver")
      Postino::CampaignMailer.newsletter(self, subscriber).deliver_now #deliver_later
    end

    def copy_template
      self.html_content = self.template.body
    end

    def compile_tamplate

    end

    def attributes_for_mailer(subscriber)
      host = Rails.application.routes.default_url_options[:host]
      campaign_url = "#{host}/campaigns/#{self.id}"
      subscriber_url = "#{campaign_url}/subscribers/#{subscriber.encoded_id}"

      { campaign_url: "#{campaign_url}",
        campaign_unsubscribe: "#{subscriber_url}/delete",
        campaign_subscribe: "#{campaign_url}/subscribers/new",
        campaign_description: "#{self.description}" ,
      }
    end

    def mustache_template_for(subscriber)
      Mustache.render(html_content, subscriber.attributes.merge(attributes_for_mailer(subscriber)) )
    end

    def compiled_template_for(subscriber)
      link_prefix = host + "/campaigns/#{self.id}/tracks/#{subscriber.encoded_id}?r="
      Postino::LinkRenamer.convert(mustache_template_for(subscriber), link_prefix)
    end

    def host
      Rails.application.routes.default_url_options[:host] || "http://localhost:3000"
    end

  end
end