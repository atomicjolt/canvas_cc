module CanvasCc::CanvasCC::Models
  class Announcement
  	attr_accessor :identifier, :dependency

  	IMSDT_TYPE = 'imsdt_xmlv1p1'
    LAR_TYPE = 'associatedcontent/imscc_xmlv1p1/learning-application-resource'

  	def resources
  		[announcement_resource, meta_resource]
  	end

  	def announcement_resource
  		resource = CanvasCc::CanvasCC::Models::Resource.new
      resource.identifier = identifier
      resource.dependencies << dependency
      resource.type = IMSDT_TYPE
      resource.files << resource.identifier + '.xml'

      resource
  	end

  	def meta_resource
  		resource = CanvasCc::CanvasCC::Models::Resource.new
      resource.identifier = dependency
      resource.type = LAR_TYPE
      file_name = dependency + '.xml'
      resource.href = file_name
      resource.files << file_name

      resource
  	end

  end
end