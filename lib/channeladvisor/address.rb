module ChannelAdvisor
  class Address
    attr_accessor :line1, :line2, :city, :region, :region_description, :postal_code, :country_code,
      :company_name, :job_title , :title, :first_name, :last_name, :suffix, :daytime_phone, :evening_phone

    def initialize(attrs={})
      unless attrs.nil?
        @line1              = attrs[:address_line1]
        @line2              = attrs[:address_line2]
        @city               = attrs[:city]
        @region             = attrs[:region]
        @region_description = attrs[:region_description]
        @postal_code        = attrs[:postal_code]
        @country_code       = attrs[:country_code]
        @company_name       = attrs[:company_name]
        @job_title          = attrs[:job_title]
        @title              = attrs[:title]
        @first_name         = attrs[:first_name]
        @last_name          = attrs[:last_name]
        @suffix             = attrs[:suffix]
        @daytime_phone      = attrs[:phone_number_day]
        @evening_phone      = attrs[:phone_number_evening]
      end
    end

    def full_name
      [@title, @first_name, @last_name].join(" ") + ", #{@suffix}"
    end

    def formatted
      <<-EOF
        #{full_name}
        #{job_title}
        #{@line1}
        #{@line2}
        #{@city}, #{@region} #{@postal_code}
        #{@country_code}
      EOF
    end
  end
end