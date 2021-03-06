require "feature_helper"

feature "User is able to view the courses in their plan" do

  before(:each) do
    @english = FactoryGirl.create(:language)
    @spanish = FactoryGirl.create(:spanish_lang)
    @user = FactoryGirl.create(:user)
    @course1 = FactoryGirl.create(:course, title: "Course 1")
    @course2 = FactoryGirl.create(:course, title: "Course 2")
    @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true)
    @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id, tracked: false)
    @user.course_progresses << [@course_progress1, @course_progress2]
    login_as(@user)
  end

  context "as a logged in user" do

    scenario "can view their added courses" do
      visit your_courses_path
      expect(page).to have_content("Course 1")
      expect(page).to_not have_content("Course 2")
    end

    scenario "should always have the option to learn more" do
      visit your_courses_path
      expect(page).to have_content("Ready to Learn More?")
      expect(page).to have_content("Find new courses when you retake the quiz")
      expect(page).to have_link("Retake the Quiz")
    end

  end

end
