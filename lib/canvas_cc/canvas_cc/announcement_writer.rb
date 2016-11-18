module CanvasCc::CanvasCC
  class AnnouncementWriter

    def initialize(work_dir, announcements)
      @work_dir = work_dir
      @announcements = announcements
    end

    def write
      @announcements.each do |announcement|
      	identifier_write_xml(announcement)
      	dependency_write_xml(announcement)
      end
    end

    private

    def identifier_write_xml(announcement)
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      	topic(xml) do |xml|
      		xml.title announcement.title
      		xml.text_('texttype' => 'text/html') { xml.text CGI.escapeHTML(announcement.text) }
      	end
      end.to_xml
      File.open(File.join(@work_dir, announcement.identifier+'.xml'), 'w') { |f| f.write(xml) }
    end

    def dependency_write_xml(announcement)
    	xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      	topicMeta(xml, announcement) do |xml|
      		xml.topic_id announcement.identifier
      		xml.title announcement.title
      		xml.posted_at announcement.posted_at
      		xml.delayed_post announcement.delayed_post
      		xml.position 1
      		xml.type 'announcement'
      		xml.discussion_type 'side_comment'
      		xml.has_group_category false
      		xml.workflow_state 'active'
      		xml.module_locked false
      		xml.allow_rating
      		xml.only_graders_can_rate
      		xml.sort_by_rating
      	end
      end.to_xml
      File.open(File.join(@work_dir, announcement.dependency+'.xml'), 'w') { |f| f.write(xml) }
    end

    def topicMeta(xml, announcement)
    	xml.topicMeta(
    		"identifier" => announcement.dependency,
    		"xmlns" => "http://canvas.instructure.com/xsd/cccv1p0",
    		"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
    		"xsi:schemaLocation" => "http://canvas.instructure.com/xsd/cccv1p0 http://canvas.instructure.com/xsd/cccv1p0.xsd"
    	) {
    		yield xml
    	}
    end

    def topic(xml)
    	xml.topic(
    		"xmlns" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1",
    		"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
    		"xsi:schemaLocation" => "http://www.imsglobal.org/xsd/imsccv1p1/imsdt_v1p1  http://www.imsglobal.org/profile/cc/ccv1p1/ccv1p1_imsdt_v1p1.xsd"
    	) {
    		yield xml
    	}
    end

  end


end