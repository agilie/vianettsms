module Vianettsms

  class Sms
    attr_accessor :to, :message, :msgid, :from

    attr_reader :status, :response_hash

    def initialize(params={})
      @to = params[:to]
      @message = params[:message]
      @msgid = params[:msgid]
      @from = params[:from]
      @response = nil
      @response_hash= {}
      @status = nil
      @delivered = false
    end

    def deliver
      if valid?
        handle_response(Net::HTTP.post_form(URI.parse(Vianettsms.url), params_hash))
      end
      delivered?
    end
    
    def delivered?
      @delivered
    end

    def valid?
      raise(ArgumentError, ":to is required") if @to.nil? or @to.empty?
      raise(ArgumentError, ":message is required") if @message.nil? or @message.empty?
      raise(ArgumentError, ":msgid is required") if @msgid.nil? or @msgid.empty?
      not (@to.nil? or @to.empty? or @message.nil? or @message.empty? or @msgid.nil? or @msgid.empty?)
    end

    private 

    attr_accessor :response

    def params_hash
      {
        :username => Vianettsms.config[:username],
        :password => Vianettsms.config[:password],
        :tel => @to || "",
        :msg => @message || "",
        :msgid => @msgid || "",
        :sourceAddr => @from || ""
        }
    end

    def handle_response(response)
      @response = response
      unless @response.nil?
        @response_hash = XmlSimple.xml_in(@response.body)        
        @status = @response_hash['errorcode']
        @delivered = @status == '200'
      end
    end
  end

end
