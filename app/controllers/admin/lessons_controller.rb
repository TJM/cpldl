module Admin
  class LessonsController < BaseController

    before_action :set_course, except: [:sort]
    before_action :set_maximums, only: [:new, :edit]

    def index

    end

    def show

    end

    def new
      @lesson = Lesson.new
    end

    def edit
      @lesson = @course.lessons.friendly.find(params[:id])
    end

    def create
      @lesson = @course.lessons.build(lesson_params)
      @lesson.duration_to_int(lesson_params[:duration])
      @lesson.lesson_order = @course.lessons.count + 1

      if @lesson.is_assessment?
        validate_assessment || return
      end

      if @lesson.save
        Unzipper.new(@lesson.story_line)
        redirect_to edit_admin_course_lesson_path(@course, @lesson), notice: "Lesson was successfully created."
      else
        render :new
      end
    end

    def update
      @lesson ||= @course.lessons.friendly.find(params[:id])
      # set slug to nil to regenerate if title changes
      @lesson.slug = nil if @lesson.title != params[:lesson][:title]
      @lesson_params = lesson_params
      @lesson_params[:duration] = @lesson.duration_to_int(lesson_params[:duration])
      asl_is_new = @lesson.story_line_updated_at.nil?
      if @lesson.update(@lesson_params)
        Unzipper.new(@lesson.story_line) if asl_is_new
        redirect_to edit_admin_course_lesson_path, notice: "Lesson successfully updated."
      else
        render :edit, notice: "Lesson failed to update."
      end
    end

    def destroy_asl_attachment
      @lesson = @course.lessons.friendly.find(params[:format])
      @lesson.story_line = nil
      @lesson.save
      FileUtils.remove_dir "#{Rails.root}/public/storylines/#{@lesson.id}", true
      render :edit, notice: "Story Line successfully removed, please upload a new story line .zip file."
    end

    def sort
      params[:order].each do |_k, v|
        Lesson.find(v["id"]).update_attribute(:lesson_order, v["position"])
      end

      render nothing: true
    end

    private

    def set_course
      @course = Course.friendly.find(params[:course_id])
    end

    def lesson_params
      params.require(:lesson).permit(:title,
                                     :summary,
                                     :duration,
                                     :story_line,
                                     :seo_page_title,
                                     :meta_desc,
                                     :is_assessment,
                                     :lesson_order,
                                     :pub_status,
                                     :subdomain)
    end

    def set_maximums
      @max_title = Lesson.validators_on(:title).first.options[:maximum]
      @max_summary = Lesson.validators_on(:summary).first.options[:maximum]
      @max_seo_page_title = Lesson.validators_on(:seo_page_title).first.options[:maximum]
      @max_meta_desc = Lesson.validators_on(:meta_desc).first.options[:maximum]
    end

    def validate_assessment
      if @course.lessons.where(is_assessment: true).blank?
        @lesson.lesson_order = @lesson.course.lessons.count + 1
        return true
      else
        warnings = ["There can only be one assessment for a Course.",
                    "If you are sure you want to <em>replace</em> it, please delete the existing one and try again.",
                    "Otherwise, please edit the existing assessment for this course."]
        flash.now[:alert] = warnings.join("<br/>").html_safe
        render :new and return # rubocop:disable Style/AndOr
      end
    end
  end
end
