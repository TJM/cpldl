# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  summary        :string(156)
#  description    :text
#  contributor    :string
#  pub_status     :string           default("D")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer
#  level          :string
#  notes          :text
#  slug           :string
#  course_order   :integer
#  pub_date       :datetime
#  format         :string
#  subsite_course :boolean          default(FALSE)
#  parent_id      :integer
#  display_on_dl  :boolean          default(FALSE)
#

require "rails_helper"

describe Course do

  context "verify validations" do

    before(:each) do
      @course = FactoryGirl.build(:course)
      @draft_course = FactoryGirl.create(:draft_course)
    end

    it "is initially valid" do
      expect(@course).to be_valid
    end

    it "should not allow two courses with the same title" do
      course = FactoryGirl.create(:course)
      course.organization = FactoryGirl.create(:organization, id: 1)
      OrganizationCourse.create(course_id: @course, organization_id: @course.organization)
      course.org_id = course.organization.id
      course.validate_has_unique_title

      expect(course.errors.messages.empty?).to be(false)
      expect(course.errors.messages[:title].first).to eq("must be unique. There is already a course with that title, please select a different title and try again.")
    end

    # it "should allow two courses with the same title" do
    #   @course.save
    #   @course2 = FactoryGirl.build(:course)
    #   expect(@course2).to be_valid
    # end

    it "can only have listed statuses" do
      allowed_statuses = %w(P D A)
      allowed_statuses.each do |status|
        @course.pub_status = status
        expect(@course).to be_valid
      end

      @course.pub_status = ""
      expect(@course).to_not be_valid

      @course.pub_status = nil
      expect(@course).to_not be_valid

      @course.pub_status = "X"
      expect(@course).to_not be_valid
    end

    it "can only have listed formats" do
      allowed_formats = %w(D M)
      allowed_formats.each do |format|
        @course.format = format
        expect(@course).to be_valid
      end

      @course.format = ""
      expect(@course).to_not be_valid

      @course.format = nil
      expect(@course).to_not be_valid

      @course.format = "Y"
      expect(@course).to_not be_valid
    end

    it "should initially be set to published status" do
      expect(@draft_course.pub_status).to eq("D")
    end

    it "does not set pub date if status is not Published" do
      expect(@draft_course.set_pub_date).to be(nil)
    end

    it "should set pub date on publication" do
      @course.pub_status = "P"
      expect(@course.set_pub_date.to_i).to eq(Time.zone.now.to_i)
    end

    it "should update the pub date with status change" do
      @course.pub_status = "P"
      expect(@course.set_pub_date).to_not be(nil)
      @course.pub_status = "D"
      expect(@course.update_pub_date(@course.pub_status)).to be(nil)
      @course.pub_status = "P"
      expect(@course.update_pub_date(@course.pub_status).to_i).to be(Time.zone.now.to_i)
    end

    it "humanizes publication status" do
      expect(@course.current_pub_status).to eq("Published")
      @course.pub_status = "D"
      expect(@course.current_pub_status).to eq("Draft")
      @course.pub_status = "T"
      expect(@course.current_pub_status).to eq("Trashed")
    end

    it "should not require the seo page title" do
      @course.seo_page_title = ""
      expect(@course).to be_valid
    end

    it "seo page title cannot be longer than 90 chars" do
      valid_title = (0...90).map { ("a".."z").to_a[rand(26)] }.join
      @course.seo_page_title = valid_title
      expect(@course).to be_valid

      invalid_title = (0...91).map { ("a".."z").to_a[rand(26)] }.join
      @course.seo_page_title = invalid_title
      expect(@course).to_not be_valid
    end

    it "should not require the meta description" do
      @course.seo_page_title = ""
      expect(@course).to be_valid
    end

    it "meta description cannot be longer than 156 chars" do
      valid_meta = (0...156).map { ("a".."z").to_a[rand(26)] }.join
      @course.meta_desc = valid_meta
      expect(@course).to be_valid

      invalid_meta = (0...157).map { ("a".."z").to_a[rand(26)] }.join
      @course.meta_desc = invalid_meta
      expect(@course).to_not be_valid
    end

    it "should not allow the other topics value to be set without text" do
      @course.other_topic = nil
      @course.other_topic_text = ""
      expect(@course).to be_valid

      @course.other_topic = "1"
      @course.other_topic_text = ""
      expect(@course).to_not be_valid

      @course.other_topic = "1"
      @course.other_topic_text = "New topic"
      expect(@course).to be_valid
    end

  end

  context "#topics_list" do

    before(:each) do
      @course = FactoryGirl.create(:course)
      @topic = FactoryGirl.create(:topic, title: "Existing Topic")
    end

    it "assigns topics to a course" do
      topics = ["Topic 1", "Topic2"]
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(2)
    end

    it "returns a topic list as a string" do
      topics = ["Topic 1", "Topic 2"]
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics_str).to eq("Topic 1, Topic 2")
    end

    it "skips blank topics when assigning to a course" do
      topics = ["Topic 1", "Topic2", ""]
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(2)
    end

    it "adds new topics to the list, if not previously there" do
      topics = ["Topic 1", "Topic2", "Topic3", ""]
      @course.topics_list(topics)
      expect(Topic.count).to eq(4) # The exising + the 3 non-empty topics.
    end

    it "does nothing if the topics list is blank" do
      topics = nil
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(0)

      topics = []
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(0)
    end

  end

  context "#next_lesson_id" do

    before :each do
      @course = FactoryGirl.create(:course_with_lessons)
    end

    it "should return the first lesson id if called without an id" do
      expect(@course.next_lesson_id).to be(@course.lessons.first.id)
    end

    it "should return the second lesson id if called with the first lesson id" do
      expect(@course.next_lesson_id(@course.lessons.first.id)).to be(@course.lessons.second.id)
    end

    it "should return the last lesson id if called with the last lesson id" do
      expect(@course.next_lesson_id(@course.lessons.last.id)).to be(@course.lessons.last.id)
    end

    it "should return the first lesson id if called with an invalid lesson id" do
      expect(@course.next_lesson_id(123)).to be(@course.lessons.first.id)
    end

    it "should raise an error if called when there are no lessons" do
      @course.lessons.destroy_all
      expect { @course.next_lesson_id }.to raise_error(StandardError)
    end

  end

  context "duration functions" do

    before :each do
      @course = FactoryGirl.create(:course)
      @lesson1 = FactoryGirl.create(:lesson, title: "1", duration: 75)
      @lesson2 = FactoryGirl.create(:lesson, title: "2", duration: 150)
      @lesson3 = FactoryGirl.create(:lesson, title: "3", duration: 225)
      @lesson4 = FactoryGirl.create(:lesson, title: "4", duration: 90)
      @lesson5 = FactoryGirl.create(:lesson, title: "5", duration: 9)
    end

    it "should return the sum of the lesson durations" do
      @course.lessons << [@lesson1, @lesson2, @lesson3]
      expect(@course.duration).to eq("7 mins")
    end

    it "should return the sum of the lesson durations" do
      @course.lessons << [@lesson4]
      expect(@course.duration).to eq("1 min")
    end

    it "should return the sum of the lesson durations" do
      @course.lessons << [@lesson5]
      expect(@course.duration).to eq("0 mins")
    end

    it "should return duration in format if one is passed" do
      @course.lessons << [@lesson1, @lesson2, @lesson3]
      expect(@course.duration("minutes")).to eq("7 minutes")
    end
  end

end
