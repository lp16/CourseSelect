class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index
#/-------------------------------------------------I add these cmments-
  def show_owned
    @course=current_user.courses

    #对课程进行排序
    @course=@course.sort_by{|e| e[:course_time]}
  end
  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    @course=Course.all
    @course=@course-current_user.courses

    #对课程进行排序
    @course=@course.sort_by{|e| e[:course_time]}
  end


  ####1系统启动的时候 调用select和qquit方法 登录的的账户的信息得以从数据iu中加载出来

  def select
    @course=Course.find_by_id(params[:id])
    flag=false
    current_user.courses.each do
        |nowcourse|
        if nowcourse.name==@course.name
          flag=true
          break
        end
    end
    if flag==false
      current_user.courses<<@course  ##把该用户的课程信息添加到表示当前用户变量的
                                   ##current_user中 方便之后使用。
      flash={:success => "成功选择课程: #{@course.name}"}
      redirect_to courses_path, flash: flash
    else
      flash={:danger =>"#{@course.name} 已经添加到您的选课中，请选择其他课程!"}
      redirect_to courses_path, flash: flash
    end
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end

end
