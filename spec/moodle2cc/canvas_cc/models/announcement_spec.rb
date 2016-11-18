require 'spec_helper'

module CanvasCc::CanvasCC::Models
  describe Announcement do

    it_behaves_like 'it has an attribute for', :identifier
    it_behaves_like 'it has an attribute for', :dependency
    it_behaves_like 'it has an attribute for', :title
    it_behaves_like 'it has an attribute for', :text
    it_behaves_like 'it has an attribute for', :posted_at
    it_behaves_like 'it has an attribute for', :delayed_post

    it 'creates resource' do
      subject.stub(:announcement_resource) { :announcement_resource }
      subject.stub(:meta_resource) { :meta_resource }
      expect(subject.resources).to eq [:announcement_resource, :meta_resource]
    end

    it "generates a announcement resource" do
      subject.identifier = 'announcement_id'
      subject.dependency = 'dependency_id'
      subject.title = 'announcement title'
      subject.text = 'announcement body'
      announcement_resource = subject.announcement_resource
      expect(announcement_resource).to be_a_kind_of Resource
      expect(announcement_resource.dependencies.count).to eq 1
      expect(announcement_resource.identifier).to eq 'announcement_id'
      expect(announcement_resource.dependencies.first).to eq subject.dependency
      expect(announcement_resource.type).to eq 'imsdt_xmlv1p1'
      expect(announcement_resource.files.count).to eq 1
      expect(announcement_resource.files.first).to eq 'announcement_id.xml'
    end

    it "generates a meta resource" do
      subject.identifier = 'announcement_id'
      subject.dependency = 'dependency_id'
      subject.title = 'announcement title'
      subject.text = 'announcement body'
      meta_resource = subject.meta_resource
      expect(meta_resource).to be_a_kind_of Resource
      expect(meta_resource.type).to eq('associatedcontent/imscc_xmlv1p1/learning-application-resource')
      expect(meta_resource.files.count).to eq 1
      expect(meta_resource.files.first).to eq subject.dependency + '.xml'
    end

  end
end