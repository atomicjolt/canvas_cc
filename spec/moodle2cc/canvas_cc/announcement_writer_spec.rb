require 'spec_helper'

describe CanvasCc::CanvasCC::AnnouncementWriter do
  subject(:writer) { CanvasCc::CanvasCC::AnnouncementWriter.new(work_dir, [announcement]) }
  let(:work_dir) { Dir.mktmpdir }
  let(:announcement) {CanvasCc::CanvasCC::Models::Announcement.new}

  after(:each) do
    FileUtils.rm_r work_dir
  end

  it 'creates the announcement xml' do
    announcement.identifier = 'announcement_id'
    announcement.dependency = 'dependency_id'
    announcement.title = 'Announcement Title'
    announcement.text = '<p>announcement_text</p>'
    writer.write
    xml = Nokogiri::XML(File.read(File.join(work_dir, announcement.announcement_resource.files.first)))
    expect(xml.%('topic/title').text).to eq 'Announcement Title'
    expect(xml.%('topic/text').text).to eq '<p>announcement_text</p>'
    expect(xml.at_xpath('xmlns:topic/xmlns:text/@texttype').value).to eq('text/html')
  end

  it 'creates the meta xml' do
    announcement.identifier = 'announcement_id'
    announcement.dependency = 'dependency_id'
    announcement.title = 'Announcement Title'
    announcement.text = '<p>announcement_text</p>'
    writer.write
    xml = Nokogiri::XML(File.read(File.join(work_dir, announcement.dependency+'.xml')))
    expect(xml.at_xpath('xmlns:topicMeta/@identifier').value).to eq(announcement.dependency)
    expect(xml.%('topicMeta/topic_id').text).to eq announcement.identifier
    expect(xml.%('topicMeta/title').text).to eq announcement.title
    expect(xml.%('topicMeta/type').text).to eq 'announcement'
    expect(xml.%('topicMeta/position').text).to eq "1"
  end

end
