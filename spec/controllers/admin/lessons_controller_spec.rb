require "rails_helper"

describe Admin::LessonsController do

  before(:each) do
    @course1 = FactoryGirl.create(:course)
    @lesson1 = FactoryGirl.create(:lesson, title: "Lesson1")
    @lesson2 = FactoryGirl.create(:lesson, title: "Lesson2")
    @course1.lessons << [@lesson1, @lesson2]
    @course1.save

    @admin = FactoryGirl.create(:admin_user)
    @admin.add_role(:admin)
    sign_in @admin
  end

  # => not yet implemented <=

  # describe "GET #index" do
  #   it "assigns all lessons for a given course as @lessons" do
  #     get :index, course_id: @course1.to_param
  #     expect(assigns(:lessons).count).to eq(2)
  #     expect(assigns(:lessons).first).to eq(@lesson1)
  #     expect(assigns(:lessons).second).to eq(@lesson2)
  #   end

  #   it "responds to json" do
  #     get :index, course_id: @course1.to_param, format: :json
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe "GET #edit" do
    it "assigns the requested lesson as @lesson" do
      get :edit, { course_id: @course1.to_param, id: @lesson1.id.to_param }
      expect(assigns(:lesson)).to eq(@lesson1)
    end
  end

  describe "GET #new" do
    it "assigns a new lesson as @lesson" do
      get :new, { course_id: @course1.to_param }
      expect(assigns(:lesson)).to be_a_new(Lesson)
    end
  end

  describe "POST #create" do
    before(:each) do
      @story_line = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/BasicSearch1.zip'), 'application/zip')
    end

    let(:valid_attributes) do
      { duration: 20,
        title:  "Lesson your load man",
        seo_page_title:  "Seo | Beo | Meo ",
        meta_desc:  "Its good to Meta-Tate",
        summary:  "Sum-tings-smelly",
        is_assessment: false,
        story_line: @story_line,
      }
    end

    let(:invalid_attributes) do
      { duration: "",
        title:  "",
        seo_page_title:  "",
        meta_desc:  "",
        summary:  "",
        is_assessment: "",
        story_line: nil,
      }
    end

    context "with valid params" do
      it "creates a new lesson" do
        expect do
          post :create, { course_id: @course1.to_param, lesson: valid_attributes }
        end.to change(Lesson, :count).by(1)
      end

      it "assigns a new lesson as @lesson" do
        post :create, { course_id: @course1.to_param, lesson: valid_attributes }
        expect(assigns(:lesson)).to be_a(Lesson)
        expect(assigns(:lesson)).to be_persisted
      end

      it "redirects to the admin edit view of the lesson" do
        post :create, { course_id: @course1.to_param, lesson: valid_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_admin_course_lesson_path(Course.last, Lesson.last))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved lesson as @lesson" do
        post :create, { course_id: @course1.to_param, lesson: invalid_attributes }
        expect(assigns(:lesson)).to be_a_new(Lesson)
      end

      it "re-renders the 'new' template" do
        post :create, { course_id: @course1.to_param, lesson: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "POST #update" do
    context "with valid params" do
      it "updates an existing Lesson" do
        patch :update, { course_id: @course1.to_param, id: @lesson1.to_param, lesson: @lesson1.attributes, commit: "Save Lesson" }
        expect(response).to have_http_status(:success)
      end
    end
  end

end